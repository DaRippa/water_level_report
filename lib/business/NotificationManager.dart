import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationManager {
  static NotificationManager _instance = NotificationManager._internal();

  static final String _notificationTitle = "High level at Elbe-Strombrücke";

  final AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails("WaterLevelReportChannel",
          "Water Level Report", "Notification channel for water level report",
          priority: Priority.defaultPriority,
          importance: Importance.high,
          showWhen: false);

  NotificationManager._internal();

  factory NotificationManager() => _instance;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    final AndroidInitializationSettings _androidInitSettings =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings _iosInitSettings =
        IOSInitializationSettings();

    await _notificationsPlugin.initialize(InitializationSettings(
        android: _androidInitSettings, iOS: _iosInitSettings));
  }

  Future<void> sendNotification(
      {required int id, required String message, String? payload}) async {
    await _notificationsPlugin.show(id, _notificationTitle, message,
        NotificationDetails(android: _androidNotificationDetails),
        payload: payload);
  }

  Future<void> scheduleNotification(
      {required int id,
      required String message,
      required DateTime notificationTime,
      Object? payload}) async {
    String timezoneName = await FlutterNativeTimezone.getLocalTimezone();

    TZDateTime time =
        TZDateTime.from(notificationTime, getLocation(timezoneName));

    await _notificationsPlugin.zonedSchedule(id, _notificationTitle, message,
        time, NotificationDetails(android: _androidNotificationDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
