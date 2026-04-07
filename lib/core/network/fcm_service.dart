import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Initialize FCM
  static Future<void> initialize() async {
    try {
      // Background message handler (optional, but good practice)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission on startup (or you can wait until login)
      await requestNotificationPermissions();
    } catch (e) {
      debugPrint('FCM Initialization Error: $e');
    }
  }

  /// Request Permissions (Important for iOS and Web)
  static Future<void> requestNotificationPermissions() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  /// Get FCM Token with retry and Web support
  static Future<String?> getToken() async {
    try {
      // On Web, you MUST provide a vapidKey
      // String? token = await _fcm.getToken(vapidKey: 'YOUR_VAPID_KEY_HERE');
      
      String? token = await _fcm.getToken();
      
      if (token == null || token.isEmpty) {
        debugPrint('FCM Token is empty, retrying...');
        // Small delay and retry
        await Future.delayed(const Duration(seconds: 1));
        token = await _fcm.getToken();
      }

      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}

/// Must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}
