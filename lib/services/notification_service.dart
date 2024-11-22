import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi')); // Change to your timezone

    // Create the notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'mirror_hours_channel', // id
      'Mirror Hours', // title
      description: 'Mirror Hours Notifications', // description
      importance: Importance.high,
    );

    // Create the channel on the device
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsIOS = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {},
    );
  }

  Future<bool> requestPermission() async {
    final bool? iosResult = await notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final bool? androidResult = await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return iosResult ?? androidResult ?? false;
  }

  Future<void> scheduleNotification(int id, String time, String message) async {
    bool permissionGranted = await requestPermission();
    if (!permissionGranted) {
      throw Exception('Notification permission not granted');
    }

    List<String> timeParts = time.split('h');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mirror_hours_channel', // Use the same channel ID as created in initNotification
      'Mirror Hours',
      channelDescription: 'Mirror Hours Notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      playSound: true,
      channelShowBadge: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    try {
      await notificationsPlugin.zonedSchedule(
        id,
        'Mirror Hour',
        message,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      throw Exception('Failed to schedule notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  scheduleNotificationDirect() async {
    await notificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> printAllScheduledNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await notificationsPlugin.pendingNotificationRequests();
    for (var notification in pendingNotifications) {
      print(
          'ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}, Payload: ${notification.payload} ');
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
}
