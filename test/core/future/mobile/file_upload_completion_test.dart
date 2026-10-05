import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/add_photo/add_image.dart';

void main() {
  testWidgets('queued attachment is described as pending synchronization', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadCompletionView(
            fileName: 'leak.jpg',
            message: 'تم حفظ الملف محلياً وسيتم رفعه عند عودة الاتصال.',
            onUploadAnother: () {},
          ),
        ),
      ),
    );

    expect(find.text('تم حفظ الملف للمزامنة'), findsOneWidget);
    expect(find.text('تم الرفع بنجاح!'), findsNothing);
    expect(find.byIcon(Icons.schedule_send_rounded), findsOneWidget);
  });

  testWidgets('server-confirmed attachment uses uploaded success state', (
    tester,
  ) async {
    var retryStarted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadCompletionView(
            fileName: 'photo.png',
            message: 'تم رفع الملف بنجاح.',
            onUploadAnother: () => retryStarted = true,
          ),
        ),
      ),
    );

    expect(find.text('تم الرفع بنجاح!'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.tap(find.text('رفع صورة أخرى'));
    expect(retryStarted, isTrue);
  });
}
