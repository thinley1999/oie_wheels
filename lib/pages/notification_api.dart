import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationApi{
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future _notificationDetails() async{
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'channel id 2',
          'channel name',
          channelDescription: 'channel description',
          // importance: Importance.max
      ),
      iOS: IOSNotificationDetails()
    );
  }

  static Future init({bool initSchedule = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    //when app is closed
    final details = await _notifications.getNotificationAppLaunchDetails();
    if(details != null && details.didNotificationLaunchApp){
      onNotification.add(details.payload);
    }

    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async{
        onNotification.add(payload);
      }
    );
    if(initSchedule){
      tz.initializeTimeZones();
    }
  }

  static Future showNotification({
    int id = 0,
    String ? title,
    String ? body,
    String ? payload,
  }) async => _notifications.show(
      id,
      title,
      body,
      await _notificationDetails(),
      payload: payload,
  );

  static Future showScheduleNotification({
    int id = 0,
    String ? title,
    String ? body,
    String ? payload,
    required DateTime scheduledDate,
  }) async => _notifications.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledDate, tz.local),
    await _notificationDetails(),
    payload: payload,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
  );
}