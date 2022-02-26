import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class FetchStore extends StatefulWidget {
  final List<DocumentSnapshot> s_list;
  final int index;

  const FetchStore({Key? key, required this.s_list, required this.index}) : super(key: key);
  @override
  _FetchStoreState createState() => _FetchStoreState();
}

class _FetchStoreState extends State<FetchStore> {
  @override
  void initState() {
    super.initState();
    _getName();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  String formattedDate = DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now());
  int counter = 1;

  showOverlay(BuildContext context) async{
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
    });
  }

  void _getName(){
    FirebaseFirestore.instance.collection('Users').doc((_auth.currentUser)!.uid).get().then((value){
      firstName = value.data()!['firstName'];
      lastName = value.data()!['lastName'];
      phone = value.data()!['phone'];
      lat = value.data()!['lat'];
      lon = value.data()!['lon'];
    }).then((value) async{
      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lon,
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.street}, ${place.locality}, ${place.country}";
        print(_currentAddress);
      });
    });
  }

  var firstName;
  var lastName;
  var phone;
  String ? _currentAddress;
  var lat;
  var lon;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("StoreItem1").where("restaurantName",isEqualTo: widget.s_list[widget.index]["restaurantName"].toString()).get(),
        builder: (BuildContext context, snapshot){
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
          return snapshot.data!.docs.isNotEmpty ? SingleChildScrollView(
            child: GroupedListView<dynamic, String>(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              elements: snapshot.data!.docs,
              groupBy: (element) => element['itemType'],
              groupSeparatorBuilder: (String groupByValue) {
                return Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Row(
                    children: [
                      Flexible(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            color: Colors.grey[400],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: Text(
                                    groupByValue.toUpperCase(),
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold),
                                  ),
                                ),

                              ],
                            ),
                          )
                      )
                    ],
                  ),
                );
              },
              itemBuilder: (context, dynamic element) {
                return Container(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  padding: EdgeInsets.only(left: 10.w,top: 5.h, right: 10.w, bottom: 5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(element['itemName'], style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          Text('Price: BTN ' + element['price'] + '.00', style: GoogleFonts.inter(fontSize: 11.sp)),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height:30.h,
                            width:30.w,
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(1),
                                    bottomLeft: Radius.circular(1),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey,
                                    width: 0.5.sp,
                                  )
                              ),
                              heroTag: null,
                              child: Icon(Icons.remove, size: 15.sp, color: Colors.black,),
                              onPressed: () async {
                                showOverlay(context);
                                var a = await FirebaseFirestore.instance
                                    .collection('Order')
                                    .doc((_auth.currentUser)!.uid)
                                    .collection('Item').doc(element['restaurantName'] + element['itemName'] + formattedDate)
                                    .get();
                                if(a.exists){
                                  FirebaseFirestore.instance
                                      .collection('Order')
                                      .doc((_auth.currentUser)!.uid)
                                      .collection('Item')
                                      .doc(element['restaurantName'] + element['itemName'] + formattedDate)
                                      .update({
                                    'orderCount': FieldValue.increment(-1),
                                  });
                                }
                                if(!a.exists){
                                  print('Not exists');
                                  return null;
                                }
                              },
                            ),
                          ),
                          Container(
                              height:30.h,
                              width:30.w,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: 1.sp, color: Colors.grey),
                                  bottom: BorderSide(width: 1.sp, color: Colors.grey),
                                ),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Order').doc((_auth.currentUser)!.uid).collection('Item').where('orderItem', isEqualTo: element['itemName'])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(child: SpinKitRing(
                                        size: 20.sp,
                                        color: Color(0xFFFF6F00),
                                        duration:  Duration(milliseconds: 800),
                                      ));
                                    } else {
                                      return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            DocumentSnapshot doc = snapshot.data!.docs[index];
                                            return (doc['orderCount'] >= 0 && doc['status'] == 'draft') ? Text(
                                              doc['orderCount'].toString(), style: GoogleFonts.inter(fontSize: 13.sp),
                                              textAlign: TextAlign.center,
                                            ) : Text('');
                                          })
                                      : Text('0', style: GoogleFonts.inter(fontSize: 13.sp), textAlign: TextAlign.center);
                                    }
                                  },
                                ),
                              ),
                          ),
                          SizedBox(
                            height:30.h,
                            width:30.w,
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(1),
                                    bottomRight: Radius.circular(1),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey,
                                    width: 0.5.sp,
                                  )
                              ),
                              heroTag: null,
                              child: Icon(Icons.add, size: 15.sp, color: Colors.black,),
                              onPressed: () async{
                                showOverlay(context);
                                var a = await FirebaseFirestore.instance
                                    .collection('Order')
                                    .doc((_auth.currentUser)!.uid)
                                .collection('Item').doc(element['restaurantName'] + element['itemName'] + formattedDate)
                                    .get();
                                if(a.exists){
                                  FirebaseFirestore.instance
                                      .collection('Order')
                                      .doc((_auth.currentUser)!.uid)
                                      .collection('Item')
                                      .doc(element['restaurantName'] + element['itemName'] + formattedDate)
                                      .update({
                                    'orderCount': FieldValue.increment(1),
                                  });
                                }
                                if(!a.exists){
                                  FirebaseFirestore.instance
                                      .collection('Order')
                                      .doc((_auth.currentUser)!.uid)
                                      .collection('Item')
                                      .doc(element['restaurantName'] + element['itemName'] + formattedDate)
                                      .set({
                                    'sId': element['refId'],
                                    'orderCount': counter,
                                    'price': int.parse(element['price']),
                                    'orderItem': element['itemName'],
                                    'itemType': element['itemType'],
                                    'size': 'none',
                                    'status': 'draft',
                                    'oId': element['restaurantName'] + element['itemName'] + formattedDate,
                                    'orderFrom': element['restaurantName'],
                                    'orderBy': firstName + ' ' + lastName,
                                    'phone': phone,
                                    'lat': lat,
                                    'lon': lon,
                                    'deliverAddress': _currentAddress,
                                    'discount': int.parse(element['discount']),
                                    'startDate': element['startDate'],
                                    'endDate': element['endDate'],
                                    'from': 'restaurant',
                                    'packingPrice': int.parse(element['packingPrice']),
                                    'dateTime': 'unknown',
                                    'uid': (_auth.currentUser)!.uid,
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              itemComparator: (item1, item2) => item1['itemName'].compareTo(item2['itemName']), // optional
              useStickyGroupSeparators: true, // optional
              floatingHeader: true, // optional
              order: GroupedListOrder.ASC,
            ),
          )
          :  SizedBox(
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

class FetchRestaurantFacts extends StatefulWidget {
  final List<DocumentSnapshot> f_list;
  final int index;

  const FetchRestaurantFacts({Key? key, required this.f_list, required this.index}) : super(key: key);
  @override
  _FetchRestaurantFactsState createState() => _FetchRestaurantFactsState();
}

class _FetchRestaurantFactsState extends State<FetchRestaurantFacts> {
  List<String> orderItem = <String>[];
  List<Widget> textWidgetList = <Widget>[];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection("Restaurant").where("restaurantName",isEqualTo: widget.f_list[widget.index]["restaurantName"].toString()).get(),
              builder: (BuildContext context, snapshot){
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 1.3,
                    child: Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 1.3,
                        child: Center(
                          child: SpinKitWave(
                            size: 30.sp,
                            color: Colors.amber[900],
                            duration:  Duration(milliseconds: 800),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index){
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.sp)
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 40.sp),
                          Expanded(child: Text(snapshot.data!.docs[index]['restaurantAddress'], style: GoogleFonts.inter(fontSize: 13.sp)))
                        ],
                      ),
                    );
                    }
                );
              }
          ),
          FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection("Rating5")
                  .where("orderFrom",isEqualTo: widget.f_list[widget.index]["restaurantName"].toString())
                  .where('isRated', isEqualTo: true)
                  .get(),
              builder: (BuildContext context, snapshot){
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
                  var ds = snapshot.data!.docs;
                  var dsLength = snapshot.data!.docs.length;

                  double sum = 0;
                  for(int i=0; i<ds.length;i++)sum+=(ds[i]['rating']);
                  double mainPercent = ((sum/5)/dsLength)*10;
                  double percent = (sum/5)/dsLength;
                  double rating = sum/dsLength;

                  return snapshot.data!.docs.isNotEmpty ? Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.sp)
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Text('Overall Customer Rating', style: GoogleFonts.inter(fontSize: 13.sp)),
                        ),
                        CircularPercentIndicator(
                          radius: 50.sp,
                          center: Text(mainPercent.round().toString() +'.0', style: GoogleFonts.inter(fontSize: 15.sp)),
                          progressColor: Colors.amber[900],
                          percent: percent,
                          lineWidth: 3.sp,
                          footer: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            child: Text(rating.round().toString() + ' RATINGS', style: GoogleFonts.inter(fontSize: 12.sp)),
                          ),
                        ),
                      ],
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.sp)
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Text('Overall Customer Rating', style: GoogleFonts.inter(fontSize: 13.sp)),
                        ),
                        CircularPercentIndicator(
                          radius: 50.sp,
                          center: Text('0.0', style: GoogleFonts.inter(fontSize: 15.sp)),
                          progressColor: Colors.amber[900],
                          percent: 0,
                          lineWidth: 3.sp,
                          footer: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            child: Text('0 RATINGS', style: GoogleFonts.inter(fontSize: 12.sp)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 70.w,
                    child: Divider(color: Colors.black,thickness: 0.5.sp)
                ),
                Text('MOST POPULAR DISHES', style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.black)),
                SizedBox(
                    width: 70.w,
                    child: Divider(color: Colors.black,thickness: 0.5.sp)
                ),
              ],
            ),
          ),
          FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection("ItemRating")
                  .where("orderFrom",isEqualTo: widget.f_list[widget.index]["restaurantName"].toString())
                  .where('isRated', isEqualTo: true)
                  .get(),
              builder: (BuildContext context, snapshot){
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 1.3,
                    child: Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 1.3,
                        child: Center(
                          child: SpinKitWave(
                            size: 30.sp,
                            color: Colors.amber[900],
                            duration:  Duration(milliseconds: 800),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  var ds = snapshot.data!.docs;
                  orderItem = [];
                  for(int i =0; i<ds.length; i++){
                    orderItem.add( ds[i]['orderItem']);
                  }

                  final removeDuplicates = orderItem.toSet().toList();

                  return snapshot.data!.docs.isNotEmpty ? ListView(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: removeDuplicates.map((element) =>
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2.sp)
                          ),
                          margin: EdgeInsets.only(bottom: 5.h),
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.only(left: 10.w),
                                  constraints: BoxConstraints(
                                    minWidth: 260.w
                                  ),
                                  child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(element, style: GoogleFonts.inter(fontSize: 13.sp)),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('StoreItem1')
                                            .where('restaurantName', isEqualTo: widget.f_list[widget.index]["restaurantName"].toString())
                                            .where('itemName',isEqualTo: element)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return  Center(child: SpinKitRing(
                                              size: 20.sp,
                                              color: Color(0xFFFF6F00),
                                              duration:  Duration(milliseconds: 800),
                                            ));
                                          } else {
                                            return SizedBox(
                                              width: 200.w,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                  physics: ClampingScrollPhysics(),
                                                  itemCount: snapshot.data!.docs.length,
                                                  itemBuilder: (context, index){
                                                  var price = snapshot.data!.docs[index]['price'];
                                                  return Text('Price : BTN ' + price + '.00', style: GoogleFonts.inter(fontSize: 12.sp));
                                                  }
                                              ),
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  )
                              ),
                              SizedBox(height: 70.h, child: VerticalDivider(color: Colors.black.withOpacity(0.6))),
                              Expanded(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('ItemRating')
                                      .where('orderFrom', isEqualTo: widget.f_list[widget.index]["restaurantName"].toString())
                                      .where('orderItem',isEqualTo: element)
                                      .where('isRated', isEqualTo: true)
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
                                        radius: 30.sp,
                                        center: Text(mainPercent.round().toString() + '.0', style: GoogleFonts.inter(fontSize: 13.sp)),
                                        progressColor: Colors.blue,
                                        percent: percent,
                                        lineWidth: 1.5.sp,
                                        header: Padding(
                                          padding: EdgeInsets.only(bottom: 5.h),
                                          child: Text(rating.round().toString() + ' RATINGS', style: GoogleFonts.inter(fontSize: 10.sp)),
                                        ),
                                      )
                                          : CircularPercentIndicator(
                                        radius: 30.sp,
                                        center: Text('0.0', style: GoogleFonts.inter(fontSize: 13.sp)),
                                        progressColor: Colors.blue,
                                        percent: 0,
                                        lineWidth: 1.5.sp,
                                        header: Padding(
                                          padding: EdgeInsets.only(bottom: 5.h),
                                          child: Text('0 RATINGS', style: GoogleFonts.inter(fontSize: 10.sp)),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                    ).toList(),
                  )
                  : Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.sp)
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.folder, size: 80.sp, color: Colors.amber[900]),
                        Text('No Data Found', style: GoogleFonts.inter(fontSize: 20.sp, color: Colors.amber[900])),
                      ],
                    ),
                  );
                }

              }
          ),
        ],
      ),
    );
  }
}

