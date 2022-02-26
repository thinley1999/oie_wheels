import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/shop/order_managenet.dart';

class MainOrderManagement extends StatefulWidget {
  @override
  _MainOrderManagementState createState() => _MainOrderManagementState();
}

class _MainOrderManagementState extends State<MainOrderManagement> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFFE8EAF6),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.h),
          child: AppBar(
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Order Management', style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0,
            backgroundColor: Color(0xFF1976D2),
          ),
        ),
        body: Column(
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
                    Tab(child: Text('Open', style: GoogleFonts.inter(fontSize: 13.sp)),),
                    Tab(child: Text('Current', style: GoogleFonts.inter(fontSize: 13.sp)),),
                    Tab(child: Text('Past Orders', style: GoogleFonts.inter(fontSize: 13.sp))),
                  ]
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                child: TabBarView(
                    children: [
                          Open(),
                          Current(),
                          PastOrder()
                    ]
                ),
              ),
            ),
          ],
        )
        ,
      ),
    );
  }
}

class Open extends StatefulWidget {
  @override
  _OpenState createState() => _OpenState();
}

class _OpenState extends State<Open> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('ShopOwner').doc((_auth.currentUser)!.uid).get().then((value){
      setState(() {
        shopName = value.data()!['shopName'];
      });
    });
  }

  var shopName;
  @override
  Widget build(BuildContext context) {
    return (shopName != null) ? StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('OrderHistory')
          .where('orderFrom', isEqualTo: shopName)
          .where('status', whereIn: ['unassigned orders', 'order received'])
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
                                      padding: EdgeInsets.only(top: 5.h),
                                      child: Text('Order Id:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.h),
                                      child: Text('Order Placed at:', style: GoogleFonts.inter(fontSize: 13.sp)),
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
                                            child: Container(
                                              height: 150.h,
                                              width: MediaQuery.of(context).size.width,
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                                        child: Align(
                                                          alignment: Alignment.topCenter,
                                                          child: Text('Status',
                                                            style: GoogleFonts.inter(
                                                                fontSize: 16.sp,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w800
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      (doc['status'] != 'order received') ? Padding(
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
                                                                    'status': 'order received',
                                                                  });
                                                                });
                                                              });
                                                              FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                                'status': 'order received'
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
                                                              hintText: 'ORDER RECEIVED',
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
                                                      (doc['status'] != 'being prepared') ? Padding(
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
                                                                    'status': 'being prepared',
                                                                  });
                                                                });
                                                              });
                                                              FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                                'status': 'being prepared'
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
                                                              hintText: 'BEING PREPARED',
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
                                                      (doc['status'] != 'order confirm') ? Padding(
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
                                                                    'status': 'order confirm',
                                                                  });
                                                                });
                                                              });
                                                              FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                                'status': 'order confirmed'
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
                                                              hintText: 'ORDER CONFIRM',
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
                                      'uid': doc['uid'],
                                      'dateTime': doc['dateTime'],
                                      'orderId': doc['orderId'],
                                    });
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderManagement()));
                                  },
                                  child: Container(
                                    color: Colors.amber[900],
                                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
                                    child: Text('VIEW DETAILS', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
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

class Current extends StatefulWidget {
  @override
  _CurrentState createState() => _CurrentState();
}

class _CurrentState extends State<Current> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('ShopOwner').doc((_auth.currentUser)!.uid).get().then((value){
      setState(() {
        shopName = value.data()!['shopName'];
      });
    });
  }

  var shopName;
  @override
  Widget build(BuildContext context) {
    return (shopName != null) ? StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('OrderHistory')
          .where('orderFrom', isEqualTo: shopName)
          .where('status', whereIn: ['being prepared', 'order confirm', 'on the way'])
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
                                      padding: EdgeInsets.only(top: 5.h),
                                      child: Text('Order Id:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.h),
                                      child: Text('Order Placed at:', style: GoogleFonts.inter(fontSize: 13.sp)),
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
                                            child: Container(
                                              height: 120.h,
                                              width: MediaQuery.of(context).size.width,
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        child: Align(
                                                          alignment: Alignment.topCenter,
                                                          child: Text('Status',
                                                            style: GoogleFonts.inter(
                                                                fontSize: 16.sp,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w800
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      (doc['status'] != 'on the way') ? Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
                                                                'status': 'on the way'
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
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                                                                'status': 'delivered'
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
                                      'uid': doc['uid'],
                                      'dateTime': doc['dateTime'],
                                      'orderId': doc['orderId'],
                                    });
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderManagement()));
                                  },
                                  child: Container(
                                    color: Colors.amber[900],
                                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
                                    child: Text('VIEW DETAILS', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
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

class PastOrder extends StatefulWidget {
  @override
  _PastOrderState createState() => _PastOrderState();
}

class _PastOrderState extends State<PastOrder> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('ShopOwner').doc((_auth.currentUser)!.uid).get().then((value){
      setState(() {
        shopName = value.data()!['shopName'];
      });
    });
  }

  var shopName;
  @override
  Widget build(BuildContext context) {
    return (shopName != null) ? StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('OrderHistory')
          .where('orderFrom', isEqualTo: shopName)
          .where('status', whereIn: ['delivered', 'paid', 'partially paid'])
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
                                      padding: EdgeInsets.only(top: 5.h),
                                      child: Text('Order Id:', style: GoogleFonts.inter(fontSize: 13.sp)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.h),
                                      child: Text('Order Placed at:', style: GoogleFonts.inter(fontSize: 13.sp)),
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
                                            child: Container(
                                              height: 120.h,
                                              width: MediaQuery.of(context).size.width,
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        child: Align(
                                                          alignment: Alignment.topCenter,
                                                          child: Text('Status',
                                                            style: GoogleFonts.inter(
                                                                fontSize: 16.sp,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w800
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      (doc['status'] != 'partially paid') ? Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
                                                                    'status': 'partially paid',
                                                                  });
                                                                });
                                                              });
                                                              FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                                'status': 'partially paid'
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
                                                              hintText: 'PARTIALLY PAID',
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
                                                      (doc['status'] != 'paid') ? Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                                                                    'status': 'paid',
                                                                  });
                                                                });
                                                              });
                                                              FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                                'status': 'paid'
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
                                                              hintText: 'PAID',
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
                                      'uid': doc['uid'],
                                      'dateTime': doc['dateTime'],
                                      'orderId': doc['orderId'],
                                    });
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderManagement()));
                                  },
                                  child: Container(
                                    color: Colors.amber[900],
                                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
                                    child: Text('VIEW DETAILS', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
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
