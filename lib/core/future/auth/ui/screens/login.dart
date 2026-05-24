import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        context.read<LoginCubit>().login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        state.whenOrNull(
          loaded: (data) {
            final isMobile = MediaQuery.sizeOf(context).width < 600;
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A1628),  // Deep navy
                Color(0xFF0F3460),  // Navy
                Color(0xFF1B4F8A),  // Royal blue (appColor)
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with gold ring
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE0C068), // Light gold
                                Color(0xFFCDA349), // Gold
                                Color(0xFFAA8030), // Dark gold
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCDA349).withAlpha(80),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 20,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 110,
                                width: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'إدارة الأزمات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سجل الدخول للمتابعة إلى لوحة التحكم',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'تسجيل الدخول',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: appColor,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                CustomTextFormField(
                                  controller: _usernameController,
                                  labelText: 'اسم المستخدم',
                                  hintText: 'أدخل اسم المستخدم',
                                  iconData: Icons.person_outline,
                                ),
                                const SizedBox(height: 20),
                                CustomTextFormField(
                                  controller: _passwordController,
                                  labelText: 'كلمة المرور',
                                  hintText: 'أدخل كلمة المرور',
                                  iconData: Icons.lock_outline,
                                  obscureText: true,
                                  enableTogglePassword: true,
                                ),
                                const SizedBox(height: 40),
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
}
