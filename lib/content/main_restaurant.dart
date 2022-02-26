import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/content/restaurant.dart';
import 'package:oie_wheels/content/store.dart';
import 'package:scroll_indicator/scroll_indicator.dart';


class MainRestaurant extends StatefulWidget {
  @override
  _MainRestaurantState createState() => _MainRestaurantState();
}

class _MainRestaurantState extends State<MainRestaurant> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  @override
  void initState() {
    super.initState();
    dataList = FirebaseFirestore.instance.collection('Restaurant').orderBy('restaurantName', descending: false).snapshots();
  }

  var date = DateTime.now();
  DateFormat dateFormat = DateFormat.Hm();

  var dataList;
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        dataList = FirebaseFirestore.instance.collection('Restaurant').orderBy('restaurantName', descending: false).snapshots();
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue = value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      dataList(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['restaurantName'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  final controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Container(
              padding: EdgeInsets.only(bottom: 10.h),
              child: TextFormField(
                style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 15.h),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  hintText: "Search Restaurant",
                  hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white),
                ),
                onChanged: (val) {
                  initiateSearch(val);
                  setState(() {
                    dataList = FirebaseFirestore.instance
                        .collection('Restaurant')
                        .where('searchKey',
                        isEqualTo: val.substring(0, 1).toUpperCase())
                        .snapshots();
                  });
                },
              ),
            ),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0, backgroundColor: Color(0xFF1976D2)
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('CuisineType').orderBy('cuisineType', descending: false).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    SizedBox(
                      height: 220.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 0),
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          controller: controller,
                          itemBuilder: (BuildContext context, int index) {
                            final document = snapshot.data!.docs[index];
                            return Card(
                              elevation: 5,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Ink.image(
                                    image: NetworkImage(
                                        document['imageUrl']
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        FirebaseFirestore.instance.collection('View').doc((_auth.currentUser)!.uid).collection('Restaurant').doc((_auth.currentUser)!.uid).set(
                                            {
                                              'cuisineType': document['cuisineType'],
                                            }
                                        );
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Restaurant()));
                                      },
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    width: size.width,
                                    color: Color.fromRGBO(0, 0, 0, 0.4),
                                    child: Text(
                                      document['cuisineType'],
                                      style: GoogleFonts.cinzel(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: snapshot.data!.docs.length,
                        ),
                      ),
                    ),
                    ScrollIndicator(
                      scrollController: controller,
                      width: 50.w,
                      height: 10.h,
                      indicatorWidth: 20.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.sp),
                          color: Colors.grey[400]),
                      indicatorDecoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(10.sp)),
                    ), 
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: dataList,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return AlphabetScrollView(
                                list: snapshot.data!.docs.map((e) => AlphaModel(e['restaurantName'])).toList(),
                                alignment: LetterAlignment.right,
                                itemExtent: 35.h,
                                selectedTextStyle: GoogleFonts.inter(fontSize: 16.sp),
                                unselectedTextStyle: GoogleFonts.inter(fontSize: 16.sp),
                                overlayWidget: (value) => Container(
                                  height: 40.h,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF1976D2),
                                      borderRadius: BorderRadius.circular(5.sp)
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$value'.toUpperCase(),
                                    style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                itemBuilder: (_, k, id) {
                                  var document = snapshot.data!.docs[k];

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

                                  return ListTile(
                                    title: Text('$id', style: GoogleFonts.inter(fontSize: 16.sp)),
                                    leading: Container(
                                      height: 30.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber[900],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${document['searchKey']}'.toUpperCase(),
                                        style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    onTap: () {
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
                                  );
                                }
                            );
                          }
                          return Center(
                            child: SpinKitWave(
                              size: 30.sp,
                              color: Colors.amber[900],
                              duration:  Duration(milliseconds: 800),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return Center(
                child: SpinKitWave(
                  size: 30.sp,
                  color: Colors.amber[900],
                  duration:  Duration(milliseconds: 800),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

