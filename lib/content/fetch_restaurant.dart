import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/content/store.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class FetchAllRestaurant extends StatefulWidget {
  final List<DocumentSnapshot> r_list;
  final int index;

  const FetchAllRestaurant({Key? key, required this.r_list, required this.index}) : super(key: key);
  @override
  _FetchAllRestaurantState createState() => _FetchAllRestaurantState();
}

class _FetchAllRestaurantState extends State<FetchAllRestaurant> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  var date = DateTime.now();
  DateFormat dateFormat = new DateFormat.Hm();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("Restaurant").where("cuisineType",isEqualTo: widget.r_list[widget.index]["cuisineType"].toString()).get(),
        builder: (BuildContext context, snapshot){
          if (!snapshot.hasData) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: Center(child: SpinKitWave(
                size: 30.sp,
                color: Colors.amber[900],
                duration:  Duration(milliseconds: 800),
              )),
            );
          }
          return snapshot.data!.docs.isNotEmpty ? ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];

                DateTime startDate = DateTime.parse(document['startDate']);
                DateTime endDate = DateTime.parse(document['endDate']);

                DateTime monOpen= dateFormat.parse(document['days'][0]['openingTime']);
                monOpen = new DateTime(date.year, date.month, date.day, monOpen.hour, monOpen.minute);
                DateTime monClose= dateFormat.parse(document['days'][0]['closingTime']);
                monClose = new DateTime(date.year, date.month, date.day, monClose.hour, monClose.minute);

                DateTime tueOpen= dateFormat.parse(document['days'][1]['openingTime']);
                tueOpen = new DateTime(date.year, date.month, date.day, tueOpen.hour, tueOpen.minute);
                DateTime tueClose= dateFormat.parse(document['days'][1]['closingTime']);
                tueClose = new DateTime(date.year, date.month, date.day, tueClose.hour, tueClose.minute);

                DateTime wedOpen= dateFormat.parse(document['days'][2]['openingTime']);
                wedOpen = new DateTime(date.year, date.month, date.day, wedOpen.hour, wedOpen.minute);
                DateTime wedClose= dateFormat.parse(document['days'][2]['closingTime']);
                wedClose = new DateTime(date.year, date.month, date.day, wedClose.hour, wedClose.minute);

                DateTime thuOpen= dateFormat.parse(document['days'][3]['openingTime']);
                thuOpen = new DateTime(date.year, date.month, date.day, thuOpen.hour, thuOpen.minute);
                DateTime thuClose= dateFormat.parse(document['days'][3]['closingTime']);
                thuClose = new DateTime(date.year, date.month, date.day, thuClose.hour, thuClose.minute);

                DateTime friOpen= dateFormat.parse(document['days'][4]['openingTime']);
                friOpen = new DateTime(date.year, date.month, date.day, friOpen.hour, friOpen.minute);
                DateTime friClose= dateFormat.parse(document['days'][4]['closingTime']);
                friClose = new DateTime(date.year, date.month, date.day, friClose.hour, friClose.minute);

                DateTime satOpen= dateFormat.parse(document['days'][5]['openingTime']);
                satOpen = new DateTime(date.year, date.month, date.day, satOpen.hour, satOpen.minute);
                DateTime satClose= dateFormat.parse(document['days'][5]['closingTime']);
                satClose = new DateTime(date.year, date.month, date.day, satClose.hour, satClose.minute);

                DateTime sunOpen= dateFormat.parse(document['days'][6]['openingTime']);
                sunOpen = new DateTime(date.year, date.month, date.day, sunOpen.hour, sunOpen.minute);
                DateTime sunClose= dateFormat.parse(document['days'][6]['closingTime']);
                sunClose = new DateTime(date.year, date.month, date.day, sunClose.hour, sunClose.minute);

                return  SingleChildScrollView(
                  child: Card(
                    elevation: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.sp),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 5.w),
                            width: 100.sp,
                            height: 100.sp,
                            color: Colors.grey.withOpacity(0.35),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                (document['image'] == 'null')
                                    ? Image.asset(
                                  'assets/no_image.png',
                                  width: 80.w,
                                  fit: BoxFit.fitHeight,
                                )
                                : Image.network(
                                  document['image'],
                                  width: 80.w,
                                  fit: BoxFit.fitHeight,
                                ),
                                if(DateFormat('EEEE').format(date) == document['days'][0]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][0]['isClosed'] == false && date.isAfter(monOpen) && date.isBefore(monClose))?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][1]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][1]['isClosed'] == false && date.isAfter(tueOpen) && date.isBefore(tueClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][2]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][2]['isClosed'] == false && date.isAfter(wedOpen) && date.isBefore(wedClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][3]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][3]['isClosed'] == false && date.isAfter(thuOpen) && date.isBefore(thuClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][4]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][4]['isClosed'] == false && date.isAfter(friOpen) && date.isBefore(friClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][5]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][5]['isClosed'] == false && date.isAfter(satOpen) && date.isBefore(satClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][6]['isClosed'] == false && date.isAfter(sunOpen) && date.isBefore(sunClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          ButtonTheme(
                            minWidth: 150.w,
                            child: FlatButton(
                                onPressed: () {
                                  if(DateFormat('EEEE').format(date) == document['days'][0]['day'] && document['days'][0]['isClosed'] == false && date.isAfter(monOpen) && date.isBefore(monClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][1]['day'] && document['days'][1]['isClosed'] == false && date.isAfter(tueOpen) && date.isBefore(tueClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][2]['day'] && document['days'][2]['isClosed'] == false && date.isAfter(wedOpen) && date.isBefore(wedClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][3]['day'] && document['days'][3]['isClosed'] == false && date.isAfter(thuOpen) && date.isBefore(thuClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][4]['day'] && document['days'][4]['isClosed'] == false && date.isAfter(friOpen) && date.isBefore(friClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][5]['day'] && document['days'][5]['isClosed'] == false && date.isAfter(satOpen) && date.isBefore(satClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][6]['day'] && document['days'][6]['isClosed'] == false && date.isAfter(sunOpen) && date.isBefore(sunClose)
                                  ) {
                                    FirebaseFirestore.instance.collection('View').doc((_auth.currentUser)!.uid).collection('StoreItem').doc((_auth.currentUser)!.uid).set({
                                      'restaurantName': document['restaurantName'],
                                      'rid': document['uid'],
                                    });
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Store()));
                                  }else{
                                    Fluttertoast.showToast(
                                        msg: document['restaurantName'] + ' is closed right now.' + ' Please try again later.',
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 14.sp
                                    );
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(document['restaurantName'], style: GoogleFonts.mukta(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                                    SizedBox(
                                      width: 150.w,
                                      child: Row(
                                        children: [
                                          Icon(FontAwesomeIcons.mapMarkerAlt, size: 15.sp, color: Colors.grey),
                                          SizedBox(width: 5.w),
                                          Expanded(child: Text(document['restaurantAddress'], style: GoogleFonts.mukta(fontSize: 11.sp, color: Colors.grey)))
                                        ],
                                      ),
                                    ),
                                    Text('Delivery Time :', style: GoogleFonts.mukta(fontSize: 13.sp, color: Colors.grey)),
                                    Text(document['deliveryTime'] + ' min', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600))
                                  ],
                                )
                            ),
                          ),
                          SizedBox(height: 90.h, child: VerticalDivider(color: Colors.black.withOpacity(0.6))),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('Rating5')
                                  .where('orderFrom', isEqualTo: document['restaurantName'])
                                  .where('isRated',isEqualTo: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return  Center(child: SpinKitRing(
                                    size: 20.sp,
                                    color: Color(0xFFFF6F00),
                                    duration:  Duration(milliseconds: 800),
                                  ));
                                } else {
                                  var ds = snapshot.data!.docs;
                                  var dsLength = snapshot.data!.docs.length;

                                  double sum = 0;
                                  for(int i=0; i<ds.length;i++)sum+=(ds[i]['rating']);
                                  double mainPercent = ((sum/5)/dsLength)*10;
                                  double percent = (sum/5)/dsLength;
                                  double rating = sum/dsLength;

                                  return snapshot.data!.docs.isNotEmpty ? CircularPercentIndicator(
                                    radius: 20.sp,
                                    center: Text(mainPercent.round().toString(), style: GoogleFonts.inter(fontSize: 13.sp)),
                                    progressColor: Colors.blue,
                                    percent: percent,
                                    lineWidth: 1.5.sp,
                                    footer: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.h),
                                      child: Text(rating.round().toString() + ' RATINGS', style: GoogleFonts.inter(fontSize: 10.sp)),
                                    ),
                                  )
                                  : CircularPercentIndicator(
                                    radius: 20.sp,
                                    center: Text('0', style: GoogleFonts.inter(fontSize: 13.sp)),
                                    progressColor: Colors.blue,
                                    percent: 0,
                                    lineWidth: 1.5.sp,
                                    footer: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.h),
                                      child: Text('0 RATINGS', style: GoogleFonts.inter(fontSize: 10.sp)),
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              })
          : SizedBox(
            height: MediaQuery.of(context).size.height / 1.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.folder, size: 80.sp, color: Colors.amber[900]),
                Text('No Data Found', style: GoogleFonts.inter(fontSize: 20.sp, color: Colors.amber[900])),
              ],
            ),
          );
        }
    );
  }
}