class FetchCustomerFeedBack extends StatefulWidget {
  final List<DocumentSnapshot> c_list;
  final int index;

  const FetchCustomerFeedBack({Key? key, required this.c_list, required this.index}) : super(key: key);
  @override
  _FetchCustomerFeedBackState createState() => _FetchCustomerFeedBackState();
}

class _FetchCustomerFeedBackState extends State<FetchCustomerFeedBack> {
  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("Rating5")
            .where("orderFrom",isEqualTo: widget.c_list[widget.index]["restaurantName"].toString())
            .where('isRated', isEqualTo: true)
            .get(),
        builder: (BuildContext context, snapshot){
          if (!snapshot.hasData) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: Center(
                    child: SpinKitWave(
                      size: 30.sp,
                      color: Colors.amber[900],
                      duration:  Duration(milliseconds: 800),
                    ),
                  ),
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
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2.sp)
                  ),
                  margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                         Row(
                           children: [
                             Container(
                                 padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                                 decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(100),
                                     border: Border.all(color: Colors.grey)
                                 ),
                                 child: Icon(Icons.person, size: 15.sp, color: Colors.grey)
                             ),
                             Padding(
                               padding: EdgeInsets.only(left: 5.w),
                               child: Text(doc['orderBy'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.amber[900])),
                             )
                           ],
                         ),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 11.sp, color: Colors.grey),
                              Padding(
                                padding: EdgeInsets.only(left: 3.w),
                                child: Text(dateTime, style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey)),
                              )
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                        child: Text(doc['comment'], style: GoogleFonts.inter(fontSize: 13.sp)),
                      )
                    ],
                  ),
                );
              }
          )
          : SizedBox(
            height: MediaQuery.of(context).size.height/1.3,
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


