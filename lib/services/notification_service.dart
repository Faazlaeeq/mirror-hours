import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const channel = AndroidNotificationChannel(
      'mirror_hours_channel',
      'Heures Miroirs',
      description: 'Heures Miroirs Notifications',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    await _notification
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _notification.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      ),
    );

    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification(
    int id,
    String time,
    String body,
  ) async {
    try {
      // Cancel all existing notifications first
      final pendingNotifications = await _notification.pendingNotificationRequests();
      for (var notification in pendingNotifications) {
        await _notification.cancel(notification.id);
      }

      List<String> timeParts = time.split('h');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      final scheduledDate = _nextInstanceOfTime(hour, minute, currentTimeZone);

      var androidDetails = const AndroidNotificationDetails(
        'mirror_hours_channel',
        'Heures Miroirs',
        channelDescription: 'Heures Miroirs Notifications',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
        ongoing: true,
        autoCancel: false,
      );

      var iOSDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      var notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notification.zonedSchedule(
        id,
        "Heures Miroirs",
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  static Future<void> cancelNotifications(int id) async {
    try {
      await _notification.cancel(id);
    } catch (e) {
      print('Error cancelling notification: $e');
      rethrow;
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, String timeZone) {
    final tz.Location location = tz.getLocation(timeZone);
    final tz.TZDateTime now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
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
}