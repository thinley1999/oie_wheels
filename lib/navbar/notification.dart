import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
              onPressed: () =>  Navigator.pop(context),
            ),
            title: Text('Notification', style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0, backgroundColor: Color(0xFF1976D2)
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("OrderHistory")
              .where('uid', isEqualTo: (_auth.currentUser)!.uid)
              .orderBy('dateTime', descending: true)
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
            }
            return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index){
                  var doc = snapshot.data!.docs[index];
                  DateTime formattedDate = DateTime.parse(doc['dateTime']);
                  String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);
                  return SingleChildScrollView(
                    child:   Container(
                      margin: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 0),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3.sp)
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 30.h,
                                width: 30.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE8EAF6),
                                ),
                                child: Icon(FontAwesomeIcons.bell, size: 20.sp, color: Colors.black.withOpacity(0.2))
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                (doc['status'] == 'unassigned orders') ? 'Your order ' + "'${doc['orderId']}'" +  ' is placed.'
                                : (doc['status'] == 'order confirm') ? 'Your order ' + "'${doc['orderId']}'" +  ' is confirm.'
                                : 'Your order ' + "'${doc['orderId']}'" +  ' is ${doc['status']}.',
                                style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              dateTime,
                              style: GoogleFonts.inter(fontSize: 12.sp,),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
            )
            : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.folder, size: 80.sp, color: Colors.amber[900]),
                  Text('No Data Found', style: GoogleFonts.inter(fontSize: 20.sp, color: Colors.amber[900])),
                ],
              ),
            );
          }
      ),
    );
  }
}
