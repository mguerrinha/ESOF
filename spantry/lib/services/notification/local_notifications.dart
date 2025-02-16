import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:spantry/model/product.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }

  static Future init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>null);
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
        defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  Future<int> scheduleNotification(Product product) async {
    tz.initializeTimeZones();
    if (product.dateTime == null) throw Exception('DateTime is not set for the product.');

    final now = DateTime.now();
    final difference = product.dateTime!.difference(now);
    tz.TZDateTime scheduleTime;

    if (difference < Duration(days: 2)) {
      scheduleTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    }
    else {
      scheduleTime = tz.TZDateTime.from(
          product.dateTime!.subtract(Duration(days: 2)), tz.local);
    }
    return showScheduleNotification(
      title: "The ${product.name} is almost expired",
      description: "The ${product.name} will expired in less than 2 days",
      payload: "this is simple data",
      scheduleTime: scheduleTime
    );
  }

  Future<int> showScheduleNotification({
    required String title,
    required String description,
    required String payload,
    required tz.TZDateTime scheduleTime,
  }) async {
    tz.initializeTimeZones();
    int notificationId = UniqueKey().hashCode;
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        description,
        scheduleTime,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker'
            )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime, payload: payload);
    return notificationId;
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}