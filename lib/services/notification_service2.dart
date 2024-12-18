import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final _notification = FlutterLocalNotificationsPlugin();

  static init() async {
    await _notification.initialize(const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ));
    tz.initializeTimeZones();
  }

  scheduleNotification(
    int id,
    String time,
    String body,
  ) async {
    List<String> timeParts = time.split('h');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print('Current timezone: $currentTimeZone');
    final scheduledDate = _nextInstanceOfTime(hour, minute, currentTimeZone);

    var androidDetails = const AndroidNotificationDetails(
      "important_notification",
      "My Channel",
      importance: Importance.max,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    await _notification.zonedSchedule(
      0,
      "Mirror Hours",
      body,
      scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print('Scheduled notification with id $id');
  }

  static cancelNotifications(int id) async {
    print('Cancelling notification with id: $id');
    await _notification.cancel(id);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, String timeZone) {
    print("hour: $hour, minute: $minute, tz: ${tz.local}");

    tz.Location loc = tz.getLocation(timeZone);

    final tz.TZDateTime now = tz.TZDateTime.now(loc);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      loc,
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
    print('Scheduled time: $scheduledDate ,${tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10))}');

    return scheduledDate;
  }
}
