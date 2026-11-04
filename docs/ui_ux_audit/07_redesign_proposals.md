# 07 — Screen-by-Screen Redesign Proposals & Textual Wireframes

This document provides **concrete Desktop and Mobile textual wireframes** and structural redesign specifications for every screen requiring improvement.

---

## 1. Unified Web Application Shell (`CrisisDashboard` + Collapsible `AppDrawer`)

### Target Files
- [`lib/core/future/home/ui/screens/home.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/screens/home.dart)
- [`lib/core/future/home/ui/widgets/app_drawer.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/app_drawer.dart)

### Desktop Wireframe (RTL Layout — Sidebar on Right)
```text
+--------------------------------------------------------------------------------------------------+
| [Contextual Action Slot] [Live Socket Pill]    Page Title & Breadcrumb  | [<<]  شركة مياه المنيا |
+-------------------------------------------------------------------------+------------------------+
|                                                                         |  غرفة العمليات والمتابعة|
|  +-------------------------------------------------------------------+  |  * لوحة متابعة الأزمات  |
|  |                                                                   |  |  o خريطة الأزمات       |
|  |                 SINGLE UNIFIED WORKSPACE CANVAS                   |  |  o التقارير والإحصائيات |
|  |       (No redundant inner AppBar or duplicate hero banner!)       |  |------------------------|
|  |                                                                   |  |  الخرائط والأسطول       |
|  |                                                                   |  |  o خريطة GIS           |
|  |                                                                   |  |  o خريطة المحابس       |
|  |                                                                   |  |  o تتبع الأسطول مباشر  |
|  |                                                                   |  |  o إدارة المركبات      |
|  |                                                                   |  |------------------------|
|  |                                                                   |  |  إدارة البلاغات والمهام |
|  |                                                                   |  |  o إبلاغ عن أزمة       |
|  |                                                                   |  |  o أنواع الأزمات       |
|  |                                                                   |  |  o سجل المهام          |
|  |                                                                   |  |  o ربط المهام بالأزمات |
|  |                                                                   |  |------------------------|
|  |                                                                   |  |  إدارة النظام          |
|  |                                                                   |  |  o إدارة المستخدمين    |
|  +-------------------------------------------------------------------+  |------------------------|
|                                                                         |  [تسجيل الخروج]        |
+-------------------------------------------------------------------------+------------------------+
```
- **Key Structural Improvements**:
  1. Single top header bar (`56px`) with a collapse toggle (`[<<]`) that shrinks `AppDrawer` from `260px` to a `72px` icon-only rail with tooltips.
  2. Child tabs no longer render a second `AppBar` or mobile `header_banner.jpg` inside the desktop workspace.

---

## 2. Incident Command Center Split-View (`DashboardView`, `IncidentsList`, `IncidentDetailsPanel`)

