# توثيق الـ APIs ونظام التكامل المباشر (Reverse Engineering Integration) - منظومة ETIT

هذا الدليل يشرح كيفية عمل **Integration كامل ومباشر** مع منظومة **ETIT** عبر الـ APIs الحقيقية التي تستخدمها المنصة بدون الحاجة للتواصل مع دعم الشركة.

---

## 1. الإجابة المباشرة: هل هينفع نعمل Integration من الـ Inspect والـ Network؟

**نعم، بنسبة 100% وبدون الرجوع لأي دعم فني.**

- تم تسجيل الدخول بنجاح بحسابك (`water.menia`).
- النظام يرسل استدعاءات **JSON / RESTful WebMethods** عبر بروتوكول HTTP POST القياسي مع ترويسة `application/json; charset=UTF-8`.
- تم سحب بيانات أسطول شركة مياه المنيا بالكامل: **162 مركبة نشطة** تشمل (رقم اللوحة، كود العربية، الفرع، نوع المركبة، كود جهاز التتبع `deviceCode` وهو موديل **Teltonika**، شريحة **Orange**، الشاسيه، والحالة).

---

## 2. آلية المصادقة وحفظ الجلسة (Authentication & Session Workflow)

المنظومة تعتمد على نظام جلسات ASP.NET مع كوكي المصادقة المشفر:

1. **الخطوة الأولى: تسجيل الدخول (Login Handshake):**
   - **الرابط:** `https://etit-fms.etit-eg.com/`
   - **النوع:** HTTP GET للحصول على `__VIEWSTATE` و `__VIEWSTATEGENERATOR`.
   - **الخطوة التالية:** إرسال HTTP POST مع الحقول:
     - `lg_AltairLogin$UserName`: `water.menia`
     - `lg_AltairLogin$Password`: `Mec@2026`
     - `lg_AltairLogin$LoginButton`: `Login`
2. **الكوكيز الناتجة (Session Tokens):**
   - الخادم يمنحك الكوكيز التالية:
     - `ASP.NET_SessionId`
     - `.ASPXAUTH` (التوكن المشفر لصلاحيات الدخول)
   - بمجرد الاحتفاظ بهذين الكوكيين، يمكنك تنفيذ أي API واستخراج أي داتا مباشرة وبشكل آلي (Automated Cron / Service).

---

## 3. الـ APIs الفعلية المكتشفة (Inspected Endpoints)

### أ. استرجاع قائمة وبيانات جميع سيارات الأسطول (Vehicles / Transporters List)

* **Endpoint URL:**
  `POST https://etit-fms.etit-eg.com/WebPages/Transporters/List.aspx/GetAllTransporterBySearchCriteria`

* **Request Headers:**
  ```http
  Content-Type: application/json; charset=UTF-8
  Accept: application/json, text/javascript, */*; q=0.01
  X-Requested-With: XMLHttpRequest
  Referer: https://etit-fms.etit-eg.com/WebPages/Transporters/List.aspx
  Cookie: ASP.NET_SessionId=...; .ASPXAUTH=...
  ```

* **Request Body (JSON Payload):**
  ```json
  {
    "transpoterCriteria": {
      "SubId": "",
      "StuffId": "",
      "TransporterCodeName": "",
      "TransporterId": "",
      "TransporterTypeId": "",
      "TransporterGroupID": "",
      "LandmarkId": "",
      "ManufacturerId": "",
      "ProductionYearID": "",
      "BranchID": "",
      "SubBranchID": "",
      "NextExaminationDate": "",
      "LicenseExpiryDate": "",
      "InsuranceEndDate": "",
      "EntranceDate": "",
      "TransporterBrand": "",
      "DasboardGPsStatus": "",
      "IsdasboardGPsStatus": 0,
      "TransporterStatus": "",
      "Category": "",
      "ChassisNumber": "",
      "EntranceDateBeforeAfter": "",
      "InsuranceEndDateBeforeAfter": "",
      "LicenseExpiryDateBeforeAfter": "",
      "NextExaminationDateBeforAfter": "",
      "PageCount": 0,
      "PageIndex": 1,
      "PageSize": 200,
      "TotalTransCount": 0,
      "TransporterIdList": []
    }
  }
  ```

