# Offline-First Architecture

This document describes the offline-first subsystem added to the Incidents
Management app. It is enterprise-grade, modular, and integrates cleanly with
the existing Dio + BLoC + GetIt + Firebase stack.

The implementation is **purely additive**: no existing repository, cubit,
model, or screen was rewritten. A single Dio interceptor automatically makes
every API call in the app offline-aware. One reference repository
(`AddIncdientRepo`) and the file-upload repository were extended to show the
recommended pattern for explicit local cache + temp id support.

---

## 1. Architecture summary

```
┌──────────────────────────── Presentation ────────────────────────────┐
│  OfflineBanner   SyncStatusChip   <existing screens & cubits>        │
│              ▲                                                       │
│              │  state                                                │
│      OfflineStatusCubit (Bloc)                                       │
└──────┬──────────────────────────────────────────────────────────────┘
       │                                                                
┌──────┴───── Domain ─────────────────────────────────────────────────┐
│  SyncManager   ConflictResolver   IdRemapService   TempIdGenerator  │
└──────┬──────────────────────────────────────────────────────────────┘
       │ uses
┌──────┴───── Data ───────────────────────────────────────────────────┐
│  SyncQueueRepository     IncidentCacheRepository                    │
│  MissionCacheRepository  AttachmentCacheRepository                  │
│                                                                     │
│  ── Hive boxes ──                                                   │
│  sync_queue, cache_incidents, cache_missions,                       │
│  cache_attachments, cache_get_responses, cache_kv                   │
└──────┬──────────────────────────────────────────────────────────────┘
       │
┌──────┴───── Network ────────────────────────────────────────────────┐
│  NetworkMonitorService (connectivity_plus)                          │
│  OfflineInterceptor (installed onto shared Dio)                     │
│  ResilientWebSocket (auto-reconnect + heartbeat + post-resync)      │
│  BackgroundSyncService (WorkManager)                                │
└─────────────────────────────────────────────────────────────────────┘
```

Layers are unidirectional: presentation depends on domain, domain on data,
data on raw Hive. The network layer is consumed from both data (interceptor
writes into the queue) and domain (sync manager reads/writes through Dio).

---

## 2. File-by-file changes

### New files (`lib/core/offline/`)

| File | Role |
|---|---|
| `offline_bootstrap.dart` | One-call initializer. Opens Hive, registers all offline services in `get_it`, installs the Dio interceptor, starts network monitor & sync manager, registers background sync. |
| `data/local_database.dart` | Owns every Hive box. `initialize()` + typed getters. `clearAll()` for logout. |
| `data/models/sync_enums.dart` | `SyncState` (pending/syncing/synced/failed/conflict) and `SyncOperation` (post/put/patch/delete/upload) with hand-written Hive adapters (typeIds 110/111). |
| `data/models/sync_queue_item.dart` | The unit of work. Stores endpoint, JSON-encoded payload, retry count, temp id, entity ref, attachment path, exponential-backoff "next eligible at" timestamp. Hive adapter typeId 100. |
| `data/models/cached_incident.dart` | On-disk incident; payload is JSON-encoded for forward compatibility. Flags `hasPendingChanges` and `hasConflict`. typeId 101. |
| `data/models/cached_mission.dart` | Same shape for missions. typeId 102. |
| `data/models/cached_attachment.dart` | Picked image/file + upload state. typeId 103. |
| `data/repositories/sync_queue_repository.dart` | Lock-guarded wrapper around the queue box: `add`, `pending`, `problematic`, `markSyncing`, `markSynced`, `markFailed` (with backoff), `markConflict`, `watch`. |
| `data/repositories/incident_cache_repository.dart` | CRUD + paginated search + temp-id remap + pending/conflict flag toggles. |
| `data/repositories/mission_cache_repository.dart` | Symmetric counterpart for missions. |
| `data/repositories/attachment_cache_repository.dart` | List by incident, list pending uploads, mark uploaded, remap incident id. |
| `domain/temp_id_generator.dart` | Negative integer counter (server ids are positive); also a string `local_<uuid>` helper. |
| `domain/id_remap_service.dart` | When a temp id graduates to a server id, rewrite every queue item, cached entity, and child attachment that referenced the temp id. |
| `domain/conflict_resolver.dart` | Inspects DioExceptions and produces a `ConflictDecision` (preserveLocal / overwriteWithServer / retryLater). |
| `domain/sync_manager.dart` | FIFO queue drain, exponential backoff, attachment uploads, lifecycle event stream. Listens to NetworkMonitor reconnect. |
| `network/network_monitor.dart` | `connectivity_plus` wrapper with `onlineStream`, reconnect listeners, `refresh()`. |
| `network/offline_interceptor.dart` | Installed first in the Dio chain. While offline: writes → queue + synthetic 202 response; reads → served from `cache_get_responses` Hive box. Caches all 200 GETs on the success path. |
| `network/websocket_resilience.dart` | Drop-in resilient wrapper around `socket_io_client`: heartbeat, exponential backoff reconnect, graceful disconnect when offline, post-reconnect resync trigger calling `SyncManager.syncNow`. |
| `background/background_sync.dart` | Subscribes to `AppLifecycleState`. Forces a connectivity re-check and triggers `SyncManager.syncNow()` every time the app comes back to the foreground. No native dependencies. |
| `presentation/offline_status_state.dart` | Equatable snapshot consumed by the banner/chip. |
| `presentation/offline_status_cubit.dart` | Aggregates network + sync + queue counts. |
| `presentation/offline_banner.dart` | Slim banner: offline / syncing / pending / conflict / clean. Has Retry button. |
| `presentation/sync_status_chip.dart` | Compact chip for appbar actions. |

