import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:oie_wheels/driver/driver_drawer.dart';
import 'package:oie_wheels/driver/order_details.dart';
import 'package:oie_wheels/driver/order_details2.dart';

class DriverHome extends StatefulWidget {
  @override
  _DriverHomeState createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  Timer ? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      _getUserLocation().then((value) {
        if(_userLocation != null) {
          FirebaseFirestore.instance.collection('Driver').doc((_auth.currentUser)!.uid).update({
            'lat': _userLocation!.latitude,
            'lon': _userLocation!.longitude,
          });
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  bool ? _serviceEnabled;
  PermissionStatus ? _permissionGranted;
  LocationData ? _userLocation;

  Future<void> _getUserLocation() async {
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();
    setState(() {
      _userLocation = _locationData;
    });
    if(_userLocation != null){
      FirebaseFirestore.instance.collection('Driver').doc((_auth.currentUser)!.uid).update({
        'lat': _userLocation!.latitude,
        'lon': _userLocation!.longitude,
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            title: Text('Orders', style: GoogleFonts.inter(
                fontSize: 18.sp, fontWeight: FontWeight.w900)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0,
            backgroundColor: Color(0xFF1976D2),
          ),
        ),
        drawer: DriverDrawer(),
        body: DoubleBackToCloseApp(
          snackBar: SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF1976D2),
            content: Text('Press back again to exit', style: GoogleFonts.inter(color: Colors.white, fontSize: 15.sp), textAlign: TextAlign.center),
          ),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: TabBar(
                    isScrollable: false,
                    indicator: BoxDecoration(
                      color: Colors.black,
                    ),
                    indicatorWeight: 0,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: GoogleFonts.inter(fontSize: 13.sp),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 13.sp),
                    tabs: [
                      Tab(child: Text('Open Orders', style: GoogleFonts.inter(fontSize: 15.sp)),),
                      Tab(child: Text('Past Orders', style: GoogleFonts.inter(fontSize: 15.sp))),
                    ]
                ),
              ),
              Flexible(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.w),
                  child: TabBarView(
                      children: [
                        OpenOrders(),
                        PastOrders(),
                      ]
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class OpenOrders extends StatefulWidget {
  @override
  _OpenOrdersState createState() => _OpenOrdersState();
}

class _OpenOrdersState extends State<OpenOrders> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  TextEditingController _amountController = TextEditingController();
  TextEditingController _receivedFromCustomerController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('Driver').doc((_auth.currentUser)!.uid).get().then((value){
      setState(() {
        driverName = value.data()!['fullName'];
      });
    });
  }

  var driverName;
  @override
  Widget build(BuildContext context) {
    return (driverName != null) ? SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('OrderHistory')
            .where('driver', isEqualTo: driverName)
            .where('status', whereIn: ['unassigned orders','order confirm','being prepared', 'on the way'])
            .orderBy('orderId', descending: true)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: Center(
                child: SpinKitWave(
                  size: 30.sp,
                  color: Colors.amber[900],
                  duration:  Duration(milliseconds: 800),
                ),
              ),
            );
          } else {
            return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  DateTime formattedDate = DateTime.parse(doc['dateTime']);
                  String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);
                  String dateTime2 = DateFormat.jm().format(formattedDate);
                  final pickUp = formattedDate.add(Duration(minutes: 30));
                  String dateTime3 = DateFormat.jm().format(pickUp);

                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey)
                            )
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.clock, size: 18.sp, color: Colors.grey),
                              SizedBox(width: 10.w),
                              Text(dateTime, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.h),
                                        child: Text('Order Id:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.h),
                                        child: Text('Order Placed at:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.h),
                                        child: Text('Pick-up ETA:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.h),
                                        child: Text('Order Status:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 50.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.h),
                                        child: Text(doc['orderId'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.h),
                                        child: Text(dateTime2, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.h),
                                        child: Text(dateTime3, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.h),
                                        child: Text(doc['status'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.green, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: SizedBox(
                                                height: 110.h,
                                                width: MediaQuery.of(context).size.width,
                                                child: Form(
                                                  key: _formKey,
                                                  child: Stack(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(vertical: 5.h),
                                                            child: Text('Status',
                                                              style: GoogleFonts.inter(
                                                                  fontSize: 16.sp,
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w800
                                                              ),
                                                            ),
                                                          ),
                                                          (doc['status'] != 'on the way') ? Padding(
                                                            padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 5.h),
                                                            child: SizedBox(
                                                              height: 30.h,
                                                              child: TextFormField(
                                                                onTap: () {
                                                                  FirebaseFirestore.instance
                                                                      .collection("Order")
                                                                      .doc(doc['uid'])
                                                                      .collection("ConfirmOrder")
                                                                      .where('dateTime', isEqualTo: doc['dateTime'])
                                                                      .get()
                                                                      .then((value) {
                                                                    value.docs.forEach((result) {
                                                                      FirebaseFirestore.instance
                                                                          .collection('Order')
                                                                          .doc(result.data()['uid'])
                                                                          .collection('ConfirmOrder')
                                                                          .doc(result.data()['oId'])
                                                                          .update({
                                                                        'status': 'on the way',
                                                                      });
                                                                    });
                                                                  });
                                                                  FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                                    'status': 'on the way',
                                                                    'cancel': false,
                                                                  }).then((value) {
                                                                    Navigator.pop(context);
                                                                    Fluttertoast.showToast(
                                                                        msg: 'Update status success!!!',
                                                                        gravity: ToastGravity.CENTER,
                                                                        timeInSecForIosWeb: 1,
                                                                        backgroundColor: Colors.red,
                                                                        textColor: Colors.white,
                                                                        fontSize: 13.sp
                                                                    );
                                                                  });
                                                                },
                                                                readOnly: true,
                                                                style: GoogleFonts.inter(fontSize: 13.sp),
                                                                textAlign: TextAlign.start,
                                                                decoration: InputDecoration(
                                                                  hintText: 'ON THE ROAD',
                                                                  hintStyle: GoogleFonts.inter(fontSize: 13.sp),
                                                                  contentPadding: EdgeInsets.only(left: 10.w),
                                                                  border: OutlineInputBorder(
                                                                    borderSide: BorderSide(color: Colors.grey),
                                                                    borderRadius: BorderRadius.circular(2.sp),
                                                                  ),
                                                                  errorBorder: OutlineInputBorder(
                                                                    borderSide: BorderSide(color: Colors.red),
                                                                    borderRadius: BorderRadius.circular(0),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          : SizedBox(),
                                                          (doc['status'] != 'delivered') ? Padding(
                                                            padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 5.h),
                                                            child: SizedBox(
                                                              height: 30.h,
                                                              child: TextFormField(
                                                                onTap: () {
                                                                  FirebaseFirestore.instance
                                                                      .collection("Order")
                                                                      .doc(doc['uid'])
                                                                      .collection("ConfirmOrder")
                                                                      .where('dateTime', isEqualTo: doc['dateTime'])
                                                                      .get()
                                                                      .then((value) {
                                                                    value.docs.forEach((result) {
                                                                      FirebaseFirestore.instance
                                                                          .collection('Order')
                                                                          .doc(result.data()['uid'])
                                                                          .collection('ConfirmOrder')
                                                                          .doc(result.data()['oId'])
                                                                          .update({
                                                                        'status': 'delivered',
                                                                      });
                                                                    });
                                                                  });
                                                                  FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                                    'status': 'delivered',
                                                                    'cancel': false,
                                                                  }).then((value) {
                                                                    Navigator.pop(context);
                                                                    Fluttertoast.showToast(
                                                                        msg: 'Update status success!!!',
                                                                        gravity: ToastGravity.CENTER,
                                                                        timeInSecForIosWeb: 1,
                                                                        backgroundColor: Colors.red,
                                                                        textColor: Colors.white,
                                                                        fontSize: 13.sp
                                                                    );
                                                                  });
                                                                },
                                                                readOnly: true,
                                                                style: GoogleFonts.inter(fontSize: 13.sp),
                                                                textAlign: TextAlign.start,
                                                                decoration: InputDecoration(
                                                                  hintText: 'DELIVERED',
                                                                  hintStyle: GoogleFonts.inter(fontSize: 13.sp),
                                                                  contentPadding: EdgeInsets.only(left: 10.w),
                                                                  border: OutlineInputBorder(
                                                                    borderSide: BorderSide(color: Colors.grey),
                                                                    borderRadius: BorderRadius.circular(2.sp),
                                                                  ),
                                                                  errorBorder: OutlineInputBorder(
                                                                    borderSide: BorderSide(color: Colors.red),
                                                                    borderRadius: BorderRadius.circular(0),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          : SizedBox(),
                                                        ],
                                                      ),
                                                      Positioned(
                                                        right: 0,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          icon: Icon(Icons.clear, size: 25.sp,),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                      );
                                    },
                                    child: Container(
                                      color: Colors.green[900],
                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                                      child: Text('CHANGE STATUS', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      FirebaseFirestore.instance.collection('EditItem').doc((_auth.currentUser)!.uid).collection('StoreItem').doc((_auth.currentUser)!.uid).set({
                                        'orderId': doc['orderId'],
                                        'dateTime': doc['dateTime'],
                                        'uid': doc['uid'],
                                      });
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetails()));
                                    },
                                    child: Container(
                                      color: Colors.black,
                                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
                                      child: Text('VIEW DETAILS', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              (doc['paymentType'] == 'Cash on Delivery') ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: SizedBox(
                                            height: 150.h,
                                            width: MediaQuery.of(context).size.width,
                                            child: Form(
                                              key: _formKey,
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        child: Text('Amount Received from Customer',
                                                          style: GoogleFonts.inter(
                                                              fontSize: 16.sp,
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w800
                                                          ),
                                                        ),
                                                      ),
                                                      Text('Please Type Amount', style: GoogleFonts.inter(fontSize: 13.sp)),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                        child: TextFormField(
                                                          style: GoogleFonts.inter(fontSize: 13.sp),
                                                          textAlign: TextAlign.start,
                                                          controller: _receivedFromCustomerController,
                                                          keyboardType: TextInputType.number,
                                                          decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.only(left: 10.w),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                            errorBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.red),
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                          ),
                                                          validator: (String ? value) {
                                                            if(value!.isEmpty) {
                                                              return 'please enter amount received from customer';
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          if(_formKey.currentState!.validate()) {
                                                            _formKey.currentState!.save();
                                                            FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                              'received from customer': int.parse(_receivedFromCustomerController.text),
                                                            }).then((value) {
                                                              Navigator.pop(context);
                                                              Fluttertoast.showToast(
                                                                  msg: 'Amount received from customer success!!!',
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 13.sp
                                                              );
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          color: Color(0xFF1976D2),
                                                          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                                                          child: Text('SUBMIT', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(Icons.clear, size: 25.sp,),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xFF1976D2),
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Text('AMOUNT RECEIVED FROM CUSTOMER', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                                ),
                              )
                                  : SizedBox(),
                              SizedBox(height: 5.h),
                              (doc['paymentType'] == 'Cash on Delivery') ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: SizedBox(
                                            height: 150.h,
                                            width: MediaQuery.of(context).size.width,
                                            child: Form(
                                              key: _formKey,
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        child: Text((doc['from'] == 'restaurant') ? 'Amount Paid To Restaurant' : 'Amount Paid To Shop',
                                                          style: GoogleFonts.inter(
                                                              fontSize: 16.sp,
                                                              color: Colors.black,
                                                            fontWeight: FontWeight.w800
                                                          ),
                                                        ),
                                                      ),
                                                      Text('Please Type Amount', style: GoogleFonts.inter(fontSize: 13.sp)),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                        child: TextFormField(
                                                          style: GoogleFonts.inter(fontSize: 13.sp),
                                                          textAlign: TextAlign.start,
                                                          controller: _amountController,
                                                          keyboardType: TextInputType.number,
                                                          decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.only(left: 10.w),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                            errorBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.red),
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                          ),
                                                          validator: (String ? value) {
                                                            if(value!.isEmpty) {
                                                              return 'please enter amount';
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          if(_formKey.currentState!.validate()) {
                                                            _formKey.currentState!.save();
                                                            FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                              'paid to ros': int.parse(_amountController.text),
                                                              'paymentStatus': 'paid'
                                                            }).then((value) {
                                                              Navigator.pop(context);
                                                              Fluttertoast.showToast(
                                                                  msg: (doc['from'] == 'restaurant') ? 'Amount paid to restaurant success!!!' : 'Amount paid to shop success!!!',
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 13.sp
                                                              );
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          color: Color(0xFF1976D2),
                                                          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                                                          child: Text('SUBMIT', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(Icons.clear, size: 25.sp,),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.amber[900],
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Text((doc['from'] == 'restaurant') ? 'AMOUNT PAID TO RESTAURANT' : 'AMOUNT PAID TO SHOP', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                                ),
                              )
                              : SizedBox(),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.folder, size: 80.sp, color: Colors.amber[900]),
                Text('No Data Found', style: GoogleFonts.inter(fontSize: 20.sp, color: Colors.amber[900])),
              ],
            );
          }
        },
      ),
    )
        : SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: Center(
        child: SpinKitWave(
          size: 30.sp,
          color: Colors.amber[900],
          duration:  Duration(milliseconds: 800),
        ),
      ),
    );
  }
}

class PastOrders extends StatefulWidget {
  @override
  _PastOrdersState createState() => _PastOrdersState();
}

class _PastOrdersState extends State<PastOrders> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('Driver').doc((_auth.currentUser)!.uid).get().then((value){
      setState(() {
        driverName = value.data()!['fullName'];
      });
    });
  }
  var driverName;

  TextEditingController _receivedFromCustomerController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return (driverName != null) ? SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('OrderHistory')
            .where('driver', isEqualTo: driverName)
            .where('status', isEqualTo: 'delivered')
            .orderBy('orderId', descending: true)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: Center(
                child: SpinKitWave(
                  size: 30.sp,
                  color: Colors.amber[900],
                  duration:  Duration(milliseconds: 800),
                ),
              ),
            );
          } else {
            return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  DateTime formattedDate = DateTime.parse(doc['dateTime']);
                  String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);
                  String dateTime2 = DateFormat.jm().format(formattedDate);

                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey)
                              )
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.clock, size: 18.sp, color: Colors.grey),
                              SizedBox(width: 10.w),
                              Text(dateTime, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text('Order Id:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text('Order Placed at:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text('Delivered At:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text('Paid To Restaurant:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text('Received To Customer:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text('Order Status:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 20.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text(doc['orderId'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text(dateTime2, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text(dateTime2, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text('BTN ' + doc['paid to ros'].toString() + '.00', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text('BTN ' + doc['received from customer'].toString() + '.00', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Text(doc['status'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.green, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              GestureDetector(
                                onTap: () {
                                  FirebaseFirestore.instance.collection('EditItem').doc((_auth.currentUser)!.uid).collection('StoreItem').doc((_auth.currentUser)!.uid).set({
                                    'orderId': doc['orderId'],
                                    'dateTime': doc['dateTime'],
                                    'uid': doc['uid'],
                                  });
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetails2()));
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Text('VIEW DETAILS', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              (doc['paymentType'] == 'Cash on Delivery') ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: SizedBox(
                                            height: 150.h,
                                            width: MediaQuery.of(context).size.width,
                                            child: Form(
                                              key: _formKey,
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        child: Text('Amount Received from Customer',
                                                          style: GoogleFonts.inter(
                                                              fontSize: 16.sp,
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w800
                                                          ),
                                                        ),
                                                      ),
                                                      Text('Please Type Amount', style: GoogleFonts.inter(fontSize: 13.sp)),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                        child: TextFormField(
                                                          style: GoogleFonts.inter(fontSize: 13.sp),
                                                          textAlign: TextAlign.start,
                                                          controller: _receivedFromCustomerController,
                                                          keyboardType: TextInputType.number,
                                                          decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.only(left: 10.w),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                            errorBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.red),
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                          ),
                                                          validator: (String ? value) {
                                                            if(value!.isEmpty) {
                                                              return 'please enter amount received from customer';
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          if(_formKey.currentState!.validate()) {
                                                            _formKey.currentState!.save();
                                                            FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                              'received from customer': int.parse(_receivedFromCustomerController.text),
                                                            }).then((value) {
                                                              Navigator.pop(context);
                                                              Fluttertoast.showToast(
                                                                  msg: 'Amount received from customer success!!!',
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 13.sp
                                                              );
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          color: Color(0xFF1976D2),
                                                          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                                                          child: Text('SUBMIT', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(Icons.clear, size: 25.sp,),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xFF1976D2),
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Text('AMOUNT RECEIVED FROM CUSTOMER', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                                ),
                              )
                                  : SizedBox(),
                              SizedBox(height: 5.h),
                              (doc['paymentType'] == 'Cash on Delivery') ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: SizedBox(
                                            height: 150.h,
                                            width: MediaQuery.of(context).size.width,
                                            child: Form(
                                              key: _formKey,
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        child: Text((doc['from'] == 'restaurant') ? 'Amount Paid To Restaurant' : 'Amount Paid To Shop',
                                                          style: GoogleFonts.inter(
                                                              fontSize: 16.sp,
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w800
                                                          ),
                                                        ),
                                                      ),
                                                      Text('Please Type Amount', style: GoogleFonts.inter(fontSize: 13.sp)),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                        child: TextFormField(
                                                          style: GoogleFonts.inter(fontSize: 13.sp),
                                                          textAlign: TextAlign.start,
                                                          controller: _amountController,
                                                          keyboardType: TextInputType.number,
                                                          decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.only(left: 10.w),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                            errorBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.red),
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                          ),
                                                          validator: (String ? value) {
                                                            if(value!.isEmpty) {
                                                              return 'please enter amount';
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          if(_formKey.currentState!.validate()) {
                                                            _formKey.currentState!.save();
                                                            FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                              'paid to ros': int.parse(_amountController.text),
                                                              'paymentStatus': 'paid'
                                                            }).then((value) {
                                                              Navigator.pop(context);
                                                              Fluttertoast.showToast(
                                                                  msg: (doc['from'] == 'restaurant') ? 'Amount paid to restaurant success!!!' : 'Amount paid to shop success!!!',
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 13.sp
                                                              );
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          color: Color(0xFF1976D2),
                                                          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                                                          child: Text('SUBMIT', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(Icons.clear, size: 25.sp,),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.amber[900],
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Text((doc['from'] == 'restaurant') ? 'AMOUNT PAID TO RESTAURANT' : 'AMOUNT PAID TO SHOP', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.folder, size: 80.sp, color: Colors.amber[900]),
                Text('No Data Found', style: GoogleFonts.inter(fontSize: 20.sp, color: Colors.amber[900])),
              ],
            );
          }
        },
      ),
    )
        : SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: Center(
        child: SpinKitWave(
          size: 30.sp,
          color: Colors.amber[900],
          duration:  Duration(milliseconds: 800),
        ),
      ),
    );
  }
}