class FetchOpenNow extends StatefulWidget {
  final List<DocumentSnapshot> r_list;
  final int index;

  const FetchOpenNow({Key? key, required this.r_list, required this.index}) : super(key: key);
  @override
  _FetchOpenNowState createState() => _FetchOpenNowState();
}

class _FetchOpenNowState extends State<FetchOpenNow> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  var date = DateTime.now();
  DateFormat dateFormat = new DateFormat.Hm();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("Restaurant").where("cuisineType",isEqualTo: widget.r_list[widget.index]["cuisineType"].toString()).get(),
        builder: (BuildContext context, snapshot){
          if (!snapshot.hasData) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: Center(child: SpinKitWave(
                size: 30.sp,
                color: Colors.amber[900],
                duration:  Duration(milliseconds: 800),
              )),
            );
          }
          return snapshot.data!.docs.isNotEmpty ? ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];

                DateTime startDate = DateTime.parse(document['startDate']);
                DateTime endDate = DateTime.parse(document['endDate']);

                DateTime monOpen= dateFormat.parse(document['days'][0]['openingTime']);
                monOpen = new DateTime(date.year, date.month, date.day, monOpen.hour, monOpen.minute);
                DateTime monClose= dateFormat.parse(document['days'][0]['closingTime']);
                monClose = new DateTime(date.year, date.month, date.day, monClose.hour, monClose.minute);

                DateTime tueOpen= dateFormat.parse(document['days'][1]['openingTime']);
                tueOpen = new DateTime(date.year, date.month, date.day, tueOpen.hour, tueOpen.minute);
                DateTime tueClose= dateFormat.parse(document['days'][1]['closingTime']);
                tueClose = new DateTime(date.year, date.month, date.day, tueClose.hour, tueClose.minute);

                DateTime wedOpen= dateFormat.parse(document['days'][2]['openingTime']);
                wedOpen = new DateTime(date.year, date.month, date.day, wedOpen.hour, wedOpen.minute);
                DateTime wedClose= dateFormat.parse(document['days'][2]['closingTime']);
                wedClose = new DateTime(date.year, date.month, date.day, wedClose.hour, wedClose.minute);

                DateTime thuOpen= dateFormat.parse(document['days'][3]['openingTime']);
                thuOpen = new DateTime(date.year, date.month, date.day, thuOpen.hour, thuOpen.minute);
                DateTime thuClose= dateFormat.parse(document['days'][3]['closingTime']);
                thuClose = new DateTime(date.year, date.month, date.day, thuClose.hour, thuClose.minute);

                DateTime friOpen= dateFormat.parse(document['days'][4]['openingTime']);
                friOpen = new DateTime(date.year, date.month, date.day, friOpen.hour, friOpen.minute);
                DateTime friClose= dateFormat.parse(document['days'][4]['closingTime']);
                friClose = new DateTime(date.year, date.month, date.day, friClose.hour, friClose.minute);

                DateTime satOpen= dateFormat.parse(document['days'][5]['openingTime']);
                satOpen = new DateTime(date.year, date.month, date.day, satOpen.hour, satOpen.minute);
                DateTime satClose= dateFormat.parse(document['days'][5]['closingTime']);
                satClose = new DateTime(date.year, date.month, date.day, satClose.hour, satClose.minute);

                DateTime sunOpen= dateFormat.parse(document['days'][6]['openingTime']);
                sunOpen = new DateTime(date.year, date.month, date.day, sunOpen.hour, sunOpen.minute);
                DateTime sunClose= dateFormat.parse(document['days'][6]['closingTime']);
                sunClose = new DateTime(date.year, date.month, date.day, sunClose.hour, sunClose.minute);

                if(DateFormat('EEEE').format(date) == document['days'][0]['day'] && document['days'][0]['isClosed'] == false && date.isAfter(monOpen) && date.isBefore(monClose) ||
                    DateFormat('EEEE').format(date) == document['days'][1]['day'] && document['days'][1]['isClosed'] == false && date.isAfter(tueOpen) && date.isBefore(tueClose) ||
                    DateFormat('EEEE').format(date) == document['days'][2]['day'] && document['days'][2]['isClosed'] == false && date.isAfter(wedOpen) && date.isBefore(wedClose) ||
                    DateFormat('EEEE').format(date) == document['days'][3]['day'] && document['days'][3]['isClosed'] == false && date.isAfter(thuOpen) && date.isBefore(thuClose) ||
                    DateFormat('EEEE').format(date) == document['days'][4]['day'] && document['days'][4]['isClosed'] == false && date.isAfter(friOpen) && date.isBefore(friClose) ||
                    DateFormat('EEEE').format(date) == document['days'][5]['day'] && document['days'][5]['isClosed'] == false && date.isAfter(satOpen) && date.isBefore(satClose) ||
                    DateFormat('EEEE').format(date) == document['days'][6]['day'] && document['days'][6]['isClosed'] == false && date.isAfter(sunOpen) && date.isBefore(sunClose)
                ) {
                  return SingleChildScrollView(
                    child: Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        margin: EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 5.w),
                              width: 100.sp,
                              height: 100.sp,
                              color: Colors.grey.withOpacity(0.35),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  (document['image'] == 'null')
                                      ? Image.asset(
                                    'assets/no_image.png',
                                    width: 80.w,
                                    fit: BoxFit.fitHeight,
                                  )
                                      : Image.network(
                                    document['image'],
                                    width: 80.w,
                                    fit: BoxFit.fitHeight,
                                  ),
                                  if(DateFormat('EEEE').format(date) == document['days'][0]['day']) ...[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: (document['days'][0]['isClosed'] == false && date.isAfter(monOpen) && date.isBefore(monClose))?
                                      Container(
                                          color: Colors.green,
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ) : Container(
                                          color: Colors.redAccent[700],
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ),
                                    ),
                                  ] else if(DateFormat('EEEE').format(date) == document['days'][1]['day']) ...[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: (document['days'][1]['isClosed'] == false && date.isAfter(tueOpen) && date.isBefore(tueClose)) ?
                                      Container(
                                          color: Colors.green,
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ) : Container(
                                          color: Colors.redAccent[700],
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ),
                                    ),
                                  ] else if(DateFormat('EEEE').format(date) == document['days'][2]['day']) ...[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: (document['days'][2]['isClosed'] == false && date.isAfter(wedOpen) && date.isBefore(wedClose)) ?
                                      Container(
                                          color: Colors.green,
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ) : Container(
                                          color: Colors.redAccent[700],
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ),
                                    ),
                                  ] else if(DateFormat('EEEE').format(date) == document['days'][3]['day']) ...[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: (document['days'][3]['isClosed'] == false && date.isAfter(thuOpen) && date.isBefore(thuClose)) ?
                                      Container(
                                          color: Colors.green,
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ) : Container(
                                          color: Colors.redAccent[700],
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ),
                                    ),
                                  ] else if(DateFormat('EEEE').format(date) == document['days'][4]['day']) ...[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: (document['days'][4]['isClosed'] == false && date.isAfter(friOpen) && date.isBefore(friClose)) ?
                                      Container(
                                          color: Colors.green,
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ) : Container(
                                          color: Colors.redAccent[700],
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ),
                                    ),
                                  ] else if(DateFormat('EEEE').format(date) == document['days'][5]['day']) ...[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: (document['days'][5]['isClosed'] == false && date.isAfter(satOpen) && date.isBefore(satClose)) ?
                                      Container(
                                          color: Colors.green,
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ) : Container(
                                          color: Colors.redAccent[700],
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ),
                                    ),
                                  ] else ...[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: (document['days'][6]['isClosed'] == false && date.isAfter(sunOpen) && date.isBefore(sunClose)) ?
                                      Container(
                                          color: Colors.green,
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ) : Container(
                                          color: Colors.redAccent[700],
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            ButtonTheme(
                              minWidth: 150.w,
                              child: FlatButton(
                                  onPressed: () {
                                    if(DateFormat('EEEE').format(date) == document['days'][0]['day'] && document['days'][0]['isClosed'] == false && date.isAfter(monOpen) && date.isBefore(monClose) ||
                                        DateFormat('EEEE').format(date) == document['days'][1]['day'] && document['days'][1]['isClosed'] == false && date.isAfter(tueOpen) && date.isBefore(tueClose) ||
                                        DateFormat('EEEE').format(date) == document['days'][2]['day'] && document['days'][2]['isClosed'] == false && date.isAfter(wedOpen) && date.isBefore(wedClose) ||
                                        DateFormat('EEEE').format(date) == document['days'][3]['day'] && document['days'][3]['isClosed'] == false && date.isAfter(thuOpen) && date.isBefore(thuClose) ||
                                        DateFormat('EEEE').format(date) == document['days'][4]['day'] && document['days'][4]['isClosed'] == false && date.isAfter(friOpen) && date.isBefore(friClose) ||
                                        DateFormat('EEEE').format(date) == document['days'][5]['day'] && document['days'][5]['isClosed'] == false && date.isAfter(satOpen) && date.isBefore(satClose) ||
                                        DateFormat('EEEE').format(date) == document['days'][6]['day'] && document['days'][6]['isClosed'] == false && date.isAfter(sunOpen) && date.isBefore(sunClose)
                                    ) {
                                      FirebaseFirestore.instance.collection('View').doc((_auth.currentUser)!.uid).collection('StoreItem').doc((_auth.currentUser)!.uid).set({
                                        'restaurantName': document['restaurantName'],
                                        'rid': document['uid'],
                                      });
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Store()));
                                    }else{
                                      Fluttertoast.showToast(
                                          msg: document['restaurantName'] + ' is closed right now.' + ' Please try again later.',
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 14.sp
                                      );
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(document['restaurantName'], style: GoogleFonts.mukta(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                                      SizedBox(
                                        width: 150.w,
                                        child: Row(
                                          children: [
                                            Icon(FontAwesomeIcons.mapMarkerAlt, size: 15.sp, color: Colors.grey),
                                            SizedBox(width: 5.w),
                                            Expanded(child: Text(document['restaurantAddress'], style: GoogleFonts.mukta(fontSize: 11.sp, color: Colors.grey)))
                                          ],
                                        ),
                                      ),
                                      Text('Delivery Time :', style: GoogleFonts.mukta(fontSize: 13.sp, color: Colors.grey)),
                                      Text(document['deliveryTime'] + ' min', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600))
                                    ],
                                  )
                              ),
                            ),
                            SizedBox(height: 90.h, child: VerticalDivider(color: Colors.black.withOpacity(0.6))),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('Rating5')
                                    .where('orderFrom', isEqualTo: document['restaurantName'])
                                    .where('isRated',isEqualTo: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return  Center(child: SpinKitRing(
                                      size: 20.sp,
                                      color: Color(0xFFFF6F00),
                                      duration:  Duration(milliseconds: 800),
                                    ));
                                  } else {
                                    var ds = snapshot.data!.docs;
                                    var dsLength = snapshot.data!.docs.length;

                                    double sum = 0;
                                    for(int i=0; i<ds.length;i++)sum+=(ds[i]['rating']);
                                    double mainPercent = ((sum/5)/dsLength)*10;
                                    double percent = (sum/5)/dsLength;
                                    double rating = sum/dsLength;

                                    return snapshot.data!.docs.isNotEmpty ? CircularPercentIndicator(
                                      radius: 20.sp,
                                      center: Text(mainPercent.round().toString(), style: GoogleFonts.inter(fontSize: 13.sp)),
                                      progressColor: Colors.blue,
                                      percent: percent,
                                      lineWidth: 1.5.sp,
                                      footer: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.h),
                                        child: Text(rating.round().toString() + ' RATINGS', style: GoogleFonts.inter(fontSize: 10.sp)),
                                      ),
                                    )
                                        : CircularPercentIndicator(
                                      radius: 20.sp,
                                      center: Text('0', style: GoogleFonts.inter(fontSize: 13.sp)),
                                      progressColor: Colors.blue,
                                      percent: 0,
                                      lineWidth: 1.5.sp,
                                      footer: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.h),
                                        child: Text('0 RATINGS', style: GoogleFonts.inter(fontSize: 10.sp)),
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              })
              : SizedBox(
            height: MediaQuery.of(context).size.height / 1.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.folder, size: 80.sp, color: Colors.amber[900]),
                Text('No Data Found', style: GoogleFonts.inter(fontSize: 20.sp, color: Colors.amber[900])),
              ],
            ),
          );
        }
    );
  }
}

