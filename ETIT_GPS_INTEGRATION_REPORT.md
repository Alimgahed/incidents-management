# تقرير الفحص التقني لمنظومة ETIT GPS Fleet Management ومسارات الـ Integration

**التاريخ:** 4 نوفمبر 2026  
**الهدف:** فحص وتوثيق واجهات برمجة التطبيقات (APIs) لمنظومة التتبع الخاصة بشركة **ETIT (Egyptian Company for Tracking Services and Information Technology)** عبر الرابط المُرسل.

---

## 1. نتائج الفحص الميداني للرابط وبيانات الدخول

- **الرابط المستهدف:** `https://etit-fms.etit-eg.com/`
- **بيانات الدخول المُقدمة:**
  - **Username:** `water.menia`
  - **Password:** `Mec@2026`
- **البنية التقنية للموقع:**
  - المنظومة مبنية بتقنية **ASP.NET WebForms (Legacy Architecture)** على خادم **Microsoft-IIS/8.5**.
  - تعتمد واجهة الدخول على تحكمات مكتبة **Telerik UI for ASP.NET AJAX** (`RadWindowManager`, `TokenWindow`, `RadAjaxManager`).

### نتيجة محاولة تسجيل الدخول البرمجية:
عند إرسال طلب تسجيل الدخول بالبيانات المذكورة، قام الخادم بإرجاع إعادة توجيه (Page Redirect) كالتالي:
```text
pageRedirect||%2fWebPages%2fError%2fErrorPage.aspx?aspxerrorpath=/ETITlogin.aspx
```
وعند فحص الحقول والنوافذ المشروطة (Validation & Windows)، تم رصد التالي:
1. **نافذة التحقق الثنائي / التوكن (Token Window):**
   - يوجد عنصر إدخال يحمل المعرف `TokenWindow$C$txt_token` ورسالة `Token Is Required` تحت Validation Group باسم `save`.
   - هذا يشير إلى أن الحسابات إما تتطلب كود تحقق (OTP / 2FA Token) يُرسل للعميل، أو نافذة تفويض إضافية.
2. **شاشة Not Authorized:**
   - هناك نافذة داخلية باسم `NotAuthorizedWindow` تظهر في حالة انتهاء صلاحية الحساب، عدم تفعيل الصلاحية من جانب مسؤولي ETIT، أو خطأ في بيانات الاعتماد.

---

## 2. الوضع المعماري لـ APIs منظومة ETIT

1. **غياب وثائق عامة (No Public Swagger / Open API):**
   - قامت عمليات الفحص لمسارات مثل `/api`, `/swagger`, `/swagger/index.html`, `/Help` بإرجاع `404 Not Found`.
   - منظومة ETIT-FMS لا تفتح Endpoints عامة للعامة، بل تعتمد المعايير الأمنية لشركات الاتصالات والجهات الحكومية في مصر (ETIT تتبع وزارة الاتصالات وقطاع النقل الذكي).

2. **كيفية عمل الـ Integration الفعلي مع ETIT:**
   بناءً على التوثيق الفني المعياري لشركة ETIT وخدمات تكامل الأساطيل (Fleet Management Integration):
   - **النمط الأول: Integration REST / SOAP APIs مخصصة:**
     تقوم ETIT بتزويد الشريك/الجهة (مثل شركة مياه المنيا) برابط مخصص للربط (Dedicated API Gateway أو Webhook / WCF Service) منفصل عن واجهة الويب الخاصة بالمستخدمين (`etit-fms`).
   - **النمط الثاني: Database / Data Push (Push API / Webhook):**
     تقوم خوادم ETIT بإرسال بيانات التتبع اللحظية (Live Coordinates & Telematics) إلى Endpoint خاص بكم عبر سيرفركم بصيغة JSON عبر HTTP POST دوري.

---

## 3. النموذج المرجعي القياسي لـ ETIT GPS APIs (Data Model & Schema)

