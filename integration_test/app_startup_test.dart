import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'cold start without a saved session reaches a usable login form',
    (tester) async {
      app.main();

      // Startup includes real Firebase/DI/Hive/plugin initialization. Allow
      // those platform futures to complete while the test binding advances the
      // app's minimum splash duration.
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 3)),
      );
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('اسم المستخدم'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);

      // Exercise the real form's recovery path without sending credentials or
      // making an authentication request.
      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(find.text('هذا الحقل مطلوب'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