class FetchCloseToday extends StatefulWidget {
  final List<DocumentSnapshot> r_list;
  final int index;

  const FetchCloseToday({Key? key, required this.r_list, required this.index}) : super(key: key);
  @override
  _FetchCloseTodayState createState() => _FetchCloseTodayState();
}

class _FetchCloseTodayState extends State<FetchCloseToday> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  var date = DateTime.now();
  DateFormat dateFormat = new DateFormat.Hm();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("Restaurant").where("cuisineType",isEqualTo: widget.r_list[widget.index]["cuisineType"].toString()).get(),
        builder: (BuildContext context, snapshot){
          if (!snapshot.hasData) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: Center(child: SpinKitWave(
                size: 30.sp,
                color: Colors.amber[900],
                duration:  Duration(milliseconds: 800),
              )),
            );
          }
          return snapshot.data!.docs.isNotEmpty ? ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];

                DateTime startDate = DateTime.parse(document['startDate']);
                DateTime endDate = DateTime.parse(document['endDate']);

                DateTime monOpen= dateFormat.parse(document['days'][0]['openingTime']);
                monOpen = new DateTime(date.year, date.month, date.day, monOpen.hour, monOpen.minute);
                DateTime monClose= dateFormat.parse(document['days'][0]['closingTime']);
                monClose = new DateTime(date.year, date.month, date.day, monClose.hour, monClose.minute);

                DateTime tueOpen= dateFormat.parse(document['days'][1]['openingTime']);
                tueOpen = new DateTime(date.year, date.month, date.day, tueOpen.hour, tueOpen.minute);
                DateTime tueClose= dateFormat.parse(document['days'][1]['closingTime']);
                tueClose = new DateTime(date.year, date.month, date.day, tueClose.hour, tueClose.minute);

                DateTime wedOpen= dateFormat.parse(document['days'][2]['openingTime']);
                wedOpen = new DateTime(date.year, date.month, date.day, wedOpen.hour, wedOpen.minute);
                DateTime wedClose= dateFormat.parse(document['days'][2]['closingTime']);
                wedClose = new DateTime(date.year, date.month, date.day, wedClose.hour, wedClose.minute);

                DateTime thuOpen= dateFormat.parse(document['days'][3]['openingTime']);
                thuOpen = new DateTime(date.year, date.month, date.day, thuOpen.hour, thuOpen.minute);
                DateTime thuClose= dateFormat.parse(document['days'][3]['closingTime']);
                thuClose = new DateTime(date.year, date.month, date.day, thuClose.hour, thuClose.minute);

                DateTime friOpen= dateFormat.parse(document['days'][4]['openingTime']);
                friOpen = new DateTime(date.year, date.month, date.day, friOpen.hour, friOpen.minute);
                DateTime friClose= dateFormat.parse(document['days'][4]['closingTime']);
                friClose = new DateTime(date.year, date.month, date.day, friClose.hour, friClose.minute);

                DateTime satOpen= dateFormat.parse(document['days'][5]['openingTime']);
                satOpen = new DateTime(date.year, date.month, date.day, satOpen.hour, satOpen.minute);
                DateTime satClose= dateFormat.parse(document['days'][5]['closingTime']);
                satClose = new DateTime(date.year, date.month, date.day, satClose.hour, satClose.minute);

                DateTime sunOpen= dateFormat.parse(document['days'][6]['openingTime']);
                sunOpen = new DateTime(date.year, date.month, date.day, sunOpen.hour, sunOpen.minute);
                DateTime sunClose= dateFormat.parse(document['days'][6]['closingTime']);
                sunClose = new DateTime(date.year, date.month, date.day, sunClose.hour, sunClose.minute);

                if(DateFormat('EEEE').format(date) == document['days'][0]['day'] && date.isAfter(monOpen) && date.isBefore(monClose) ||
                    DateFormat('EEEE').format(date) == document['days'][1]['day'] && date.isAfter(tueOpen) && date.isBefore(tueClose) ||
                    DateFormat('EEEE').format(date) == document['days'][2]['day'] && date.isAfter(wedOpen) && date.isBefore(wedClose) ||
                    DateFormat('EEEE').format(date) == document['days'][3]['day'] && date.isAfter(thuOpen) && date.isBefore(thuClose) ||
                    DateFormat('EEEE').format(date) == document['days'][4]['day'] && date.isAfter(friOpen) && date.isBefore(friClose) ||
                    DateFormat('EEEE').format(date) == document['days'][5]['day'] && date.isAfter(satOpen) && date.isBefore(satClose) ||
                    DateFormat('EEEE').format(date) == document['days'][6]['day'] && date.isAfter(sunOpen) && date.isBefore(sunClose)
                ) {
                  return SizedBox();
                }
                return SingleChildScrollView(
                  child: Card(
                    elevation: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      margin: EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 5.w),
                            width: 100.sp,
                            height: 100.sp,
                            color: Colors.grey.withOpacity(0.35),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                (document['image'] == 'null')
                                    ? Image.asset(
                                  'assets/no_image.png',
                                  width: 80.w,
                                  fit: BoxFit.fitHeight,
                                )
                                    : Image.network(
                                  document['image'],
                                  width: 80.w,
                                  fit: BoxFit.fitHeight,
                                ),
                                if(DateFormat('EEEE').format(date) == document['days'][0]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][0]['isClosed'] == false && date.isAfter(monOpen) && date.isBefore(monClose))?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][1]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][1]['isClosed'] == false && date.isAfter(tueOpen) && date.isBefore(tueClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][2]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][2]['isClosed'] == false && date.isAfter(wedOpen) && date.isBefore(wedClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][3]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][3]['isClosed'] == false && date.isAfter(thuOpen) && date.isBefore(thuClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][4]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][4]['isClosed'] == false && date.isAfter(friOpen) && date.isBefore(friClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else if(DateFormat('EEEE').format(date) == document['days'][5]['day']) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][5]['isClosed'] == false && date.isAfter(satOpen) && date.isBefore(satClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ] else ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: (document['days'][6]['isClosed'] == false && date.isAfter(sunOpen) && date.isBefore(sunClose)) ?
                                    Container(
                                        color: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('OPEN', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ) : Container(
                                        color: Colors.redAccent[700],
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        child: Text('CLOSE', style: GoogleFonts.mukta(fontSize: 12.sp, color: Colors.white))
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          ButtonTheme(
                            minWidth: 150.w,
                            child: FlatButton(
                                onPressed: () {
                                  if(DateFormat('EEEE').format(date) == document['days'][0]['day'] && document['days'][0]['isClosed'] == false && date.isAfter(monOpen) && date.isBefore(monClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][1]['day'] && document['days'][1]['isClosed'] == false && date.isAfter(tueOpen) && date.isBefore(tueClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][2]['day'] && document['days'][2]['isClosed'] == false && date.isAfter(wedOpen) && date.isBefore(wedClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][3]['day'] && document['days'][3]['isClosed'] == false && date.isAfter(thuOpen) && date.isBefore(thuClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][4]['day'] && document['days'][4]['isClosed'] == false && date.isAfter(friOpen) && date.isBefore(friClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][5]['day'] && document['days'][5]['isClosed'] == false && date.isAfter(satOpen) && date.isBefore(satClose) ||
                                      DateFormat('EEEE').format(date) == document['days'][6]['day'] && document['days'][6]['isClosed'] == false && date.isAfter(sunOpen) && date.isBefore(sunClose)
                                  ) {
                                    FirebaseFirestore.instance.collection('View').doc((_auth.currentUser)!.uid).collection('StoreItem').doc((_auth.currentUser)!.uid).set({
                                      'restaurantName': document['restaurantName'],
                                      'rid': document['uid'],
                                    });
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Store()));
                                  }else{
                                    Fluttertoast.showToast(
                                        msg: document['restaurantName'] + ' is closed right now.' + ' Please try again later.',
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 14.sp
                                    );
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(document['restaurantName'], style: GoogleFonts.mukta(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                                    SizedBox(
                                      width: 150.w,
                                      child: Row(
                                        children: [
                                          Icon(FontAwesomeIcons.mapMarkerAlt, size: 15.sp, color: Colors.grey),
                                          SizedBox(width: 5.w),
                                          Expanded(child: Text(document['restaurantAddress'], style: GoogleFonts.mukta(fontSize: 11.sp, color: Colors.grey)))
                                        ],
                                      ),
                                    ),
                                    Text('Delivery Time :', style: GoogleFonts.mukta(fontSize: 13.sp, color: Colors.grey)),
                                    Text(document['deliveryTime'] + ' min', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600))
                                  ],
                                )
                            ),
                          ),
                          SizedBox(height: 90.h, child: VerticalDivider(color: Colors.black.withOpacity(0.6))),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('Rating5')
                                  .where('orderFrom', isEqualTo: document['restaurantName'])
                                  .where('isRated',isEqualTo: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return  Center(child: SpinKitRing(
                                    size: 20.sp,
                                    color: Color(0xFFFF6F00),
                                    duration:  Duration(milliseconds: 800),
                                  ));
                                } else {
                                  var ds = snapshot.data!.docs;
                                  var dsLength = snapshot.data!.docs.length;

                                  double sum = 0;
                                  for(int i=0; i<ds.length;i++)sum+=(ds[i]['rating']);
                                  double mainPercent = ((sum/5)/dsLength)*10;
                                  double percent = (sum/5)/dsLength;
                                  double rating = sum/dsLength;

                                  return snapshot.data!.docs.isNotEmpty ? CircularPercentIndicator(
                                    radius: 20.sp,
                                    center: Text(mainPercent.round().toString(), style: GoogleFonts.inter(fontSize: 13.sp)),
                                    progressColor: Colors.blue,
                                    percent: percent,
                                    lineWidth: 1.5.sp,
                                    footer: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.h),
                                      child: Text(rating.round().toString() + ' RATINGS', style: GoogleFonts.inter(fontSize: 10.sp)),
                                    ),
                                  )
                                      : CircularPercentIndicator(
                                    radius: 20.sp,
                                    center: Text('0', style: GoogleFonts.inter(fontSize: 13.sp)),
                                    progressColor: Colors.blue,
                                    percent: 0,
                                    lineWidth: 1.5.sp,
                                    footer: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.h),
                                      child: Text('0 RATINGS', style: GoogleFonts.inter(fontSize: 10.sp)),
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              })
           : SizedBox(
            height: MediaQuery.of(context).size.height / 1.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.folder, size: 80.sp, color: Colors.amber[900]),
                Text('No Data Found', style: GoogleFonts.inter(fontSize: 20.sp, color: Colors.amber[900])),
              ],
            ),
          );
        }
    );
  }
}


