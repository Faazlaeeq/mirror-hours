import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _notification.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
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
        print('Cancelled notification: ${notification.id}');
      }

      // Parse the time
      List<String> timeParts = time.split('h');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      final scheduledDate = _nextInstanceOfTime(hour, minute, currentTimeZone);

      var androidDetails = const AndroidNotificationDetails(
        "mirror_hours_channel",
        "Heures Miroirs",
        channelDescription: "Heures Miroirs Notifications",
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      var iOSDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'mirror_hour_$id',
      );

      print('Successfully scheduled notification:');
      print('ID: $id');
      print('Time: $hour:$minute');
      print('Scheduled for: $scheduledDate');
      
      // Verify scheduled notification
      final pending = await _notification.pendingNotificationRequests();
      print('Current pending notifications: ${pending.length}');

    } catch (e, stackTrace) {
      print('Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> cancelNotifications(int id) async {
    try {
      await _notification.cancel(id);
      print('Successfully cancelled notification with ID: $id');
      
      // Verify cancellation
      final pending = await _notification.pendingNotificationRequests();
      print('Remaining pending notifications: ${pending.length}');
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
      print('Scheduled date is before now. Adding one day.');
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('Current time: $now');
    print('Scheduled time: $scheduledDate');

    return scheduledDate;
  }
}