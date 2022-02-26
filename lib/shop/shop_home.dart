import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/shop/shop_drawer.dart';

class ShopHome extends StatefulWidget {
  @override
  _ShopHomeState createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  var date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      drawer: ShopDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(FontAwesomeIcons.bars, size: 20.sp,),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text('Welcome to OieWheels', style: GoogleFonts.inter(
              fontSize: 15.sp, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottomOpacity: 0.0,
          elevation: 0.0,
          backgroundColor: Color(0xFF1976D2),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.
        collection('ShopOwner').where('uid', isEqualTo: (_auth.currentUser)!.uid).snapshots(),
        builder: (context,snapshot){
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
          switch (snapshot.connectionState){
            case ConnectionState.waiting:
              return  Container(
                height: 200.0,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
                ),
              );
            default:return ListView.builder(itemCount:snapshot.data!.docs.length,itemBuilder: (_,index){
              final userDocument = snapshot.data!.docs[index];
              return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection("Shop").where("shopName",isEqualTo: userDocument["shopName"].toString()).get(),
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
                    else {
                      return  Column(
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Text('Here are your Shop Details as registered with OieWheels', style: GoogleFonts.inter(fontSize: 13.sp), textAlign: TextAlign.center,),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(5))
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 5.h),
                                      child: Center(
                                          child: Container(
                                              padding: EdgeInsets.only(top: 5, bottom: 5),
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                        width: 3.sp,
                                                        color: Colors.black.withOpacity(0.35)
                                                    ),
                                                    bottom: BorderSide(
                                                        width: 3.sp,
                                                        color: Colors.black.withOpacity(0.35)
                                                    ),
                                                  )
                                              ),
                                              child: Text('DETAILS', style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.black.withOpacity(0.55))))),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 0),
                                      padding: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 5.h),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFD6D6D6),
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text("Shop Name: ", style: GoogleFonts.inter(fontSize: 13.sp)),
                                              Text(document['shopName'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text("Address: ", style: GoogleFonts.inter(fontSize: 13.sp)),
                                              Text(document['shopAddress'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text("Phone: ", style: GoogleFonts.inter(fontSize: 13.sp)),
                                              Text('+975 ' + document['shopPhone'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Current Operation Status: ", style: GoogleFonts.inter(fontSize: 13.sp)),
                                              (DateFormat('EEEE').format(date) == document['days'][0]['day']) ? Text('Opened', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (DateFormat('EEEE').format(date) == document['days'][1]['day']) ? Text('Opened', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (DateFormat('EEEE').format(date) == document['days'][2]['day']) ? Text('Opened', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (DateFormat('EEEE').format(date) == document['days'][3]['day']) ? Text('Opened', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (DateFormat('EEEE').format(date) == document['days'][4]['day']) ? Text('Opened', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (DateFormat('EEEE').format(date) == document['days'][5]['day']) ? Text('Opened', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (DateFormat('EEEE').format(date) == document['days'][6]['day']) ? Text('Opened', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("District: ", style: GoogleFonts.inter(fontSize: 13.sp)),
                                              Text(document['district'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Service Charge Amount: ", style: GoogleFonts.inter(fontSize: 13.sp)),
                                              Text(document['serviceCharge'] + '.00%', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Owner Email: ", style: GoogleFonts.inter(fontSize: 13.sp)),
                                              Text(userDocument["email"].toString(), style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 5.h),
                                      child: Center(
                                          child: Container(
                                              padding: EdgeInsets.only(top: 5, bottom: 5),
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                        width: 3.sp,
                                                        color: Colors.black.withOpacity(0.35)
                                                    ),
                                                    bottom: BorderSide(
                                                        width: 3.sp,
                                                        color: Colors.black.withOpacity(0.35)
                                                    ),
                                                  )
                                              ),
                                              child: Text('DAY WISE OPENING TIME', style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.black.withOpacity(0.55))))),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 5.h),
                                      padding: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 5.h),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFD6D6D6),
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              (document['days'][0]['isClosed'] == false)?Text('Monday: ', style: GoogleFonts.inter(fontSize: 13.sp)) : Container(),
                                              (document['days'][1]['isClosed'] == false)?Text('Tuesday: ', style: GoogleFonts.inter(fontSize: 13.sp)) : Container(),
                                              (document['days'][2]['isClosed'] == false)?Text('Wednesday: ', style: GoogleFonts.inter(fontSize: 13.sp)) : Container(),
                                              (document['days'][3]['isClosed'] == false)?Text('Thursday: ', style: GoogleFonts.inter(fontSize: 13.sp)) : Container(),
                                              (document['days'][4]['isClosed'] == false)?Text('Friday: ', style: GoogleFonts.inter(fontSize: 13.sp)) : Container(),
                                              (document['days'][5]['isClosed'] == false)?Text('Saturday: ', style: GoogleFonts.inter(fontSize: 13.sp)) : Container(),
                                              (document['days'][6]['isClosed'] == false)?Text('Sunday: ', style: GoogleFonts.inter(fontSize: 13.sp)) : Container(),
                                            ],
                                          ),
                                          SizedBox(width: 10.w),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              (document['days'][0]['isClosed'] == false)?Text(document['days'][0]['openingTime'] + ' to ' + document['days'][0]['closingTime'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (document['days'][1]['isClosed'] == false)?Text(document['days'][1]['openingTime'] + ' to ' + document['days'][1]['closingTime'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (document['days'][2]['isClosed'] == false)?Text(document['days'][2]['openingTime'] + ' to ' + document['days'][2]['closingTime'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (document['days'][3]['isClosed'] == false)?Text(document['days'][3]['openingTime'] + ' to ' + document['days'][3]['closingTime'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (document['days'][4]['isClosed'] == false)?Text(document['days'][4]['openingTime'] + ' to ' + document['days'][4]['closingTime'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (document['days'][5]['isClosed'] == false)?Text(document['days'][5]['openingTime'] + ' to ' + document['days'][5]['closingTime'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                              (document['days'][6]['isClosed'] == false)?Text(document['days'][6]['openingTime'] + ' to ' + document['days'][6]['closingTime'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600)) : Container(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '*To update any of the above details, Please contact our Toll No 1254 or visit Facebook Page facebook.com/OieWheels4Meals',
                                style: GoogleFonts.inter(fontSize: 13.sp), textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    }
                  }
              );
            });
          }
        },
      ),
    );
  }
}
