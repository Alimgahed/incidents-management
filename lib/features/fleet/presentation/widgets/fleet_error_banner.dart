import 'package:flutter/material.dart';
import '../../core/error/fleet_failure.dart';
import '../../core/theme/fleet_design_system.dart';

class FleetErrorStateView extends StatelessWidget {
  final FleetFailure failure;
  final VoidCallback onRetry;

  const FleetErrorStateView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: FleetColors.surfaceWhite,
          borderRadius: BorderRadius.circular(FleetRadius.xl),
          border: Border.all(color: FleetColors.offlineBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: FleetColors.offlineBadgeBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 28,
                color: FleetColors.offlineText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تعذر تحديث بيانات الأسطول',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: FleetColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: FleetColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (failure.isRetryable) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'إعادة المحاولة الآن',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FleetColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FleetRadius.md),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FleetInlineErrorBanner extends StatelessWidget {
  final FleetFailure failure;
  final VoidCallback onRetry;

  const FleetInlineErrorBanner({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: FleetColors.offlineCardBg,
        borderRadius: BorderRadius.circular(FleetRadius.md),
        border: Border.all(color: FleetColors.offlineBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: FleetColors.offlineText,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              failure.message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: FleetColors.offlineText,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: const Text('إعادة المحاولة'),
            style: TextButton.styleFrom(
              foregroundColor: FleetColors.offlineText,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
