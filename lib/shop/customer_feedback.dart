import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomerFeedback extends StatefulWidget {
  @override
  _CustomerFeedbackState createState() => _CustomerFeedbackState();
}

class _CustomerFeedbackState extends State<CustomerFeedback> {
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
            title: Text('Customer Feedback', style: GoogleFonts.inter(
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
                    Tab(child: Text('All', style: GoogleFonts.inter(fontSize: 13.sp)),),
                    Tab(child: Text('Below 5 star', style: GoogleFonts.inter(fontSize: 13.sp)),),
                    Tab(child: Text('5 star', style: GoogleFonts.inter(fontSize: 13.sp), textAlign: TextAlign.center)),
                  ]
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                child: TabBarView(
                    children: [
                      All(),
                      Below(),
                      Equal(),
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

class All extends StatefulWidget {
  @override
  _AllState createState() => _AllState();
}

class _AllState extends State<All> {
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
          .where('isRated', isEqualTo: true)
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
          return snapshot.data!.docs.isNotEmpty ? SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  DateTime formattedDate = DateTime.parse(doc['dateTime']);
                  String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);
                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Row(
                                  children: [
                                    Text('Rating:', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.indigo[900], fontWeight: FontWeight.w600)),
                                    RatingBar.builder(
                                        itemSize: 20.sp,
                                        unratedColor: Colors.indigo[900],
                                        initialRating: doc['rating'],
                                        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber[700]),
                                        onRatingUpdate: (rating) {
                                        }
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Text('CustomerName: ' + doc['orderBy'], style: GoogleFonts.inter(fontSize: 13.sp)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Text((doc['comment'] != '') ? doc['comment'] : '(No Review)', style: GoogleFonts.inter(fontSize: 13.sp)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
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

class Below extends StatefulWidget {
  @override
  _BelowState createState() => _BelowState();
}

class _BelowState extends State<Below> {
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
          .where('isRated', isEqualTo: true)
          .where('rating', isLessThan: 5)
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
          return snapshot.data!.docs.isNotEmpty ? SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  DateTime formattedDate = DateTime.parse(doc['dateTime']);
                  String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);
                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Row(
                                  children: [
                                    Text('Rating:', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.indigo[900], fontWeight: FontWeight.w600)),
                                    RatingBar.builder(
                                        itemSize: 20.sp,
                                        unratedColor: Colors.indigo[900],
                                        initialRating: doc['rating'],
                                        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber[700]),
                                        onRatingUpdate: (rating) {
                                        }
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Text('CustomerName: ' + doc['orderBy'], style: GoogleFonts.inter(fontSize: 13.sp)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Text((doc['comment'] != '') ? doc['comment'] : '(No Review)', style: GoogleFonts.inter(fontSize: 13.sp)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
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

class Equal extends StatefulWidget {
  @override
  _EqualState createState() => _EqualState();
}

class _EqualState extends State<Equal> {
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
          .where('isRated', isEqualTo: true)
          .where('rating', isEqualTo: 5)
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
          return snapshot.data!.docs.isNotEmpty ? SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  DateTime formattedDate = DateTime.parse(doc['dateTime']);
                  String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);
                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Row(
                                  children: [
                                    Text('Rating:', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.indigo[900], fontWeight: FontWeight.w600)),
                                    RatingBar.builder(
                                        itemSize: 20.sp,
                                        unratedColor: Colors.indigo[900],
                                        initialRating: doc['rating'],
                                        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber[700]),
                                        onRatingUpdate: (rating) {
                                        }
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Text('CustomerName: ' + doc['orderBy'], style: GoogleFonts.inter(fontSize: 13.sp)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Text((doc['comment'] != '') ? doc['comment'] : '(No Review)', style: GoogleFonts.inter(fontSize: 13.sp)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
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
