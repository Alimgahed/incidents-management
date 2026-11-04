# ETIT GPS Fleet Management — API Compatibility Report

## 1. Verification Summary

All existing ETIT FMS & GPS endpoints, authentication mechanisms, session cookies, proxy routing, and JSON response mappings have been **100% preserved** without modification to backend contracts.

| Requirement | Status | Implementation Reference |
| :--- | :--- | :--- |
| **100% Read-Only Integration** | Verified | Only `GET` and read-only search/login `POST` requests are used. Zero write/mutation endpoints exist. |
| **ETIT Authentication Flow Preserved** | Verified | `POST /Security/Login` with `{"UserName": "water.menia", "Password": "***"}` in `EtitGpsService._authenticate()`. |
| **Proxy Routing Preserved** | Verified | Routes through `http://127.0.0.1:8089/?url=` on local development and supports backend proxy URLs in production. |
| **Vehicle Metadata Endpoint Preserved** | Verified | `POST /FleetManagement/Transporter/GetAllTransporterBySearchCriteria` with `PageSize: 100` across pages `1` and `2` (`162` total vehicles). |
| **Live GPS Telematics Endpoint Preserved** | Verified | `POST https://fms-gps.etit-eg.com/WebPages/Operation/SubPages/GetTransportersSpeedStatus.aspx?lang=en` parsing double-encoded JSON array. |
| **Zero Mock or Hardcoded Vehicle Data** | Verified | All vehicle rows, KPI counts, percentages, branch options, vehicle types, tracker vendors, SIM providers, speeds, and coordinates come strictly from live API responses. |

---

## 2. Preserved Field Mappings (`EtitVehicleModel`)

| ETIT Backend JSON Field | Source Endpoint | `EtitVehicleModel` Property | UI Display Usage |
| :--- | :--- | :--- | :--- |
| `ID` / `TransporterId` | Both Endpoints | `id` | Unique primary key & join key between FMS metadata and GPS telematics |
| `code` | `GetAllTransporterBySearchCriteria` | `code` | Vehicle code badge (`كود: cbcnsisa17`) |
| `plateNo` | `GetAllTransporterBySearchCriteria` | `plateNumber` | Primary vehicle plate number (`د ن 9143`) |
| `CodePlateNumber` | `GetAllTransporterBySearchCriteria` | `codePlateNumber` | Combined search & full details modal |
| `Allocation` | `GetAllTransporterBySearchCriteria` | `allocation` | Branch name (`الفرع`) column & filter dropdown |
| `branch` | `GetAllTransporterBySearchCriteria` | `branch` | Branch UUID in full vehicle details modal |
| `VehicleType` | `GetAllTransporterBySearchCriteria` | `vehicleType` | Vehicle type (`Pickup`, `Trailer`, `Truck`) & Arabic translation (`arabicVehicleType`) |
| `StatusName` | `GetAllTransporterBySearchCriteria` | `statusName` | Administrative fleet status (`Available`) in full details modal |
| `deviceCode` | `GetAllTransporterBySearchCriteria` | `deviceCode` | Tracker IMEI number (`IMEI: 869606020926386`) |
| `Vendor_Name` | `GetAllTransporterBySearchCriteria` | `vendorName` | GPS tracker manufacturer (`Queclink`, `Teltonika`) |
| `providerName` | `GetAllTransporterBySearchCriteria` | `providerName` | SIM network provider (`Vodafone`, `Orange`, `We`) |
| `ChassisNumber` | `GetAllTransporterBySearchCriteria` | `chassisNumber` | Chassis number in search & full details modal |
| `isMonitored` | `GetAllTransporterBySearchCriteria` | `isMonitored` | Monitoring flag in full details modal |
| `lat` / `Latitude` | `GetTransportersSpeedStatus.aspx` | `latitude` | Map marker position, bounds fitting & coordinate copy |
| `lng` / `Longitude` | `GetTransportersSpeedStatus.aspx` | `longitude` | Map marker position, bounds fitting & coordinate copy |
| `speed` / `Speed` | `GetTransportersSpeedStatus.aspx` | `speed` | Live speed in km/h (`السرعة: 56 كم/س`) & speed sorting |
| `statusId` / `StatusId` | `GetTransportersSpeedStatus.aspx` | `statusCode` | Real-time movement state (`isMoving`, `isStopped`, `isOffline`) |
| `trackingDate` / `LastUpdate` | `GetTransportersSpeedStatus.aspx` | `lastUpdate` | Timestamp & relative time formatting (`اليوم 06:08 م`, `منذ 19 دقيقة`) |
| `*` (All raw keys) | Both Endpoints | `rawData` | Every unmapped key returned by ETIT is preserved and rendered in `FleetVehicleDetailsModal` |