### Target Files
- [`lib/core/future/home/ui/widgets/dash_board/dash_board.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/dash_board.dart)
- [`lib/core/future/home/ui/widgets/dash_board/incient_list.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/incient_list.dart)
- [`lib/core/future/home/ui/widgets/dash_board/incident_details.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/incident_details.dart)

### Desktop Split-View Wireframe (`35:65` Ratio + Full-Width Top Filter Bar)
```text
+--------------------------------------------------------------------------------------------------+
| [Grid / Split Toggle] [Sort] [Branch v] [Severity v] [Status Chips] [Search...] | KPI Counters   |
+------------------------------------------------------------------+-------------------------------+
|  INCIDENT DETAILS PANE (65% Width — LayoutBuilder >= 720px)      | MASTER INCIDENT LIST (35% W)  |
|  +------------------------------------------------------------+  | Min-Width: 340px              |
|  | [تعديل] [تحديث الحالة] [تعيين مهام]   #142 كسر خط مياه رئيسي|  | +---------------------------+ |
|  | الفرع: المنيا | الخطورة: حرج | الحالة: قيد المعالجة        |  | | كسر خط مياه 8 بوصة  [حرج] ||
|  +------------------------------------------------------------+  | | فرع المنيا • منذ 12د [نشط]||
|  +---------------------------+  +-----------------------------+  | +---------------------------+ |
|  | المهام والتدخل الميداني    |  | الموقع الجغرافي والعنوان    |  | +---------------------------+ |
|  | (Balanced Flex Card)      |  | [FlutterMap 300px]          |  | | طفح صرف صحي شارع... [متوسط]||
|  | 1. غلق المحبس الرئيسي [تم]|  | [فتح في خرائط جوجل]         |  | | فرع سمالوط • 02:15م [جديد]||
|  | 2. شفط المياه [قيد التنفيذ]|  +-----------------------------+  | +---------------------------+ |
|  +---------------------------+                                   | +---------------------------+ |
|  +---------------------------+  +-----------------------------+  | | انقطاع مياه بمنطقة... [عالي]||
|  | الصور المرفقة (+ إضافة)   |  | تفاصيل البلاغ والسجل الزمني |  | | فرع ملوي • 01:40م  [محلول]||
|  +---------------------------+  +-----------------------------+  | +---------------------------+ |
+------------------------------------------------------------------+-------------------------------+
```
- **Key Structural Improvements**:
  1. Global KPI & Filter bar spans `100%` width above the split panes so the master list starts immediately at the top.
  2. Master list width increases from `28%` to `35%` (`minWidth: 340px`), and each `IncidentCard` uses a legible 2-row layout (Row 1: Title + Severity; Row 2: Branch + Timestamp + Status Badge) with minimum `12px` Arabic text.
  3. `IncidentDetailsPanel` uses `LayoutBuilder` (`constraints.maxWidth >= 720`) instead of `MediaQuery` and removes the fragile `_MeasureSize` post-frame `setState` loop.

---

## 3. User Management & Registration (`UserManagementScreen` & `RegistrationScreen`)

### Target Files
- [`lib/core/future/home/ui/screens/user_management_screen.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/screens/user_management_screen.dart)
- [`lib/core/future/home/ui/widgets/user_management/user_header.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/user_management/user_header.dart)
- [`lib/core/future/auth/ui/screens/registration.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/auth/ui/screens/registration.dart)

### Desktop Wireframe (`UserManagementScreen` Header + Connected Registration CTA)
```text
+--------------------------------------------------------------------------------------------------+
| [+ تسجيل مستخدم جديد (Primary CTA)] [تحديث]            إدارة المستخدمين والصلاحيات (148 مستخدم) |
+--------------------------------------------------------------------------------------------------+
| [ غير نشط: 6 ]         [ القطاعات: 9 ]         [ المشرفين: 24 ]         [ إجمالي النشطين: 142 ]  |
+--------------------------------------------------------------------------------------------------+
| [Table | Cards Toggle] [القطاع v] [مستوى الصلاحية v] [الحالة v] [ابحث بالاسم أو الكود الوظيفي...] |
+--------------------------------------------------------------------------------------------------+
|  الاسم الكامل      | اسم المستخدم | الكود الوظيفي | الصلاحية    | المجموعة | القطاع     | الحالة  |
|--------------------------------------------------------------------------------------------------|
|  م. أحمد محمود     | a.mahmoud    | 10452         | مشرف عام    | الطوارئ  | فرع المنيا | [نشط]   |
+--------------------------------------------------------------------------------------------------+
```
- **Key Structural Improvements**:
  1. Adds `+ تسجيل مستخدم جديد` primary button in `UserHeader` linking directly to `Routes.registration` and refreshing `AllActiveUserCubit` on return.
  2. Enhances `RegistrationScreen` with a structured 2-column desktop card (`maxWidth: 720px`), password visibility toggle (`enableTogglePassword: true`), and `AppErrorState` on load failure.

---

## 4. Executive Reports Suite (`IncidentReportsScreen`)

