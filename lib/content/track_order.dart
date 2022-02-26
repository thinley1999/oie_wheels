import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/pages/custom_slider_theme.dart';
import 'package:oie_wheels/content/direction.dart';
import '../pages/utils2.dart';

class TrackOrder extends StatefulWidget {
  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  Widget build(BuildContext context) {
    final labels = ['Order Placed', 'Confirmed', 'Being\nPrepared', 'On Road', 'Delivered'];
    final double min = 0;
    final double max = labels.length - 1.0;
    final divisions = (max - min).toInt();
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text('Track Order', style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0, backgroundColor: Color(0xFF1976D2)
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Order")
            .doc((_auth.currentUser)!.uid)
            .collection("View").snapshots(),
        builder: (context,snapshot){
          if (snapshot.hasError)
            return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState){
            case ConnectionState.waiting:
              return Center(child: SpinKitWave(
                size: 30.sp,
                color: Colors.amber[900],
                duration:  Duration(milliseconds: 800),
              ));
            default:return RawScrollbar(
              thumbColor: Colors.amber[900],
              thickness: 5.sp,
              isAlwaysShown: true,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:snapshot.data!.docs.length,
                  itemBuilder: (_,index){
                    var userDocument = snapshot.data!.docs[index];

                    return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('OrderHistory')
                            .where("orderId",isEqualTo: userDocument['orderId']).get(),
                        builder: (BuildContext context, snapshot) {
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
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount:snapshot.data!.docs.length,
                              itemBuilder: (context, index){

                                var doc = snapshot.data!.docs[index];
                                DateTime formattedDate = DateTime.parse(doc['dateTime']);
                                String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);
                                String dateTime2 = DateFormat.jm().format(formattedDate.add(Duration(minutes: 30)));

                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(3.sp),
                                            topLeft: Radius.circular(3.sp),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(FontAwesomeIcons.clock, size: 15.sp, color: Colors.grey),
                                            SizedBox(width: 10.w),
                                            Text(dateTime, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE8EAF6),
                                          border: Border(
                                            right: BorderSide(width: 0.8.w, color: Colors.grey.withOpacity(0.2.sp)),
                                            left: BorderSide(width: 0.8.w, color: Colors.grey.withOpacity(0.2.sp)),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(dateTime, style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                                            Text('Order no: ' + doc['orderId'], style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                       color: Colors.white,
                                        child: Column(
                                          children: [
                                            Text('YOUR ORDER WILL BE WITH YOU AT\n APPROXIMATELY : $dateTime2', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey)),
                                            CustomSliderTheme(
                                              child: RangeSlider(
                                                values: (doc['status'] == 'unassigned orders') ? RangeValues(0, 0)
                                                    :(doc['status'] == 'order confirm') ? RangeValues(0, 1)
                                                    : (doc['status'] == 'being prepared') ? RangeValues(0, 2)
                                                    : (doc['status'] == 'on the way') ? RangeValues(0, 3)
                                                    : RangeValues(0, 4),
                                                min: min,
                                                max: max,
                                                divisions: divisions,
                                                onChanged: (values) {
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: Utils.modelBuilder(
                                                  labels, (index, label) {
                                                  return Text(label.toString(),
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.inter(fontSize: 10.sp,)
                                                  );
                                                },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: GestureDetector(
                                          onTap: () async {
                                            List<Location> locations = await locationFromAddress(doc['deliveryAddress']);
                                            var lat = locations.first.latitude;
                                            var lon = locations.first.longitude;

                                            FirebaseFirestore.instance.collection('Driver')
                                                .where('fullName',isEqualTo: doc['driver'])
                                                .get()
                                                .then((value){
                                              value.docs.forEach((result) async{
                                                FirebaseFirestore.instance.collection('EditItem').doc((_auth.currentUser)!.uid).collection('Direction').doc((_auth.currentUser)!.uid).set({
                                                  'lat': lat,
                                                  'lon': lon,
                                                  'lat2': result.data()['lat'],
                                                  'lon2': result.data()['lon'],
                                                });
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => Direction()));
                                              });
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                            padding: EdgeInsets.symmetric(vertical: 10.h),
                                            color: Color(0xFF1976D2),
                                            child: Text('VIEW DETAILS', style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white), textAlign: TextAlign.center),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                          );
                        }
                    );
                  }),
            );
          }
        },
      ),
    );
  }
}