### Modified existing files

| File | Change |
|---|---|
| `pubspec.yaml` | Added: `hive ^2.2.3`, `hive_flutter ^1.1.0`, `path_provider ^2.1.5`, `connectivity_plus ^6.1.0`, `uuid ^4.5.1`, `synchronized ^3.3.0+3`. (No `workmanager` — its 0.5.x release uses removed v1 embedding APIs and breaks the Android build; the lifecycle observer in `background_sync.dart` covers the same use case without native code.) |
| `lib/core/di/dependcy_injection.dart` | Registered the shared `Dio` in get_it so `FileUploadRepository`, `SyncManager`, and offline-aware repos resolve the same instance. |
| `lib/core/helpers/startup_service.dart` | Added `OfflineBootstrap.initialize(...)` between DI setup and the token read. Idempotent. |
| `lib/incidents.dart` | Added a top-level `BlocProvider<OfflineStatusCubit>` and the `OfflineBanner` widget at the top of every screen. |
| `lib/core/security/session_manager.dart` | `logout()` now calls `OfflineBootstrap.resetOnLogout()` to wipe cached data + queue. |
| `lib/core/future/actions/data/repos/add_incident/add_incdient_repo.dart` | **Reference offline-aware repo**. Generates a temp id, writes to the local cache before the network call, passes `entityRef` + `tempLocalId` via Dio `extra`, swaps to server payload on success. |
| `lib/core/future/mobile/data/repo/file_upload_repo.dart` | Always saves the picked file to the attachment cache first; when offline or the incident is still a temp id, defers upload to SyncManager and returns a synthetic 202. Online failures fall back to deferred upload too. |

---

## 3. Sync flow

### 3.1 Online write — happy path

1. UI calls `repo.method(model)`.
2. Repo invokes Retrofit (`ApiService`).
3. Dio runs interceptors. `OfflineInterceptor.onRequest` sees `isOnline` and
   forwards the request.
