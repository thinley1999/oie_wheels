import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/content/order_history.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  var date = DateTime.now();

  void _onPressed() {
    FirebaseFirestore.instance
        .collection("Order")
        .doc((_auth.currentUser)!.uid)
        .collection("PlaceOrder")
        .where('status', isEqualTo: 'placeOrder')
        .get()
        .then((value) {
      value.docs.forEach((result) {
        FirebaseFirestore.instance
            .collection('Order')
            .doc((_auth.currentUser)!.uid)
            .collection('ConfirmOrder')
            .doc(result.data()['oId'])
            .set({
          'sId': result.data()['sId'],
          'orderCount': result.data()['orderCount'],
          'price': result.data()['price'],
          'orderItem': result.data()['orderItem'],
          'size': result.data()['size'],
          'rating': 1.0,
          'isRated': false,
          'status': 'unassigned orders',
          'oId': result.data()['oId'],
          'orderFrom': result.data()['orderFrom'],
          'from': result.data()['from'],
          'dateTime': result.data()['dateTime'],
          'uid': result.data()['uid'],
        }).then((value) {
          FirebaseFirestore.instance
              .collection('Order')
              .doc((_auth.currentUser)!.uid)
              .collection('PlaceOrder')
              .doc(result.data()['oId'])
              .delete();
        });
        FirebaseFirestore.instance
            .collection('ItemRating')
            .doc(result.data()['oId'])
            .set({
          'sId': result.data()['sId'],
          'rating': 1.0,
          'isRated': false,
          'oId': result.data()['oId'],
          'orderFrom': result.data()['orderFrom'],
          'orderItem': result.data()['orderItem'],
          'dateTime': result.data()['dateTime'],
          'uid': result.data()['uid'],
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderHistory()));
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        _onPressed();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFE8EAF6),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.h),
          child: AppBar(
              leading: IconButton(
                icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
                onPressed: () {
                  _onPressed();
                },
              ),
              title: Text('Order Details', style: GoogleFonts.inter(
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
                .collection("PlaceOrder").where('status', isEqualTo: 'placeOrder').snapshots(),
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
              var ds = snapshot.data!.docs;
              DateTime formattedDate = DateTime.parse(ds[0]['dateTime']);
              String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);

              return Column(
                children: [
                  SizedBox(
                    height: 65.h,
                    child: Center(
                        child: Image.asset(
                          'assets/logo2.png',
                          width: 130.w,
                        )
                    ),
                  ),
                  Expanded(
                    child: RawScrollbar(
                      thumbColor: Colors.amber[900],
                      thickness: 5.sp,
                      isAlwaysShown: true,
                      child: ListView(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15.w),
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(3.sp),
                                topLeft: Radius.circular(3.sp),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.clock, size: 15.sp, color: Colors.grey),
                                    SizedBox(width: 10.w),
                                    Text(dateTime, style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey)),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2.sp),
                                    color: Colors.amber[600],
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                                  child: Text('ORDER PLACED', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w800)),
                                )
                              ],
                            ),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount:1,
                              itemBuilder: (context,index){
                                var doc1 = snapshot.data!.docs[index];
                                return FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance.collection("OrderHistory")
                                        .where('uid', isEqualTo: (_auth.currentUser)!.uid)
                                        .where("dateTime",isEqualTo: doc1["dateTime"]).get(),
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

                                            return Container(
                                              margin: EdgeInsets.symmetric(horizontal: 15.w),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE8EAF6),
                                                border: Border(
                                                  right: BorderSide(width: 0.8.w, color: Colors.grey.withOpacity(0.2.sp)),
                                                  left: BorderSide(width: 0.8.w, color: Colors.grey.withOpacity(0.2.sp)),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                        child: Text('Ordered Id:',style: GoogleFonts.inter(fontSize: 11.sp, color:Colors.grey, fontWeight: FontWeight.w800)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                        child: Text('Ordered By:',style: GoogleFonts.inter(fontSize: 11.sp, color:Colors.grey, fontWeight: FontWeight.w800)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                        child: Text('Address:',style: GoogleFonts.inter(fontSize: 11.sp, color:Colors.grey, fontWeight: FontWeight.w800)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                        child: Text('Contact no:',style: GoogleFonts.inter(fontSize: 11.sp, color:Colors.grey, fontWeight: FontWeight.w800)),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 20.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                          child: Text(doc['orderId'],style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w800)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                          child: Text(doc['orderBy'],style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w800)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                          child: Text(doc['deliveryAddress'],style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w800)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                          child: Text('+975-' + doc['phone'],style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w800)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                      );
                                    }
                                );
                              }),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15.w),
                            child: GroupedListView<dynamic, String>(
                              shrinkWrap: true,
                              elements: snapshot.data!.docs,
                              groupBy: (element) => element['orderFrom'],
                              groupSeparatorBuilder: (String groupByValue) {
                                return Row(
                                  children: [
                                    Flexible(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE8EAF6),
                                            border: Border(
                                              right: BorderSide(width: 0.8.w, color: Colors.grey.withOpacity(0.2.sp)),
                                              left: BorderSide(width: 0.8.w, color: Colors.grey.withOpacity(0.2.sp)),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(left: 10, right: 10),
                                                padding: EdgeInsets.symmetric(vertical: 5.h),
                                                child: Text(
                                                  groupByValue,
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    )
                                  ],
                                );
                              },
                              itemBuilder: (context, dynamic element) {
                                final price = element['price']*element['orderCount'];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(width: 0.5.w, color: Colors.black.withOpacity(0.8)),
                                    ),
                                  ),
                                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(element['orderItem'], style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                                          SizedBox(height: 2.h),
                                          Text('Qtn : ' + element['orderCount'].toString(), style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey)),
                                        ],
                                      ),
                                      Text(price.toString() + '.0', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800))
                                    ],
                                  ),
                                );
                              },
                              itemComparator: (item1, item2) => item1['orderItem'].compareTo(item2['orderItem']), // optional
                              useStickyGroupSeparators: true, // optional
                              floatingHeader: true, // optional
                              order: GroupedListOrder.ASC,
                            ),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount:1,
                              itemBuilder: (context,index){
                                var doc1 = snapshot.data!.docs[index];
                                return FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance.collection("OrderHistory")
                                    .where('uid', isEqualTo: (_auth.currentUser)!.uid)
                                        .where("dateTime",isEqualTo: doc1["dateTime"]).get(),
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
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 15.w),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border(
                                                      bottom: BorderSide(width: 0.8.w, color: Colors.black.withOpacity(0.8)),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(bottom: 10.h),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 10.h),
                                                            child: Text('Total Item Value',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800)),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 5.h),
                                                            child: Text('BST(if any)',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800)),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 5.h),
                                                            child: Text('Service Charges(if any)',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800)),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 5.h),
                                                            child: Text('Delivery Charges',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800)),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 5.h),
                                                            child: Text('Discount on Delivery Charges',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800)),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 5.h),
                                                            child: Text('Discount on Item',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800)),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 5.h),
                                                            child: Text('Packing Charges',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800)),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(width: 20.w),
                                                      Padding(
                                                        padding: EdgeInsets.only(right: 20.w),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 10.h),
                                                              child: Text(doc['total'],style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text(doc['bst'].toString(),style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text(doc['serviceCharge'] + '.0',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text(doc['deliveryCharge'] + '.0',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child:Text(doc['discountOnDC'],style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child:Text(doc['discountOnItem'],style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text(doc['packingCharge'],style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 15.w),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.circular(3.sp),
                                                      bottomLeft: Radius.circular(3.sp),
                                                    ),
                                                  ),
                                                  child: Material(
                                                    elevation: 2.sp,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(right: 10.w, top: 15.h, bottom: 15.h),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Text('Total Amount', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.amber[900])),
                                                          SizedBox(width: 30.w,),
                                                          Text(doc['from'] == 'restaurant'?'BTN ' + doc['totalAmount'].toString() : 'BTN ' + doc['totalAmount'].toString() + '.0', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.amber[900], fontWeight: FontWeight.w700))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                  child: Card(
                                                    elevation: 2.sp,
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Icon(FontAwesomeIcons.solidCreditCard, size: 20.sp),
                                                          SizedBox(width: 10.w),
                                                          Text(doc['paymentType'], style: GoogleFonts.inter(fontSize: 13.sp))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    FirebaseFirestore.instance
                                                        .collection("Order")
                                                        .doc((_auth.currentUser)!.uid)
                                                        .collection("PlaceOrder")
                                                        .where('status', isEqualTo: 'placeOrder')
                                                        .get()
                                                        .then((value) {
                                                      value.docs.forEach((result) {
                                                        FirebaseFirestore.instance
                                                            .collection('Order')
                                                            .doc((_auth.currentUser)!.uid)
                                                            .collection('ConfirmOrder')
                                                            .doc(result.data()['oId'])
                                                            .set({
                                                          'sId': result.data()['sId'],
                                                          'orderCount': result.data()['orderCount'],
                                                          'price': result.data()['price'],
                                                          'orderItem': result.data()['orderItem'],
                                                          'status': 'cancelled',
                                                          'oId': result.data()['oId'],
                                                          'orderFrom': result.data()['orderFrom'],
                                                          'from': result.data()['from'],
                                                          'dateTime': result.data()['dateTime'],
                                                          'uid': result.data()['uid'],
                                                        }).then((value) {
                                                          FirebaseFirestore.instance
                                                              .collection('Order')
                                                              .doc((_auth.currentUser)!.uid)
                                                              .collection('PlaceOrder')
                                                              .doc(result.data()['oId'])
                                                              .delete();
                                                        });
                                                        FirebaseFirestore.instance
                                                            .collection('OrderHistory')
                                                            .doc(doc['orderId'])
                                                            .update({
                                                          'status': 'cancelled'
                                                        });
                                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderHistory()));
                                                      });
                                                    });
                                                  },
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    color: Colors.red,
                                                    margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                                      child: Center(child: Text('CANCEL', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w800))),
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
                  )
                ],
              );
            }
        ),
      ),
    );
  }
}
