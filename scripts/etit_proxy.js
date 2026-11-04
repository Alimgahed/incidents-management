/**
 * Local dev proxy for Flutter Web -> ETIT (read-only).
 *
 * Why: browsers block cross-origin calls to ETIT (no CORS headers) and forbid
 * setting the `Cookie` header from JS. This proxy owns the ETIT session
 * (login + cookie jar + auto re-login) and adds CORS headers.
 *
 * Run:   node scripts/etit_proxy.js
 * Usage: http://127.0.0.1:8089/?url=<encoded ETIT url>
 */
const http = require('http');
const https = require('https');

const PORT = 8089;
const USERNAME = process.env.ETIT_USER || 'water.menia';
const PASSWORD = process.env.ETIT_PASS || 'Mec@2026';
const ALLOWED_HOSTS = ['etit-fms.etit-eg.com', 'fms-gps.etit-eg.com'];
const SESSION_TTL_MS = 20 * 60 * 1000;

// ── Cookie jars ─────────────────────────────────────────────────────────────
// Both hosts issue their own `ASP.NET_SessionId`, so they must NOT share a jar.
// The GPS host additionally needs the FMS auth/SSO cookies.
const FMS = 'etit-fms.etit-eg.com';
const jars = { [FMS]: {}, 'fms-gps.etit-eg.com': {} };
let lastLogin = 0;
let loginPromise = null;

function cookieHeader(host) {
  const merged = host === FMS ? { ...jars[FMS] } : { ...jars[FMS], ...jars[host] };
  return Object.entries(merged).map(([k, v]) => `${k}=${v}`).join('; ');
}
function storeCookies(host, res) {
  (res.headers['set-cookie'] || []).forEach((c) => {
    const [kv] = c.split(';');
    const i = kv.indexOf('=');
    if (i > 0) jars[host][kv.slice(0, i).trim()] = kv.slice(i + 1);
  });
}

function etitRequest(url, { method = 'GET', body, headers = {} } = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const r = https.request({
      hostname: u.hostname,
      path: u.pathname + u.search,
      method,
      rejectUnauthorized: false,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120.0 Safari/537.36',
        Cookie: cookieHeader(u.hostname),
        ...headers,
        ...(body != null ? { 'Content-Length': Buffer.byteLength(body) } : {}),
      },
    }, (res) => {
      storeCookies(u.hostname, res);
      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body: Buffer.concat(chunks) }));
    });
    r.on('error', reject);
    if (body != null) r.write(body);
    r.end();
  });
}

// ── Login: ASP.NET AJAX async postback (same as the real browser) ──────────
async function doLogin() {
  for (const h of Object.keys(jars)) jars[h] = {};
  const page = (await etitRequest('https://etit-fms.etit-eg.com/')).body.toString('utf8');
  const vs = /id="__VIEWSTATE" value="([^"]*)"/.exec(page)?.[1] ?? '';
  const vsg = /id="__VIEWSTATEGENERATOR" value="([^"]*)"/.exec(page)?.[1] ?? '';

  const form = new URLSearchParams({
    ScriptManager1: 'UpdatePanel1|lg_AltairLogin$LoginButton',
    __EVENTTARGET: 'lg_AltairLogin$LoginButton',
    __EVENTARGUMENT: '',
    __VIEWSTATE: vs,
    __VIEWSTATEGENERATOR: vsg,
    'lg_AltairLogin$UserName': USERNAME,
    'lg_AltairLogin$Password': PASSWORD,
    lg_AltairLogin_RadW_SendEmail_ClientState: '',
    'TokenWindow$C$txt_token': '',
    TokenWindow_ClientState: '',
    NotAuthorizedWindow_ClientState: '',
    RadWindowManager2_ClientState: '',
    __ASYNCPOST: 'true',
    RadAJAXControlID: 'RadAjaxManager1',
  }).toString();

  const res = await etitRequest('https://etit-fms.etit-eg.com/', {
    method: 'POST',
    body: form,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-MicrosoftAjax': 'Delta=true',
      'X-Requested-With': 'XMLHttpRequest',
      Referer: 'https://etit-fms.etit-eg.com/',
    },
  });

  const text = res.body.toString('utf8');
  // Success = ETIT answers with a pageRedirect to an internal page (not the error page).
  if (!/pageRedirect\|\|[^|]*WebPages/i.test(text) || /ErrorPage/i.test(text)) {
    throw new Error('ETIT login failed: ' + text.slice(0, 200));
  }
  // Open the GPS site once so its session is initialised too.
  await etitRequest('https://fms-gps.etit-eg.com/WebPages/Maps.aspx', {
    headers: { Referer: 'https://etit-fms.etit-eg.com/WebPages/Transporters/List.aspx' },
  });
  lastLogin = Date.now();
  console.log(`✅ ETIT login OK (${new Date().toLocaleTimeString()})`);
}

function ensureLogin(force = false) {
  if (!force && lastLogin && Date.now() - lastLogin < SESSION_TTL_MS) return Promise.resolve();
  if (!loginPromise) loginPromise = doLogin().finally(() => { loginPromise = null; });
  return loginPromise;
}

const looksLoggedOut = (r) =>
  r.status >= 500 || r.status === 401 ||
  (r.status === 302 && /login|ErrorPage/i.test(r.headers.location || ''));

// ── HTTP server ────────────────────────────────────────────────────────────
function readBody(req) {
  return new Promise((resolve) => {
    const chunks = [];
    req.on('data', (c) => chunks.push(c));
    req.on('end', () => resolve(chunks.length ? Buffer.concat(chunks) : null));
  });
}

http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', '*');
  if (req.method === 'OPTIONS') { res.writeHead(204); return res.end(); }

  const target = new URL(req.url, 'http://localhost').searchParams.get('url');
  let targetUrl;
  try { targetUrl = new URL(target); } catch (_) { res.writeHead(400); return res.end('Missing or invalid ?url='); }
  if (!ALLOWED_HOSTS.includes(targetUrl.hostname)) { res.writeHead(403); return res.end('Host not allowed'); }

  try {
    const body = await readBody(req);
    // Login page itself is handled by the proxy – the app does not need to log in on web.
    await ensureLogin();

    const fwdHeaders = {
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': 'application/json, text/javascript, */*; q=0.01',
    };
    if (targetUrl.pathname.endsWith('GetAllTransporterBySearchCriteria')) {
      fwdHeaders['Content-Type'] = 'application/json; charset=UTF-8';
    } else if (req.headers['content-type']) {
      fwdHeaders['Content-Type'] = req.headers['content-type'];
    }
    fwdHeaders.Referer = targetUrl.hostname.startsWith('fms-gps')
      ? 'https://fms-gps.etit-eg.com/WebPages/Maps.aspx'
      : 'https://etit-fms.etit-eg.com/WebPages/Transporters/List.aspx';

    const send = () => etitRequest(targetUrl.href, { method: req.method, body, headers: fwdHeaders });
    let r = await send();
    if (looksLoggedOut(r)) {
      console.log(`↻ Session expired (status ${r.status}), re-login…`);
      await ensureLogin(true);
      r = await send();
    }

    const out = { 'Content-Type': r.headers['content-type'] || 'text/plain; charset=utf-8' };
    res.writeHead(r.status, out);
    res.end(r.body);
    console.log(`${req.method} ${targetUrl.pathname} -> ${r.status}`);
  } catch (e) {
    console.error('Proxy error:', e.message);
    res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end('Proxy error: ' + e.message);
  }
}).listen(PORT, '127.0.0.1', () => {
  console.log(`🚀 ETIT proxy running on http://127.0.0.1:${PORT}`);
});