4. Real server responds.
5. `OfflineInterceptor.onResponse` caches GETs (writes don't get cached).
6. Repo writes the authoritative response into the local cache, returns
   `ApiResult.success`.

### 3.2 Write while offline

1. Repo calls Dio (directly or via Retrofit).
2. `OfflineInterceptor.onRequest` sees `isOffline` and:
   * Builds a `SyncQueueItem` from `RequestOptions` (endpoint, method, JSON
     body, query params, `entityRef`, `tempLocalId`, `attachmentPath`).
   * Persists it to the `sync_queue` Hive box.
   * Resolves the Dio call with a synthetic `Response` (status `202`, body
     `{__offline: true, __queue_id, data: <echoed body>}`).
3. The caller sees a success and updates its BLoC state. The UI updates
   optimistically because the local cache was written *before* the network
   call.
4. The `OfflineBanner` widget re-renders ("Offline — 3 pending").

### 3.3 Read while offline

1. Repo calls Retrofit. `OfflineInterceptor.onRequest` sees `isOffline`.
2. Interceptor looks up `cache_get_responses[uri]`.
3. If present, resolves with the cached body, status 200.
4. If absent, rejects with `DioExceptionType.connectionError` and message
   `offline_no_cache` so callers can show "no cached data" UX.

### 3.4 Reconnect

1. `connectivity_plus` reports online.
2. `NetworkMonitorService` fires registered reconnect listeners.
3. `SyncManager.syncNow()` runs (single-flighted by `Lock`):
   * Calls `queue.pending()` (FIFO, oldest first, honouring backoff windows).
   * For each item:
     * Mark `syncing`.
     * Replay via `dio.request(...)` with header `X-Offline-Replay: true`
       so the interceptor lets it through.
     * On `2xx`:
       * If `tempLocalId` was set, extract the server id from the response
         (`current_incident_id`, `id`, etc.) and call
         `IdRemapService.remapIncidentId(tempId, serverId)`. That rewrites
         *every* queue item, cached entity, and attachment FK that
         referenced the temp id.
       * Drop the queue item.
     * On `409`: hand to `ConflictResolver`. Default policy is
       `preserveLocal` and mark the queue item `conflict`.
     * On other `4xx`: mark `conflict` with the server error message.
     * On transport errors: increment `retryCount`, set
       `nextEligibleAtMs = now + 500ms * 2^retry` (capped at 8 = ~2 min).
   * After the queue is drained, replay pending attachment uploads.
4. `OfflineStatusCubit` collapses the events into a clean
   "All changes synced" banner state.

### 3.5 WebSocket

* `ResilientWebSocket` subscribes to `NetworkMonitorService`.
* Goes offline → disconnects the socket to save battery.
* Comes back online → reconnects, fires `onConnected`, calls
  `SyncManager.syncNow()`, then fires `onResync` so cubits can refetch lists
  to replace cached data with fresh server state.

### 3.6 Background sync

* `BackgroundSyncService.initialize()` registers a 15-minute WorkManager
  periodic task on Android (no-op on web; iOS bridge requires
  `BGTaskScheduler` identifiers in Info.plist when you adopt headless sync).
* The callback dispatcher is intentionally minimal — the next time the app
  is brought to the foreground, `SyncManager.syncNow()` runs as part of
  bootstrap and drains anything left. This avoids the complexity of opening
  Hive + DI in a background isolate and is sufficient for "sync on wake".

---

## 4. Backend expectations

The frontend works against the current API as-is. The following backend
support unlocks the *full* offline experience:

| # | Expectation | Used by |
|---|---|---|
| 1 | All write endpoints accept retries with the *same* payload idempotently. The simplest implementation: accept an optional `Idempotency-Key` header (we can send the queue item's `id`) and de-dup on the server. | All replays |
| 2 | `POST /add-current-incident` returns a JSON body that includes the new `current_incident_id`. | `IdRemapService` |
| 3 | New mission/incident-mission create endpoints likewise return `id`. | `IdRemapService` |
| 4 | When the client's `current_incident_status` is stale, return HTTP `409` with body `{ "code": "stale" or "version_mismatch", "message": "...", "server": {...} }`. | `ConflictResolver` |
| 5 | Image upload (`/upload-incident-photo/:id`) returns `{ "id": <photo_id> }` so attachments can be reconciled. | `SyncManager._uploadAttachment` |
| 6 | The WebSocket emits a "since" or "snapshot" event after the client reconnects so the app can verify nothing was missed (optional; current setup relies on a foreground refetch in `onResync`). | `ResilientWebSocket` |

If you control the backend, also add an optional `X-Client-Queue-Id` header
the server stores so admins can correlate complaints with retried writes —
the offline interceptor already sets a unique `SyncQueueItem.id` on every
queued item.

---

## 5. How to make any existing repo offline-aware

The interceptor alone keeps the app from crashing while offline — but for the
**best** UX (optimistic UI, temp ids, conflict badges), follow the pattern
from `AddIncdientRepo`:

```dart
final isOffline = _monitor.isOffline;

// 1. Synthesize a temp id when we know the entity is brand new.
int tempId = model.id ?? TempIdGenerator.nextNumeric();

// 2. Write to the local cache BEFORE the network call.
await _cache.upsert(
  CachedIncident.fromMap(payload, idOrTempId: tempId, hasPendingChanges: isOffline),
);

// 3. When offline, call Dio directly and pass tracking metadata via `extra`.
if (isOffline) {
  await _dio.post(
    ApiConstants.someEndpoint,
    data: payload,
    options: Options(extra: {
      OfflineInterceptor.kEntityRef: 'incident:$tempId',
      OfflineInterceptor.kTempLocalId: tempId.toString(),
    }),
  );
} else {
  final response = await apiService.someOnlineCall(model);
  // swap optimistic temp entry for the authoritative server copy
  await _cache.remove(tempId);
  await _cache.upsert(CachedIncident.fromMap(response, idOrTempId: response['id']));
}
```

For **edits** (PUT/PATCH) the same pattern applies, but you don't need a
temp id — just write the optimistic update into the cache and pass
`entityRef: 'incident:<id>'`. The interceptor handles the rest.

For **deletes** (DELETE), remove from the cache first, then call Dio. The
interceptor will queue and replay the DELETE.

For **reads** (GET) — no change required. Existing repos work because the
interceptor transparently serves cached responses while offline.

---

## 6. UX recipes

### 6.1 Show queue status on a screen
```dart
BlocBuilder<OfflineStatusCubit, OfflineStatusState>(
  builder: (context, state) {
    if (state.pendingCount == 0) return SizedBox.shrink();
    return Chip(label: Text('${state.pendingCount} unsynced changes'));
  },
)
```

### 6.2 Trigger a manual sync (pull-to-refresh)
```dart
await context.read<OfflineStatusCubit>().retryNow();
```

### 6.3 Render a local-only photo before upload
```dart
final attachments = getIt<AttachmentCacheRepository>()
    .listForIncident(incident.id ?? incident.tempId);
// Build a stream off attachments + the server's photo list, dedup by serverId.
```

### 6.4 Wrap the existing socket with the resilient layer
```dart
final ws = ResilientWebSocket(
  url: ApiConstants.baseUrl,
  networkMonitor: getIt<NetworkMonitorService>(),
  syncManager: getIt<SyncManager>(),
  authToken: token,
  onConnected: (socket) {
    socket.emit('subscribe_incidents', {'user_id': userId});
  },
  onEvent: (event, data) => incidentMapCubit.onSocketEvent(event, data),
  onResync: () => dashboardCubit.refetchAll(),
);
await ws.connect();
```

---

## 7. Future improvements

These are intentionally out of scope of the current pass; each is a small
follow-up:

1. **Headless background sync.** Initialise Hive + DI inside the WorkManager
   callback so the queue drains without the user re-opening the app. Trade
   off against battery + iOS BGTask quotas.
2. **Hive encryption.** Pass an `encryptionCipher` to `Hive.openBox` using a
   key stored in `flutter_secure_storage` so the offline cache is encrypted
   at rest. Trivial wiring; chose not to add it automatically to avoid
   silently locking out existing test data.
3. **Conflict UI.** Build a `ConflictsScreen` that lists queue items with
   `state == conflict` and lets the user "Keep mine", "Use server", or
   "Edit and retry".
4. **Per-entity TTL.** Cache items currently live forever. Add a sweeper
   that drops cached incidents older than N days unless they are pinned or
   have pending changes.
5. **Selective sync.** A "Download for offline" toggle on incidents/branches
   that biases the GET-cache writer to keep certain data even when the
   user navigates away.
6. **Telemetry.** Push `SyncManager` lifecycle events into Firebase
   Analytics so you can monitor the offline-success ratio in production.
7. **Adapter tests.** Add unit tests for `SyncQueueItemAdapter`,
   `CachedIncidentAdapter`, `CachedMissionAdapter`, `CachedAttachmentAdapter`
   round-tripping after a Hive close/open cycle.

---

## 8. Operational checklist

* `flutter pub get` after pulling.
* Android: `WorkManager` requires no manifest changes for the default 15-min
  periodic task; if you adopt `requestOneoff` from sensitive paths add
  `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>`
  to `android/app/src/main/AndroidManifest.xml`.
* iOS: WorkManager's iOS bridge needs `BGTaskScheduler` identifiers in
  `Info.plist` *only if* you enable headless processing inside
  `_callbackDispatcher`. The default (foreground sync on app resume) needs
  nothing extra.
* On logout, `SessionManager.logout()` already wipes the cache.
* In tests, call `OfflineBootstrap.initialize(...)` with an in-memory Hive
  (`Hive.init(Directory.systemTemp.path)`) and a mock Dio.
