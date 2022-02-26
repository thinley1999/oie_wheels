import 'dart:async';
import 'package:carousel_nullsafety/carousel_nullsafety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/content/main_restaurant.dart';
import 'package:oie_wheels/content/main_shop.dart';
import 'package:location/location.dart' as loc;
import 'package:oie_wheels/pages/main_drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  Timer ? timer;

  @override
  void initState() {
    super.initState();
    initializeSetting();
    tz.initializeTimeZones();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      FirebaseFirestore.instance
          .collection("OrderHistory")
          .where('uid', isEqualTo: (_auth.currentUser)!.uid)
          .where('cancel', isEqualTo: false)
          .where('status', whereIn: ['unassigned orders','order confirm','being prepared', 'on the way', 'delivered'])
          .get()
          .then((value) {
        value.docs.forEach((result) {
          displayNotification(
              null,
              (result.data()['status'] == 'unassigned orders') ? 'Your order "${result.data()['orderId']}" is placed.'
                  : (result.data()['status'] == 'order confirm') ? 'Your order "${result.data()['orderId']}" is confirmed.'
                  : 'Your order "${result.data()['orderId']}" is ${result.data()['status']}.',
              DateTime.now().add(Duration(seconds: 5))
          ).then((value) => {
            FirebaseFirestore.instance.collection('OrderHistory').doc(result.data()['orderId']).update({
              'cancel': true,
            })
          });
        });
      });
    });
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
    _listenLocation();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  List<NetworkImage> _listOfImages = <NetworkImage>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(FontAwesomeIcons.bars, size: 20.sp,),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text('Welcome to OieWheel', style: GoogleFonts.inter(
              fontSize: 15.sp, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottomOpacity: 0.0,
          elevation: 0.0,
          backgroundColor: Color(0xFF1976D2),
        ),
      ),
      drawer: MainDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 200.h,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Banner').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _listOfImages = [];
                  for(int i =0; i<snapshot.data!.docs.length; i++){
                    _listOfImages.add(NetworkImage(snapshot.data!.docs[i]['imageUrl']));
                  }
                  return Carousel(
                    boxFit: BoxFit.cover,
                    dotBgColor: Colors.transparent,
                    dotSpacing: 18.w,
                    dotIncreasedColor: Colors.grey,
                    dotSize: 6.sp,
                    autoplayDuration: Duration(seconds: 2),
                    images: _listOfImages,
                  );
                } else {
                  return Center(
                    child: SpinKitWave(
                      size: 30.sp,
                      color: Colors.amber[900],
                      duration:  Duration(milliseconds: 800),
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
                width: 400.w,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.8,
                  children: <Widget>[
                    Card(
                      elevation: 5,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                          ),
                          Ink.image(
                            image: AssetImage(
                          'assets/restaurant.jpg',
                      ),
                            child: InkWell(
                              onTap: () async{
                                _listenLocation();
                                OverlayState? overlayState = Overlay.of(context);
                                OverlayEntry overlayEntry = OverlayEntry(
                                    builder: (context) => Align(
                                      alignment: Alignment.center,
                                      child: SpinKitWave(
                                        size: 30.sp,
                                        color: Colors.amber[900],
                                      ),
                                    ));
                                overlayState!.insert(overlayEntry);
                                await Future.delayed(Duration(seconds: 1)).then((value) {
                                  overlayEntry.remove();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MainRestaurant()));
                                });
                              },
                            ),
                            fit: BoxFit.cover,
                          ),
                          Text(
                            'Restaurant',
                            style: GoogleFonts.cinzelDecorative(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 5,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                          ),
                          Ink.image(
                            image: AssetImage(
                                'assets/shop.jpg'
                            ),
                            child: InkWell(
                              onTap: () async{
                                _listenLocation();
                                OverlayState? overlayState = Overlay.of(context);
                                OverlayEntry overlayEntry = OverlayEntry(
                                    builder: (context) => Align(
                                      alignment: Alignment.center,
                                      child: SpinKitWave(
                                        size: 30.sp,
                                        color: Colors.amber[900],
                                      ),
                                    ));
                                overlayState!.insert(overlayEntry);
                                await Future.delayed(Duration(seconds: 1)).then((value) {
                                  overlayEntry.remove();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MainShop()));
                                });
                              },
                            ),
                            fit: BoxFit.cover,
                          ),
                          Text(
                            'Shop',
                            style: GoogleFonts.cinzelDecorative(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Future<void> displayNotification(String ? title, String ? body, DateTime dateTime) async {
    notificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
              'channel id', 'channel name', channelDescription: 'channel description'),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('Users').doc((_auth.currentUser)!.uid).update({
        'lat': currentlocation.latitude,
        'lon': currentlocation.longitude,
      });
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}

void initializeSetting() async{
  final android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final iOS = IOSInitializationSettings();
  final settings = InitializationSettings(android: android, iOS: iOS);
  await notificationsPlugin.initialize(settings);
}


