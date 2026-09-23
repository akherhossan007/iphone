import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../../firebase_options.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late final FirebaseMessaging _fcm;
  late final FlutterLocalNotificationsPlugin _localNotifications;

  GlobalKey<NavigatorState>? _navKey;
  GlobalKey<NavigatorState>? get navKey => _navKey;
  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  final ValueNotifier<List<AppNotification>> notificationsNotifier = ValueNotifier<List<AppNotification>>([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  static const String _storageKey = 'gb_push_notifications_history';
  static const String _tokenStorageKey = 'gb_fcm_device_token';

  Future<void> initialize({GlobalKey<NavigatorState>? navKey}) async {
    _navKey = navKey;
    await _loadSavedNotifications();
    if (kIsWeb) return;

    _fcm = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();

    // 1. Request Runtime Permission (Android 13+ / iOS)
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('FCM Permission Request error: $e');
    }

    // 2. Setup Local Notifications Settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClick(response.payload);
      },
    );

    // 3. Android High-Importance Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'glowbay_high_importance_channel',
      'GlowBay Priority Notifications',
      description: 'Used for order tracking updates, parcel deliveries and flash sales.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Background Message Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Retrieve & Cache FCM Device Token
    try {
      _deviceToken = await _fcm.getToken();
      if (_deviceToken != null) {
        debugPrint('====================================');
        debugPrint('GLOWBAY FCM DEVICE TOKEN:');
        debugPrint(_deviceToken);
        debugPrint('====================================');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenStorageKey, _deviceToken!);
        // Register token with backend API
        ApiService().registerDeviceToken(token: _deviceToken!);
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        _deviceToken = newToken;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenStorageKey, newToken);
        ApiService().registerDeviceToken(token: newToken);
        debugPrint('FCM Token Refreshed: $newToken');
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // 6. Foreground Notification Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;
      final title = notification?.title ?? message.data['title'] ?? 'GlowBay Update';
      final body = notification?.body ?? message.data['body'] ?? '';

      // Add to internal history
      addNotification(
        title: title,
        body: body,
        type: message.data['type'] ?? 'promo',
        data: message.data,
      );

      if (notification != null || android != null || body.isNotEmpty) {
        _localNotifications.show(
          id: message.hashCode,
          title: title,
          body: body,
          payload: jsonEncode(message.data),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });

    // 7. Clicked Notification from Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(jsonEncode(message.data));
    });

    // 8. Clicked Notification from Terminated State
    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(jsonEncode(initialMessage.data));
      }
    } catch (_) {}

    // 9. Subscribe to Standard Broadcast Topics
    try {
      await _fcm.subscribeToTopic('all_users');
      await _fcm.subscribeToTopic('flash_deals');
      await _fcm.subscribeToTopic('order_updates');
    } catch (e) {
      debugPrint('FCM Subscribe Topics error: $e');
    }
  }

  void _handleNotificationClick(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      debugPrint('Notification payload clicked: $data');
      // e.g. navigate if route specified
    } catch (e) {
      debugPrint('Error handling notification click: $e');
    }
  }

  Future<void> addNotification({
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    final newNotif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
      data: data,
    );

    final updated = [newNotif, ...notificationsNotifier.value];
    notificationsNotifier.value = updated;
    _updateUnreadCount();
    await _saveNotifications();
  }

  Future<void> markAsRead(String id) async {
    final updated = notificationsNotifier.value.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    notificationsNotifier.value = updated;
    _updateUnreadCount();
    await _saveNotifications();
  }

  Future<void> markAllAsRead() async {
    final updated = notificationsNotifier.value.map((n) => n.copyWith(isRead: true)).toList();
    notificationsNotifier.value = updated;
    _updateUnreadCount();
    await _saveNotifications();
  }

  Future<void> clearAll() async {
    notificationsNotifier.value = [];
    _updateUnreadCount();
    await _saveNotifications();
  }

  void _updateUnreadCount() {
    unreadCountNotifier.value = notificationsNotifier.value.where((n) => !n.isRead).length;
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = notificationsNotifier.value.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(listJson));
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> _loadSavedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        final list = decoded.map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item))).toList();
        notificationsNotifier.value = list;
        _updateUnreadCount();
      } else {
        // Provide initial welcome notifications
        notificationsNotifier.value = [
          AppNotification(
            id: 'welcome_1',
            title: 'Welcome to GlowBay BD! ✨',
            body: 'Discover 100% authentic Malaysian & Asian skincare directly imported and verified.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: false,
            type: 'general',
          ),
          AppNotification(
            id: 'welcome_2',
            title: '⚡ Flash Deals Live Now',
            body: 'Check out today\'s flash deals on authentic serums, cleansers, and sunscreens.',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            isRead: false,
            type: 'promo',
          ),
        ];
        _updateUnreadCount();
        await _saveNotifications();
      }
    } catch (e) {
      debugPrint('Error loading saved notifications: $e');
    }
  }

  /// Manually trigger a test notification (useful for instant verification)
  Future<void> showTestNotification({
    String title = 'GlowBay Test Notification 🔔',
    String body = 'Push notification system is working perfectly on this device!',
  }) async {
    if (kIsWeb) {
      await addNotification(title: title, body: body, type: 'general');
      return;
    }
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'glowbay_high_importance_channel',
      'GlowBay Priority Notifications',
      channelDescription: 'Used for order tracking updates, parcel deliveries and flash sales.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: jsonEncode({'type': 'test'}),
      notificationDetails: platformChannelSpecifics,
    );

    await addNotification(
      title: title,
      body: body,
      type: 'general',
    );
  }
}
