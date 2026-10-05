import 'dart:ui' show Tristate;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/future/auth/data/repo/login/login.dart';
import 'package:incidents_managment/core/future/auth/logic/cubit/login_cubit.dart';
import 'package:incidents_managment/core/future/auth/logic/state/login_state.dart';
import 'package:incidents_managment/core/future/auth/ui/screens/login.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/widget/fields.dart';

void main() {
  late Dio dio;
  late LoginCubit cubit;

  setUp(() {
    dio = Dio();
    cubit = LoginCubit(loginRepo: LoginRepo(apiService: ApiService(dio)));
  });

  tearDown(() async {
    await cubit.close();
    dio.close(force: true);
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    Size size = const Size(800, 900),
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          home: BlocProvider.value(value: cubit, child: const LoginScreen()),
        ),
      ),
    );
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders labeled login fields and password visibility control', (
    tester,
  ) async {
    await pumpLogin(tester);

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('اسم المستخدم'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.byTooltip('إظهار كلمة المرور'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows required field errors without attempting a login', (
    tester,
  ) async {
    await pumpLogin(tester);
    await tester.ensureVisible(find.byType(CustomButton));
    await tester.tap(find.byType(CustomButton));
    await tester.pump();

    expect(find.text('هذا الحقل مطلوب'), findsNWidgets(2));
    expect(cubit.state, const LoginState.initial());
  });

  testWidgets('password visibility can be toggled accessibly', (tester) async {
    await pumpLogin(tester);
    final password = find.byType(EditableText).last;

    expect(tester.widget<EditableText>(password).obscureText, isTrue);
    await tester.tap(find.byTooltip('إظهار كلمة المرور'));
    await tester.pump();

    expect(tester.widget<EditableText>(password).obscureText, isFalse);
    expect(find.byTooltip('إخفاء كلمة المرور'), findsOneWidget);
  });

  testWidgets(
    'loading disables submit and remains usable at 2x text on narrow screens',
    (tester) async {
      final semantics = tester.ensureSemantics();
      cubit.emit(const LoginState.loading());
      await pumpLogin(tester, size: const Size(320, 720), textScale: 2.0);
      await tester.pump();

      final button = tester.getSemantics(find.bySemanticsLabel('دخول'));
      expect(button.flagsCollection.isButton, isTrue);
      expect(button.flagsCollection.isEnabled, Tristate.isFalse);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
