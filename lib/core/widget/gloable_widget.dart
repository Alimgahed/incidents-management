import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/helpers/map_helper.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/theming/styling.dart';
import 'package:latlong2/latlong.dart';

class Globalheader extends StatelessWidget {
  const Globalheader({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: appColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: appColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: appColor,
          ),
        ),
      ],
    );
  }
}

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leadingIcon;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onBackPress;

  const GlobalAppBar({
    super.key,
    required this.title,
    this.leadingIcon,
    this.showBack = true,
    this.actions,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
          ),
        ),
      ),
      // Leading section with custom back button design

      // Centered Title with Icon
      title: Center(
        child: Text(
          title,
          style: TextStyles.size20(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ).copyWith(letterSpacing: 0.5),
        ),
      ),

      actions:
          actions ??
          (showBack
              ? [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: appColor,
                        ),
                        onPressed: onBackPress ?? () => context.pop(),
                        tooltip: 'رجوع',
                      ),
                    ),
                  ),
                ]
              : null),

      // Professional Decoration

      // Subtle bottom shadow/border effect
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onPressed,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ErrorDialog(title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Container
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F), // Professional Red
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                    fontFamily: 'Cairo', // Recommended for Arabic
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: 100,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onPressed ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400], // Your global app color
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'موافق',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Floating Error Icon
          Positioned(
            top: -35,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, right: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );
}

class BuildEmptyState extends StatelessWidget {
  final String title;
  final String message;
  const BuildEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ابدأ بإضافة مهمة جديدة',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class Loadding extends StatelessWidget {
  const Loadding({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(appColor),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل ...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class Error extends StatelessWidget {
  const Error({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text('خطأ في تحميل البيانات', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'نم',
    this.onPressed,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          SuccessDialog(title: title, message: message, onPressed: onPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Container
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 80,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onPressed ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green[400], // Your global app color
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Floating Success Icon
          Positioned(
            top: -40,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFloatingButton extends StatelessWidget {
  final String routeName;
  final String text;
  const CustomFloatingButton({
    super.key,
    required this.routeName,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32.0,
      left: 32.0,
      child: GestureDetector(
        onTap: () {
          context.pushNamed(routeName);
        },
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: appColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: appColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.white),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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



class AppMapSection extends StatelessWidget {
  final double lat;
  final double lng;
  final String title;
  final double mapHeight;
  final Color accentColor;

  const AppMapSection({
    super.key,
    required this.lat,
    required this.lng,
    this.title = 'الموقع الجغرافي',
    this.mapHeight = 200.0,
    this.accentColor = Colors.blue, // Default if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row (Optional: Wrap in your _MobileSection if needed)
        Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),

        // Map Preview Box
        SizedBox(
          height: mapHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none, // Static preview
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.crisis_management',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Launch Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => MapUtils.openMap(lat, lng), // Using the Global Util
            icon: const Icon(Icons.map, size: 18),
            label: const Text('فتح في الخرائط'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}