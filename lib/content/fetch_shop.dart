import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/content/fetch_shop_dialog.dart';

class FetchShop extends StatefulWidget {
  final List<DocumentSnapshot> s_list;
  final int index;

  const FetchShop({Key? key, required this.s_list, required this.index}) : super(key: key);
  @override
  _FetchShopState createState() => _FetchShopState();
}

class _FetchShopState extends State<FetchShop> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection("StoreItem2").where("shopItemType",isEqualTo: widget.s_list[widget.index]["shopItemType"].toString()).get(),
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
          return snapshot.data!.docs.isNotEmpty ? GridView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              childAspectRatio: 0.65,
            ),
              itemBuilder: (context, index) {
                List<dynamic> image = snapshot.data!.docs[index]['imageUrl'];
                var doc = snapshot.data!.docs[index];
                return Container(
                  margin: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 0),
                  child: Column(
                    children: [
                      Container(
                        height: 150.h,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3.w)
                        ),
                        child: CarouselSlider.builder(
                            itemCount: image.length,
                            slideBuilder: (index){
                              return Image.network(
                                image[index],
                                fit: BoxFit.cover,
                              );
                            },
                          slideTransform: CubeTransform(rotationAngle: 0),
                          slideIndicator: CircularSlideIndicator(
                            indicatorBackgroundColor: Color.fromRGBO(0, 0, 0, 0.4),
                            currentIndicatorColor: Color.fromRGBO(1, 1, 1, 0.9),
                            indicatorRadius: 4.sp,
                            itemSpacing: 10.sp,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FirebaseFirestore.instance.collection('View').doc((_auth.currentUser)!.uid).collection('StoreItem1').doc((_auth.currentUser)!.uid).set({
                            'refId': doc['refId'],
                            'shopName': widget.s_list[widget.index]["shopName"].toString(),
                            'shopItemType': widget.s_list[widget.index]["shopItemType"].toString(),
                          });
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 20.w, top: 20.h, right: 20.w),
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection("View")
                                          .doc((_auth.currentUser)!.uid)
                                          .collection("StoreItem1").snapshots(),
                                      builder: (context,snapshot){
                                        if (snapshot.hasError)
                                          return new Text('Error: ${snapshot.error}');
                                        switch (snapshot.connectionState){
                                          case ConnectionState.waiting:
                                            return  Container(
                                              height: 200.0,
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
                                              ),
                                            );
                                          default:
                                            return ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:snapshot.data!.docs.length,
                                                itemBuilder: (_,index){
                                                  List<DocumentSnapshot> userDocument = snapshot.data!.docs;
                                                  return FetchShopDialog(d_list: userDocument,index: index);
                                                });
                                        }
                                      },
                                    )
                                  ),
                                );
                              }
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(doc['shopItemName'], style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                                Text('Nu. '+doc['price'] +'.00', style: GoogleFonts.inter(fontSize: 13.sp)),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
          )
          :SizedBox(
            height: MediaQuery.of(context).size.height / 1.3,
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
