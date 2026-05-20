import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('غير مصرح'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Lock icon illustration
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2), // light red
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFECACA),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 80,
                    color: Color(0xFFDC2626), // red-600
                  ),
                ),
                const SizedBox(height: 32),
                
                // Alert Title
                const Text(
                  'عذرًا، غير مصرح بالدخول',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Explanatory Subtitle
                Text(
                  'حسابك الحالي لا يمتلك الصلاحيات الكافية للوصول إلى هذه الصفحة. يرجى مراجعة مسؤول النظام إذا كنت تعتقد أن هذا خطأ.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Return button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.home_outlined, color: Colors.white),
                    label: const Text(
                      'العودة للرئيسية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