في حال استلام وثيقة الـ Integration الرسمية من مهندسي ETIT، تكون النماذج والعمليات الأساسية كالتالي:

### أ. المصادقة (Authentication)
* **الطريقة:** Bearer Token عبر طلب Token Endpoint مخصص للـ API (يسلّمه فريق ETIT Technical Support):
```http
POST /api/Auth/Login
Host: <API_BASE_URL>
Content-Type: application/json

{
  "Username": "water.menia",
  "Password": "...",
  "ClientSecret": "..."
}
```
* **الاستجابة المتوقعة:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 86400
}
```

---

### ب. جلب الحالات اللحظية للمركبات (Latest Fleet Tracking / Telematics)
* **المسار الشائع:** `GET /api/v1/Tracking/GetLatestFleetStatus` أو `GET /api/Vehicles/Positions`
* **Headers:** `Authorization: Bearer <TOKEN>`
* **نموذج البيانات المتوقع (Response Model):**
```json
[
  {
    "vehicleId": "VH-1024",
    "plateNumber": "ن ق د 1234",
    "driverName": "أحمد محمود",
    "latitude": 28.10988,
    "longitude": 30.75030,
    "speed": 45.2,
    "heading": 180,
    "altitude": 42.0,
    "ignition": true,
    "odometer": 128450.5,
    "fuelLevelPercentage": 68.0,
    "engineHours": 1420.3,
    "batteryVoltage": 12.6,
    "gpsSignal": "Good",
    "lastUpdate": "2026-11-04T13:58:20Z",
    "status": "Moving"
  }
]
```

---

### ج. جلب المسار التاريخي (Historical Trips / Track History)
* **المسار:** `POST /api/v1/Reports/TripHistory`
* **Request Body:**
```json
{
  "vehicleId": "VH-1024",
  "fromDateTime": "2026-11-04T00:00:00Z",
  "toDateTime": "2026-11-04T12:00:00Z",
  "includeEvents": true
}
```
* **Response Body:**
```json
{
  "vehicleId": "VH-1024",
  "totalDistanceKm": 85.4,
  "totalDurationMinutes": 140,
  "points": [
    {
      "timestamp": "2026-11-04T08:10:00Z",
      "latitude": 28.10950,
      "longitude": 30.75010,
      "speed": 40.0
    }
  ],
  "alerts": [
    {
      "type": "OverSpeed",
      "timestamp": "2026-11-04T08:45:12Z",
      "value": 105.0
    }
  ]
}
```

---

## 4. الخطوات التنفيذية الموصى بها للبدء الفوري

1. **مراجعة بيانات الدخول والـ Token:**
   - يرجى التحقق من صلاحية الحساب (`water.menia`) عبر الدخول المباشر من متصفحك للتأكد هل يطلب الويب كود توكن (OTP / SMS / Token Key) أو إذا كانت هناك رسالة تظهر على الشاشة تخص انتهاء الاشتراك أو حظر IP.
2. **طلب الـ API Kit المخصص للعملاء (B2B API Package):**
   - الواجهة `etit-fms.etit-eg.com` هي Portal استعراضي للمستخدمين النهائيين (End-User Web Dashboard) وليست بوابة API للمطورين.
   - كجهة متعاقدة (مياه المنيا)، يحق لكم طلب ملف الـ **Integration Specification & API Credentials** مباشرة من الدعم الفني لشركة ETIT عبر:
     - **الخط الساخن:** `19382`
     - **البريد الإلكتروني:** `administrator@etit-eg.com` أو `info@etit-eg.com`
   - يتم طلب: *(REST/Push API Documentation + API Key / Client Secret)*.
3. **تجهيز السيرفر لاستقبال الـ Webhook / Push:**
   - بمجرد تزويدكم بالوثيقة، سنقوم فوراً ببرمجة الـ Client والخدمة في مشروعكم وربط أسطول السيارات مع نظام إدارة البلاغات (Incidents Management System).