* **Response Model (عينة حقيقية تم سحبها من حساب مياه المنيا):**
  الخادم يرجع كائن JSON يحوي بداخله خاصية `d` كنص JSON مشفر:
  ```json
  {
    "d": "{\"total\":\"162\",\"page\":1,\"records\":\"162\",\"rows\":[{\"ID\":\"eb142056-4c1e-e911-80e2-0025b500010d\",\"CodePlateNumber\":\"10\\\\ن س ج 1987\",\"plateNo\":\"ن س ج 1987\",\"isMonitored\":false,\"code\":\"10\",\"branch\":\"f0f79084-4231-ea11-80ee-0025b500010d\",\"Allocation\":\"فرع مطاى\",\"VehicleType\":\"Truck\",\"StatusName\":\"Available\",\"deviceCode\":\"352094085130810\",\"providerName\":\"Orange\",\"Vendor_Name\":\"Teltonika\",\"ChassisNumber\":\"\"}]}"
  }
  ```

* **الحقول المستخرجة لكل عربية:**
  - `ID`: المعرف الفريد للمركبة في قاعدة بيانات المنظومة (UUID).
  - `CodePlateNumber`: كود العربية ورقم اللوحة (مثل `10\ن س ج 1987`).
  - `plateNo`: رقم اللوحة فقط (مثل `ن س ج 1987` أو `ن م ج 9541`).
  - `Allocation`: الفرع التابع له في شركة مياه المنيا (مثل `فرع المنيا`، `فرع مطاى`).
  - `VehicleType`: نوع المركبة (`Truck`, `Trailer`, ...).
  - `StatusName`: الحالة الحالية (`Available`, ...).
  - `deviceCode`: كود ومعرف جهاز الـ GPS الفعلي المركب داخل السيارة (IMEI للجهاز مثل `352094085130810`).
  - `Vendor_Name`: الشركة المصنعة للجهاز (`Teltonika`).
  - `providerName`: مزود شريحة البيانات (`Orange`).

---

### ب. تفاصيل حالة المركبات والإحصائيات (On-Demand Info)

* **Endpoint URL:**
  `POST https://etit-fms.etit-eg.com/WebPages/Transporters/List.aspx/OnLoadGetOnDemandInfo`
* **Response Body:**
  ```json
  {
    "d": "{\"TotalCount\":225,\"MaxLimitTransporter\":242,\"lbl_TransporterNumbers\":\"Created 225 of 242\"}"
  }
  ```

---

### ج. فحص استمرارية الجلسة (Session Keep-Alive)

* **Endpoint URL:**
  `POST https://etit-fms.etit-eg.com/WebPages/Transporters/List.aspx/SessionIsUp`
* يُستخدم هذا الـ Endpoint للتأكد من أن الـ Session لا تزال نشطة قبل إرسال استعلامات التتبع.

---

### د. التنبيهات وإشعارات النظام (System Notifications)

* **Endpoint URL:**
  `GET https://etit-fms.etit-eg.com/WebServices/srvc_MasterNotifications.asmx/GetINSystemNotifications`
* يُرجع التنبيهات المباشرة الواردة من المركبات (تجاوز سرعة، تحرك خارج النطاق).

---

## 4. كيف نقوم بعمل الـ Integration في نظام البلاغات (Incidents Management)؟

يمكننا تنفيذ Microservice خفيف (بـ Node.js أو Python) يقوم بالخطوات التالية تلقائياً:

1. **Auto-Login:** يقوم السيرفر بعمل POST لصفحة الدخول مرة واحدة ويحتفظ بالكوكيز في الذاكرة (Memory/Cache).
2. **Scheduled Sync:** كل دقيقة أو عند فتح بلاغ جديد، يقوم السيرفر بضرب:
   `/WebPages/Transporters/List.aspx/GetAllTransporterBySearchCriteria`
3. **Data Mapping:** ربط السيارات مع البلاغات عبر `plateNo` أو `deviceCode` أو `Allocation` (الفرع).
4. **تجديد تلقائي (Auto Re-login):** في حال انتهت صلاحية الجلسة، يقوم الكود بإعادة تسجيل الدخول أوتوماتيكياً وتحديث الكوكيز دون توقف الخدمة.

الملف جاهز ومكتمل ويمكن البدء في كتابة كود الـ Integration فوراً.
