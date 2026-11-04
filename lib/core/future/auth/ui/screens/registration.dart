import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';
import 'package:incidents_managment/core/future/auth/logic/cubit/registration_get_cubit.dart';
import 'package:incidents_managment/core/future/auth/logic/cubit/registraion_post_cubit.dart';
import 'package:incidents_managment/core/future/auth/logic/state/registeration_get_state.dart';
import 'package:incidents_managment/core/future/auth/logic/state/registeration_post_state.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/widget/shimmer/screen_shimmers.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _empNameController = TextEditingController();
  final _empCodeController = TextEditingController();

  int? _selectedAuthLevel;
  int? _selectedGroup;
  int? _selectedSector;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _empNameController.dispose();
    _empCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = ActiveUser(
        username: _usernameController.text.trim(),
        empName: _empNameController.text.trim(),
        empCode: _empCodeController.text.trim(),
        authorityLevelId: _selectedAuthLevel,
        groupId: _selectedGroup,
        password: _passwordController.text.trim(),
        sectorManagementId: _selectedSector,
        isActive: true,
      );
      context.read<RegistrationPostCubit>().register(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationPostCubit, RegistrationPostState>(
      listener: (context, state) {
        state.whenOrNull(
          loaded: (data) {
            SuccessDialog.show(
              context,
              title: 'تم بنجاح',
              message: 'تم تسجيل المستخدم الجديد بنجاح',
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(); // close dialog
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(true); // go back with result
                }
              },
            );
          },
          error: (message) {
            ErrorDialog.show(
              context,
              title: 'فشل التسجيل',
              message: message.error ?? 'خطأ غير معروف',
            );
          },
        );
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const GlobalAppBar(title: 'تسجيل مستخدم جديد'),
          body: SafeArea(
            child: BlocBuilder<RegistrationGetCubit, RegistrationGetState>(
              builder: (context, getState) {
                return getState.when(
                  initial: () => const FormScreenShimmer(fieldCount: 7),
                  loading: () => const FormScreenShimmer(fieldCount: 7),
                  error: (message) => AppErrorState(
                    title: 'تعذر تحميل بيانات الصلاحيات والإدارات',
                    message: message,
                    onRetry: () =>
                        context.read<RegistrationGetCubit>().getregister(),
                  ),
                  loaded: (data) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderLg,
                              border: Border.all(color: AppColors.border),
                              boxShadow: AppShadows.subtle,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('البيانات الأساسية'),
                                  const SizedBox(height: 20),

                                  CustomTextFormField(
                                    controller: _empNameController,
                                    labelText: 'الاسم الكامل *',
                                    hintText: 'أدخل الاسم الكامل للموظف',
                                    iconData: Icons.person_outline,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextFormField(
                                    controller: _usernameController,
                                    labelText: 'اسم المستخدم *',
                                    hintText: 'أدخل اسم المستخدم لتسجيل الدخول',
                                    iconData: Icons.badge_outlined,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextFormField(
                                    controller: _passwordController,
                                    labelText: 'كلمة المرور *',
                                    hintText: 'أدخل كلمة المرور',
                                    iconData: Icons.lock_outline,
                                    obscureText: true,
                                    enableTogglePassword: true,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextFormField(
                                    controller: _empCodeController,
                                    labelText: 'كود الموظف (الرقم الوظيفي) *',
                                    hintText: 'أدخل الرقم الوظيفي',
                                    iconData: Icons.pin_outlined,
                                    isNumberField: true,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  const SizedBox(height: 28),

                                  _buildSectionTitle('بيانات الصلاحيات والإدارة'),
                                  const SizedBox(height: 20),

                                  CustomDropdownFormField<int>(
                                    labelText: 'مستوى الصلاحية *',
                                    hintText: 'اختر مستوى الصلاحية',
                                    iconData: Icons.security_outlined,
                                    value: _selectedAuthLevel,
                                    items: data.authLevels.map((e) {
                                      return DropdownMenuItem<int>(
                                        value: e.id,
                                        child: Text(e.description),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedAuthLevel = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  CustomDropdownFormField<int>(
                                    labelText: 'المجموعة *',
                                    hintText: 'اختر المجموعة أو الفريق',
                                    iconData: Icons.group_outlined,
                                    value: _selectedGroup,
                                    items: data.groups.map((e) {
                                      return DropdownMenuItem<int>(
                                        value: e.groupId,
                                        child: Text(e.groupName),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedGroup = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  CustomDropdownFormField<int>(
                                    labelText: 'القطاع / الإدارة *',
                                    hintText: 'اختر القطاع التابع له الموظف',
                                    iconData: Icons.domain_outlined,
                                    value: _selectedSector,
                                    items: data.sectors.map((e) {
                                      return DropdownMenuItem<int>(
                                        value: e.id,
                                        child: Text(e.name),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedSector = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 36),

                                  BlocBuilder<
                                    RegistrationPostCubit,
                                    RegistrationPostState
                                  >(
                                    builder: (context, postState) {
                                      final isLoading = postState.maybeWhen(
                                        loading: () => true,
                                        orElse: () => false,
                                      );
                                      return CustomButton(
                                        text: 'تسجيل الحساب',
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
                    );
                  },
                );
              },
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