### Target File
- [`lib/core/future/reports/ui/incident_reports_screen.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/reports/ui/incident_reports_screen.dart)

### Desktop Wireframe (Compact Chrome + Full-Height Table Tab)
```text
+--------------------------------------------------------------------------------------------------+
| [تصدير CSV] [طباعة PDF/HTML] [تصفية متقدمة (3 فلاتر نشطة) v] | [آخر 30 يوم | الربع | الكل]       |
+--------------------------------------------------------------------------------------------------+
| [8. الجدول التفصيلي] [7. التحليل الجغرافي] ... [2. الملخص والمناطق] [1. الملخص التنفيذي (Active)] |
+--------------------------------------------------------------------------------------------------+
|  [KPI 6: SLA]  [KPI 5: الحل]  [KPI 4: قيد المعالجة]  [KPI 3: حرجة]  [KPI 2: مغلقة]  [KPI 1: الكل] |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|                       EXPANDED ANALYTICAL VIEWPORT (+120px Vertical Gain)                        |
|        (On Tab 8 Detailed Table: Direct Expanded Flex Table with Sticky Header & Footer)         |
|                                                                                                  |
+--------------------------------------------------------------------------------------------------+
```

---

## 5. Link Missions to Incident Type (`Addincidentmission`) & Edit Mission (`EditMissions`)

### Target Files
- [`lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart)
- [`lib/core/future/actions/ui/screens/missions/edit_missions.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/edit_missions.dart)

### Desktop Wireframe (`Addincidentmission` — Single Header + Dual-Pane Builder)
```text
+--------------------------------------------------------------------------------------------------+
| [اختر نوع الأزمة: كسر خط مياه رئيسي v]                 ربط خطوات التدخل القياسية بنوع الأزمة     |
+------------------------------------------------+-------------------------------------------------+
|  خطة التدخل المرتبة (3 مهام محددة)             |  بنك المهام القياسية المتاحة (ابحث أو صفّي)     |
|  +------------------------------------------+  |  [ابحث في المهام...] [كل التصنيفات v]           |
|  | [1] غلق المحبس المغذي للخط   [^] [v] [X] |  |  +-------------------------------------------+  |
|  | [2] الدفع بسيارة شفط المياه  [^] [v] [X] |  |  | [+] تأمين الموقع بالحواجز المرورية        |  |
|  | [3] إبلاغ غرفة عمليات المحافظة[^] [v] [X] |  |  | [+] سحب عينات مياه لتحليل الجودة          |  |
|  +------------------------------------------+  |  +-------------------------------------------+  |
+------------------------------------------------+-------------------------------------------------+
| [حفظ خطة التدخل (Inline Loading Button — No Blocking Raw Dialog!)]      [إعادة تعيين الاختيارات] |
+--------------------------------------------------------------------------------------------------+
```

---

## 6. Mobile Incident Details (`MobileIncidentDetailsScreen`)

### Target File
- [`lib/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart)

### Mobile Wireframe (Segmented 3-Tab Field View)
```text
+---------------------------------------------+
| [رجوع ->]     تفاصيل البلاغ #142    [تعديل] |
|        كسر خط مياه رئيسي - فرع المنيا       |
|       [حرج جداً]        [قيد المعالجة]      |
+---------------------------------------------+
|  [+ إضافة صورة]  [تعيين مهام]  [تحديث الحالة]|  <-- Sticky Quick-Action Strip
+---------------------------------------------+
| [ الصور والسجل ] [ المهام (4) ] [ نظرة عامة*]|  <-- Segmented 3-Tab Bar (Zero Scroll Depth!)
+---------------------------------------------+
|  (When Tab 1 "نظرة عامة" is active):        |
|  +---------------------------------------+  |
|  | الفرع: المنيا     | الوقت: منذ 15 د   |  |
|  | المبلغ: غرفة...   | الخطورة: حرج      |  |
|  +---------------------------------------+  |
|  | الوصف والملاحظات الميدانية            |  |
|  +---------------------------------------+  |
|  | الموقع الجغرافي [فتح في خرائط جوجل]   |  |
|  | [Interactive Mini Map 200px]          |  |
|  +---------------------------------------+  |
+---------------------------------------------+
```
- **Key Structural Improvements**:
  1. Eliminates `1,800px+` of vertical scrolling by organizing field information into 3 immediate tabs (`نظرة عامة والموقع`, `المهام والتدخل`, `الصور والسجل الزمني`).
  2. Keeps the 3 primary field actions (`تحديث الحالة`, `تعيين مهام`, `+ إضافة صورة`) permanently accessible below the header.
