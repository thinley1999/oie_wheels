import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Rating extends StatefulWidget {
  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  double rating = 0.0;
  var _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("Order")
        .doc((_auth.currentUser)!.uid)
        .collection("View")
        .doc((_auth.currentUser)!.uid)
        .get().then((value){
      FirebaseFirestore.instance.collection("Rating5")
          .where('uid', isEqualTo: (_auth.currentUser)!.uid)
          .where("dateTime",isEqualTo: value.data()!['dateTime'])
          .get()
          .then((value) {
        value.docs.forEach((result){
          _comment.text = result.data()['comment'];
        });
      });
    });
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Rating', style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottomOpacity: 0.0,
          elevation: 0.0,
          backgroundColor: Color(0xFF1976D2),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Order")
            .doc((_auth.currentUser)!.uid)
            .collection("View").snapshots(),
        builder: (context,snapshot){
          if (!snapshot.hasData){
            return Center(child: SpinKitWave(
              size: 30.sp,
              color: Colors.amber[900],
              duration:  Duration(milliseconds: 800),
            ));
          }
          return RawScrollbar(
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
                          .collection("ItemRating")
                          .where('uid',isEqualTo: (_auth.currentUser)!.uid)
                          .where("dateTime",isEqualTo: userDocument['dateTime']).get(),
                      builder: (BuildContext context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: SizedBox(
                            height: MediaQuery.of(context).size.height/1.3,
                            child: SpinKitWave(
                              size: 30.sp,
                              color: Colors.amber[900],
                              duration:  Duration(milliseconds: 800),
                            ),
                          ));
                        }
                        return ListView(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              height: 150.h,
                              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/rating.jpg'
                                  ),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.75), BlendMode.dstATop),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 70.w,
                                          child: Divider(color: Colors.white,thickness: 1.sp)
                                      ),
                                      Text('ORDER RATING', style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                      SizedBox(
                                          width: 70.w,
                                          child: Divider(color: Colors.white,thickness: 1.sp)
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star, size: 40.sp, color: Colors.amber[700]),
                                      Icon(Icons.star, size: 40.sp, color: Colors.amber[700]),
                                      Icon(Icons.star, size: 40.sp, color: Colors.amber[700]),
                                      Icon(Icons.star, size: 40.sp, color: Colors.white60),
                                      Icon(Icons.star, size: 40.sp, color: Colors.white60),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 10.w),
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 70.w,
                                          child: Divider(color: Colors.black,thickness: 1.sp)
                                      ),
                                      Text('RATE RESTAURANT', style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.w600)),
                                      SizedBox(
                                          width: 70.w,
                                          child: Divider(color: Colors.black,thickness: 1.sp)
                                      ),
                                    ],
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount:1,
                                      itemBuilder: (context,index){
                                        var doc1 = snapshot.data!.docs[index];
                                        return FutureBuilder<QuerySnapshot>(
                                            future: FirebaseFirestore.instance.collection("Rating5")
                                                .where('uid', isEqualTo: (_auth.currentUser)!.uid)
                                                .where("dateTime",isEqualTo: doc1["dateTime"])
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
                                              }
                                              return ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: ClampingScrollPhysics(),
                                                  itemCount:snapshot.data!.docs.length,
                                                  itemBuilder: (context, index){
                                                    var doc = snapshot.data!.docs[index];
                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 10.h),
                                                          child: RatingBar.builder(
                                                              itemSize: 40.sp,
                                                              unratedColor: Colors.grey.withOpacity(0.5),
                                                              initialRating: doc['rating'],
                                                              minRating: 1,
                                                              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber[700]),
                                                              onRatingUpdate: (rating) {
                                                                setState(() {
                                                                  this.rating = rating;
                                                                });
                                                                FirebaseFirestore.instance.collection('Rating5').doc(doc['orderId']).update({
                                                                  'rating': rating,
                                                                });
                                                              }
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 80.h,
                                                          decoration: BoxDecoration(
                                                              color: Colors.grey.withOpacity(0.09),
                                                              border: Border.all(color: Colors.grey),
                                                              borderRadius: BorderRadius.circular(2.sp)
                                                          ),
                                                          margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
                                                          child: TextFormField(
                                                            keyboardType: TextInputType.multiline,
                                                            cursorColor: Colors.amber[900],
                                                            style: GoogleFonts.inter(fontSize: 13.sp),
                                                            textAlign: TextAlign.start,
                                                            controller: _comment,
                                                            decoration: InputDecoration(
                                                              hintText: 'Write your comments (optional)',
                                                              contentPadding: EdgeInsets.only(left: 10.w),
                                                              border: InputBorder.none,
                                                              focusedBorder: InputBorder.none,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  }
                                              );
                                            }
                                        );
                                      }),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 70.w,
                                          child: Divider(color: Colors.black,thickness: 1.sp)
                                      ),
                                      Text('RATE INDIVIDUAL ITEM', style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.w600)),
                                      SizedBox(
                                          width: 70.w,
                                          child: Divider(color: Colors.black,thickness: 1.sp)
                                      ),
                                    ],
                                  ),
                                  ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        var doc = snapshot.data!.docs[index];
                                        return  Padding(
                                          padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(doc['orderItem'], style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black)),
                                              RatingBar.builder(
                                                  itemSize: 20.sp,
                                                  unratedColor: Colors.grey.withOpacity(0.5),
                                                  initialRating: doc['rating'],
                                                  minRating: 1,
                                                  itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber[700]),
                                                  onRatingUpdate: (rating) {
                                                    setState(() {
                                                      this.rating = rating;
                                                    });
                                                    FirebaseFirestore.instance.collection('ItemRating').doc(doc['oId']).update({
                                                      'rating': rating,
                                                      'isRated': true,
                                                    });
                                                  }
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 120.w),
                              child: FlatButton.icon(
                                onPressed: () async{
                                  FirebaseFirestore.instance.collection('Rating5').doc(userDocument['orderId']).update({
                                    'comment': _comment.text,
                                    'isRated': true,
                                  });
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.check, color: Colors.white, size: 20.sp,),
                                label: Text('SUBMIT',style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp)),
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        );
                      }
                  );
                }),
          );
        },
      ),
    );
  }
}
