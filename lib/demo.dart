import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oie_wheels/content/track_order.dart';
import 'package:oie_wheels/pages/notification_api.dart';

FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();


class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  void initState() {
    super.initState();
    NotificationApi.init(initSchedule: true);
    listenNotifications();
    FirebaseFirestore.instance
        .collection("OrderHistory")
        .where('uid', isEqualTo: (_auth.currentUser)!.uid)
        .where('status', whereIn: ['unassigned orders','order confirm','being prepared', 'on the way', 'delivered'])
        .get()
        .then((value) {
      value.docs.forEach((result) {
        NotificationApi.showScheduleNotification(
            body: (result.data()['status'] == 'unassigned orders') ? 'Your order "${result.data()['orderId']}" is placed.'
            : (result.data()['status'] == 'order confirm') ? 'Your order "${result.data()['orderId']}" is confirmed.'
            : 'Your order "${result.data()['orderId']}" is ${result.data()['status']}.',
            scheduledDate: DateTime.now().add(Duration(seconds: 5))
        );
      });
    });
  }

  void listenNotifications(){
    NotificationApi.onNotification.stream.listen((event) {
      onClickedNotification('Hello');
    });
  }

  void onClickedNotification(String?payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TrackOrder()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
        centerTitle: true,
      ),
      body:   Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NotificationApi.showNotification(
                    title: 'Thinley',
                    body: 'How are you??',
                    payload: 'Hi'
                );
              },
              child: Text('Simple'),
            ),
            ElevatedButton(
              onPressed: () {
                NotificationApi.showScheduleNotification(
                    title: 'Dinner',
                    body: 'Toaday at 6 PM',
                    payload: 'Hi',
                  scheduledDate: DateTime.now().add(Duration(seconds: 5))
                );
              },
              child: Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

