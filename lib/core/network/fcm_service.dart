import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Required for SnackBar, Column, etc.
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/alarm_service.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_picker_bridge.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static String? _cachedToken;

  /// Initialize FCM
  static Future<void> initialize() async {
    try {
      // 1. Handle Background Messages (When app is closed/background)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }

      // 2. Handle Foreground Messages (When app is open and active)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('--- [DEBUG] FCM Message Received in Foreground ---');
          debugPrint('Message ID: ${message.messageId}');
          debugPrint('Notification Title: ${message.notification?.title}');
          debugPrint('Notification Body: ${message.notification?.body}');
          debugPrint('Data Payload: ${message.data}');
        }

        // Show a visual notification in the app
        if (message.notification != null) {
          final title = message.notification?.title ?? "إشعار جديد";
          final body = message.notification?.body ?? "";
          
          // Play loud alarm for 10 seconds if it's a new incident (or just assume critical notifications)
          if (title.contains('أزمة') || body.contains('أزمة') || 
              title.contains('بلاغ') || title.contains('جديد')) {
            try {
              getIt<AlarmService>().playAlarmForDuration(const Duration(seconds: 10));
            } catch (e) {
              if (kDebugMode) debugPrint('Could not play alarm: $e');
            }
          }
          
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
            icon: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
            ),
            mainButton: TextButton(
              onPressed: () {
                _handleNotificationClick(message.data);
                Get.closeCurrentSnackbar();
              },
              child: const Text('عرض', style: TextStyle(color: Colors.blueAccent)),
            ),
          );
        }
      }, onError: (error) {
        if (kDebugMode) debugPrint('--- [ERROR] FCM Foreground Listener Error: $error ---');
      });

      // 3. Handle Notification Clicks (When app is in background but not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) debugPrint('--- [DEBUG] Notification Clicked in Background ---');
        _handleNotificationClick(message.data);
      });

      // 4. Handle Notification Clicks (When app was completely terminated/closed)
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) debugPrint('--- [DEBUG] App Opened from Terminated State via Notification ---');
        // Delay slightly to ensure UI is mounted before navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationClick(initialMessage.data);
        });
      }

      // Request permission on startup
      await requestNotificationPermissions();

      // Crucial for Web: We must generate/refresh the token on every app start.
      // If we skip this when already logged in, Web FCM will not bind properly.
      await getToken();
    } catch (e) {
      if (kDebugMode) debugPrint('FCM Initialization Error: $e');
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

      if (kDebugMode) {
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('FCM: User granted permission (authorized)');
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
          debugPrint('FCM: User granted provisional permission');
        } else {
          debugPrint('FCM: User declined or has not accepted permission. Status: ${settings.authorizationStatus}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error requesting notification permissions: $e');
    }
  }

  static const String _vapidKey = 'BLoFjQBLpbLC2OX3yfZY4AYr3ws6e80-N-PKtoEZVYjjK3m5ktmXR4erSM1Aek6-QLGTGdBdn0UH5MfSxM6t9kI';

  /// Get FCM Token with retry and Web support
  static Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      if (kDebugMode) debugPrint('FCM: Returning cached token instantly.');
      return _cachedToken;
    }

    try {
      if (kDebugMode) debugPrint('FCM: Attempting to get token...');
      String? token;

      if (kIsWeb) {
        if (kDebugMode) debugPrint('FCM: Requesting Web token with VAPID key...');
        try {
          token = await _fcm.getToken(vapidKey: _vapidKey);
          if (kDebugMode) debugPrint('FCM: Web token retrieved: ${token?.substring(0, 10)}...');
        } catch (webError) {
          if (kDebugMode) debugPrint('FCM ERROR specifically on Web getToken: $webError');
        }
      } else {
        token = await _fcm.getToken();
      }

      if (token == null || token.isEmpty) {
        if (kDebugMode) debugPrint('FCM Token is empty, retrying in 2 seconds...');
        await Future.delayed(const Duration(seconds: 2));
        if (kIsWeb) {
          token = await _fcm.getToken(vapidKey: _vapidKey);
        } else {
          token = await _fcm.getToken();
        }
      }

      if (kDebugMode) {
        if (token != null) {
          debugPrint('FCM SUCCESS! Token: $token');
        } else {
          debugPrint('FCM FAILURE: Could not retrieve token.');
        }
      }
      
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
      }
      return token;
    } catch (e) {
      if (kDebugMode) debugPrint('FCM ERROR getting token: $e');
      return null;
    }
  }

  /// Parses the payload and navigates to the specific incident details
  static void _handleNotificationClick(Map<String, dynamic> data) {
    if (kDebugMode) debugPrint('Handling Notification Click with Data: $data');

    // Attempt to extract the incident ID using multiple possible keys
    final String? incidentIdStr = data['current_incident_id']?.toString() ??
        data['incident_id']?.toString() ??
        data['id']?.toString();

    if (incidentIdStr != null) {
      try {
        final cubit = getIt<IncidentMapCubit>();
        final incident = cubit.incidentss.firstWhereOrNull(
          (i) => i.currentIncidentId.toString() == incidentIdStr,
        );

        if (incident != null) {
          if (kDebugMode) debugPrint('Incident found! Opening details for: $incidentIdStr');
          // This will center the map on the incident and open the details panel
          getIt<IncidentPickerBridge>().requestSelect(incident);
        } else {
          if (kDebugMode) debugPrint('Incident ID $incidentIdStr not found in current map cubit data.');
          // Optionally, fetch the incident from the API if it's not in the list
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error while routing to incident: $e');
      }
    } else {
      if (kDebugMode) debugPrint('No valid incident ID found in notification data.');
    }
  }
}

/// Must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) debugPrint('Handling a background message: ${message.messageId}');
  
  final title = message.notification?.title ?? "إشعار جديد";
  final body = message.notification?.body ?? "";
  
  if (title.contains('أزمة') || body.contains('أزمة') || 
      title.contains('بلاغ') || title.contains('جديد')) {
    try {
      final alarmService = AlarmService();
      await alarmService.playAlarmForDuration(const Duration(seconds: 10));
    } catch (e) {
      if (kDebugMode) debugPrint('Could not play background alarm: $e');
    }
  }
}
