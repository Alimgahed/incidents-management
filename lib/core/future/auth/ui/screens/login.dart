import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/network/fcm_service.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_model.dart';
import 'package:incidents_managment/core/future/auth/logic/cubit/login_cubit.dart';
import 'package:incidents_managment/core/future/auth/logic/state/login_state.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final fcmToken = await FcmService.getToken();

      final loginModel = LoginModel(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        deviceToken: fcmToken ?? "",
      );

      if (mounted) {
        context.read<LoginCubit>().login(loginModel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        state.whenOrNull(
          loaded: (data) {
            final isMobile = MediaQuery.of(context).size.width < 600;
            if (isMobile) {
              context.pushNamedAndRemoveUntil(Routes.mobileHome);
            } else {
              context.pushNamedAndRemoveUntil(Routes.crisisDashboardScreen);
            }
          },
          error: (message) {
            ErrorDialog.show(
              context,
              title: 'فشل تسجيل الدخول',
              message: message,
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: const GlobalAppBar(title: 'تسجيل الدخول', showBack: true),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.lock_person_outlined,
                            size: 80,
                            color: appColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle('بيانات الدخول'),
                        const SizedBox(height: 24),

                        CustomTextFormField(
                          controller: _usernameController,
                          labelText: 'اسم المستخدم',
                          hintText: 'أدخل اسم المستخدم لتسجيل الدخول',
                          iconData: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),

                        CustomTextFormField(
                          controller: _passwordController,
                          labelText: 'كلمة المرور',
                          hintText: 'أدخل كلمة المرور',
                          iconData: Icons.lock_outline,
                          obscureText: true,
                          enableTogglePassword: true,
                        ),
                        const SizedBox(height: 48),

                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final isLoading = state.maybeWhen(
                              loading: () => true,
                              orElse: () => false,
                            );
                            return CustomButton(
                              text: 'دخول',
                              isLoading: isLoading,
                              onPressed: _submitForm,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: appColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appColor,
          ),
        ),
      ],
    );
  }
}
