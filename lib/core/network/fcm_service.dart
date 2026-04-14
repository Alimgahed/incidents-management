import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Required for SnackBar, Column, etc.
import 'package:get/get.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Initialize FCM
  static Future<void> initialize() async {
    try {
      // 1. Handle Background Messages (When app is closed/background)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }

      // 2. Handle Foreground Messages (When app is open and active)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('--- [DEBUG] FCM Message Received in Foreground ---');
        debugPrint('Message ID: ${message.messageId}');
        debugPrint('Notification Title: ${message.notification?.title}');
        debugPrint('Notification Body: ${message.notification?.body}');
        debugPrint('Data Payload: ${message.data}');

        // Show a visual notification in the app
        if (message.notification != null) {
          final title = message.notification?.title ?? "إشعار جديد";
          final body = message.notification?.body ?? "";
          
          // Using Get.snackbar ensures the notification is shown globally
          // without needing the context to be exactly attached to the current Scaffold.
          Get.snackbar(
            title,
            body,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.black,
            borderRadius: 10,
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 5),
            isDismissible: true,
            icon: const Icon(Icons.notifications_active, color: Colors.blueAccent),
            mainButton: TextButton(
              onPressed: () {
                // Handle navigation if needed
                Get.closeCurrentSnackbar();
              },
              child: const Text('عرض', style: TextStyle(color: Colors.blueAccent)),
            ),
          );
        }
      }, onError: (error) {
        debugPrint('--- [ERROR] FCM Foreground Listener Error: $error ---');
      });

      // Request permission on startup
      await requestNotificationPermissions();
      
      // Crucial for Web: We must generate/refresh the token on every app start. 
      // If we skip this when already logged in, Web FCM will not bind properly.
      await getToken();
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
        debugPrint('FCM: User granted permission (authorized)');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('FCM: User granted provisional permission');
      } else {
        debugPrint('FCM: User declined or has not accepted permission. Status: ${settings.authorizationStatus}');
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
        try {
          token = await _fcm.getToken(vapidKey: _vapidKey);
          debugPrint('FCM: Web token retrieved: ${token?.substring(0, 10)}...');
        } catch (webError) {
          debugPrint('FCM ERROR specifically on Web getToken: $webError');
          // Fallback or rethrow? Let's just log for now
        }
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
