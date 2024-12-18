import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> initNotification() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // InitializationSettings for both platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // Handle notification tap
      },
    );

    // Create the notification channel
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'mirror_hours_channel',
      'Mirror Hours',
      description: 'Mirror Hours Notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleNotification(int id, String time, String message) async {
    try {
      // Check notification permissions
      final permissionStatusExactAlarm = await notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      final permissionStatusNotification = await notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final permissionStatusFullIntent = await notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestFullScreenIntentPermission();

      if (permissionStatusFullIntent != true) {
        print(' Full permission denied');
        return;
      }
      if (permissionStatusExactAlarm != true) {
        print("Exact Alarm permission denied");
      }

      if (permissionStatusNotification != true) {
        print(" Notification permission denied");
        return;
      }

      List<String> timeParts = time.split('h');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      final scheduledsDate = _nextInstanceOfTime(hour, minute);

      // Debug: Print current time and scheduled time
      final now = tz.TZDateTime.now(tz.local);
      print('Current time: $now');

      // For testing: Schedule notification for 10 seconds from now

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'mirror_hours_channel', 'Mirror Hours',
          channelDescription: 'Mirror Hours Notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.reminder);
      NotificationDetails notificationDetails = const NotificationDetails(
        android: androidDetails,
      );

      // For testing: Use testDate instead of scheduledDate
      await notificationsPlugin.zonedSchedule(
        id,
        'Mirror Hour',
        message,
        scheduledsDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Debug: Check pending notifications
      final List<PendingNotificationRequest> pendingNotifications =
          await notificationsPlugin.pendingNotificationRequests();
      print('Pending notifications: ${pendingNotifications.length}');
      for (var notification in pendingNotifications) {
        print('Pending notification: ID=${notification.id}, Title=${notification.title}');
      }
    } catch (e, stackTrace) {
      print('Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to schedule notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mirror_hours_channel',
      'Mirror Hours',
      channelDescription: 'Mirror Hours Notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification',
      notificationDetails,
    );
  }
}
