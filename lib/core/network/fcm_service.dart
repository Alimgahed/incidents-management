import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Initialize FCM
  static Future<void> initialize() async {
    try {
      // 1. Handle Background Messages (When app is closed/background)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Handle Foreground Messages (When app is open and active)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('--- FCM Message Received in Foreground ---');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        
        // You can add logic here to show a SnackBar or a Dialog
        // Example: Get.snackbar(message.notification?.title ?? "Notification", message.notification?.body ?? "");
      });

      // Request permission on startup
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

  static const String _vapidKey = 'BLoFjQBLpbLC2OX3yfZY4AYr3ws6e80-N-PKtoEZVYjjK3m5ktmXR4erSM1Aek6-QLGTGdBdn0UH5MfSxM6t9kI';

  /// Get FCM Token with retry and Web support
  static Future<String?> getToken() async {
    try {
      debugPrint('FCM: Attempting to get token...');
      String? token;
      
      if (kIsWeb) {
        debugPrint('FCM: Requesting Web token with VAPID key...');
        token = await _fcm.getToken(vapidKey: _vapidKey);
      } else {
        token = await _fcm.getToken();
      }
      
      if (token == null || token.isEmpty) {
        debugPrint('FCM Token is empty, retrying in 2 seconds...');
        await Future.delayed(const Duration(seconds: 2));
        if (kIsWeb) {
          token = await _fcm.getToken(vapidKey: _vapidKey);
        } else {
          token = await _fcm.getToken();
        }
      }

      if (token != null) {
        debugPrint('FCM SUCCESS! Token: $token');
      } else {
        debugPrint('FCM FAILURE: Could not retrieve token.');
      }
      return token;
    } catch (e) {
      debugPrint('FCM ERROR getting token: $e');
      return null;
    }
  }
}

/// Must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}
