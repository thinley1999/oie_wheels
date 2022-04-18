import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/content/order_details2.dart';
import 'package:oie_wheels/content/payment.dart';
import 'package:oie_wheels/content/track_order.dart';
import 'package:oie_wheels/navbar/rating.dart';
import 'package:oie_wheels/pages/home.dart';


class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  var date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
              onPressed: () =>  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false),
            ),
            title: Text('Order History', style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0, backgroundColor: Color(0xFF1976D2)
        ),
      ),
      body: Column(
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
            child: StreamBuilder<QuerySnapshot>(
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
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 0),
                                padding: EdgeInsets.only(left: 10.w, top: 3.h, bottom: 3.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(width: 1.w, color: Colors.grey),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.h),
                                      child: Row(
                                        children: [
                                          Icon(FontAwesomeIcons.clock, size: 15.sp, color: Colors.grey),
                                          SizedBox(width: 10.w),
                                          Text(dateTime, style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    (doc['status'] == 'unassigned orders' || doc['status'] == 'order confirm' || doc['status'] == 'being prepared' || doc['status'] == 'on the way')
                                        ? GestureDetector(
                                      onTap: () {
                                        FirebaseFirestore.instance.collection('Order').doc((_auth.currentUser)!.uid).collection('View').doc((_auth.currentUser)!.uid).set({
                                          'dateTime': doc['dateTime'],
                                          'orderId': doc['orderId'],
                                          'status': doc['status']
                                        });
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => TrackOrder()));
                                      },
                                      child: Container(
                                        color: Colors.green,
                                        margin: EdgeInsets.only(right: 5.w),
                                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.location_on, size: 15.sp, color: Colors.white),
                                            SizedBox(width: 3.w),
                                            Text('Track', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w700))
                                          ],
                                        ),
                                      ),
                                    )
                                        :(doc['status'] == 'delivered')
                                        ? GestureDetector(
                                      onTap: () {
                                        FirebaseFirestore.instance.collection('Order').doc((_auth.currentUser)!.uid).collection('View').doc((_auth.currentUser)!.uid).set({
                                          'dateTime': doc['dateTime'],
                                          'orderId': doc['orderId'],
                                          'status': doc['status']
                                        });
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Rating()));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 1.w),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.star, size: 20.sp, color: Colors.amber[900]),
                                            SizedBox(width: 3.w),
                                            Text('Rate Now', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.amber[900], fontWeight: FontWeight.w700))
                                          ],
                                        ),
                                      ),
                                    )
                                        : SizedBox()
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                padding: EdgeInsets.fromLTRB(10.w, 5.h, 0, 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(width: 1.w, color: Colors.grey),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(doc['orderFrom'], style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                                        Padding(
                                          padding: EdgeInsets.only(top: 2.h),
                                          child: Text(doc['from'] == 'restaurant'? 'Amount: BTN ' + doc['totalAmount'].toString() + '0' : 'Amount: BTN ' + doc['totalAmount'].toString() + '.00', style: GoogleFonts.inter(fontSize: 11.sp, color:Colors.grey)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 2.h),
                                          child: Text('Payment Type: ' + doc['paymentType'], style: GoogleFonts.inter(fontSize: 11.sp, color:Colors.grey)),
                                        ),
                                        Row(children: [
                                          Text('Order no: ' + doc['orderId'], style: GoogleFonts.inter(fontSize: 11.sp, color:Colors.grey)),
                                          SizedBox(width: 5.w),
                                          (doc['paymentType'] == 'Bank' && doc['status'] != 'cancelled')
                                              ? Padding(
                                            padding: EdgeInsets.only(top: 2.h),
                                            child: GestureDetector(
                                              onTap: () {
                                                if(doc['received from customer'] == 0) {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Payment()));
                                                  FirebaseFirestore.instance
                                                      .collection('EditItem').doc((_auth.currentUser)!.uid)
                                                      .collection('StoreItem').doc((_auth.currentUser)!.uid)
                                                      .set({
                                                    'dateTime': doc['dateTime'],
                                                    'orderId': doc['orderId'],
                                                    'jrnlNo': doc['jrnlNo'],
                                                    'received from customer': doc['received from customer'],
                                                    'totalAmount': doc['totalAmount'],
                                                  });
                                                } else if(doc['received from customer'] < doc['totalAmount']) {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => PartiallyPaid()));
                                                  FirebaseFirestore.instance
                                                      .collection('EditItem').doc((_auth.currentUser)!.uid)
                                                      .collection('StoreItem').doc((_auth.currentUser)!.uid)
                                                      .set({
                                                    'dateTime': doc['dateTime'],
                                                    'orderId': doc['orderId'],
                                                    'jrnlNo': doc['jrnlNo'],
                                                    'received from customer': doc['received from customer'],
                                                    'totalAmount': doc['totalAmount'],
                                                  });
                                                } else {
                                                  print('paid');
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                                                color: (doc['received from customer'] >= doc['totalAmount']) ? Colors.blue : (doc['received from customer'] == 0) ? Colors.green: Colors.amber,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Icon(FontAwesomeIcons.solidCreditCard, size: 15.sp, color: Colors.white),
                                                    SizedBox(width: 10.w),
                                                    Text((doc['received from customer'] >= doc['totalAmount'])?'PAID' : (doc['received from customer'] == 0) ? 'PAY' : 'PARTIALLY PAID', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w800)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                              : SizedBox(),
                                          SizedBox(width: 5.w),
                                          (doc['status'] == 'unassigned orders')
                                              ? Padding(
                                            padding: EdgeInsets.only(top: 2.h),
                                            child: GestureDetector(
                                              onTap: () {
                                                FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                  'status': 'cancelled'
                                                });
                                                if(doc['from'] == 'restaurant') {
                                                  FirebaseFirestore.instance
                                                      .collection("Order")
                                                      .doc((_auth.currentUser)!.uid)
                                                      .collection("ConfirmOrder")
                                                      .where('dateTime', isEqualTo: doc['dateTime'])
                                                      .get()
                                                      .then((value) {
                                                    value.docs.forEach((result) {
                                                      FirebaseFirestore.instance
                                                          .collection('Order')
                                                          .doc((_auth.currentUser)!.uid)
                                                          .collection('ConfirmOrder')
                                                          .doc(result.data()['oId'])
                                                          .update({
                                                        'status': 'cancelled',
                                                      });
                                                    });
                                                  });
                                                } else {
                                                  FirebaseFirestore.instance
                                                      .collection("Order")
                                                      .doc((_auth.currentUser)!.uid)
                                                      .collection("ConfirmOrder")
                                                      .where('dateTime', isEqualTo: doc['dateTime'])
                                                      .get()
                                                      .then((value) {
                                                    value.docs.forEach((result) {
                                                      FirebaseFirestore.instance
                                                          .collection('Order')
                                                          .doc((_auth.currentUser)!.uid)
                                                          .collection('ConfirmOrder')
                                                          .doc(result.data()['oId'])
                                                          .update({
                                                        'status': 'cancelled',
                                                      });
                                                      for(int i = 0; i<value.docs.length; i++) {
                                                        var sId = value.docs[i]['sId'];
                                                        var size = value.docs[i]['size'];
                                                        int quantity = value.docs[i]['orderCount'];

                                                        FirebaseFirestore.instance
                                                            .collection("StoreItem2").doc(sId)
                                                            .get().then((value){
                                                          for(int j =0; j<value.data()!['size'].length; j++) {
                                                            var array = [];
                                                            var array2 = [{'size': value.data()!["size"][j]["size"], 'quantity': value.data()!["size"][j]["quantity"],}];
                                                            if(size == value.data()!["size"][j]["size"]) {
                                                              array = [{'size': value.data()!["size"][j]["size"], 'quantity': value.data()!["size"][j]["quantity"] + quantity,}];
                                                            } else {
                                                              array = [{'size': value.data()!["size"][j]["size"], 'quantity': value.data()!["size"][j]["quantity"],}];
                                                            }
                                                            FirebaseFirestore.instance.collection('StoreItem2').doc(sId).update({
                                                              'size': FieldValue.arrayRemove(array2),
                                                            }).then((value) => {
                                                              FirebaseFirestore.instance.collection('StoreItem2').doc(sId).update({
                                                                'size': FieldValue.arrayUnion(array),
                                                              })
                                                            });
                                                          }
                                                        });
                                                      }
                                                    });
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                                                color: Colors.grey,
                                                child: Text('CANCEL', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w800)),
                                              ),
                                            ),
                                          )
                                              : (doc['status'] == 'cancelled')
                                              ? Padding(
                                            padding: EdgeInsets.only(top: 2.h),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                                                color: Colors.red,
                                                child: Text('CANCELLED', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w800)),
                                              ),
                                            ),
                                          )
                                              : SizedBox()
                                        ]),
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance.collection('Order').doc((_auth.currentUser)!.uid).collection('View').doc((_auth.currentUser)!.uid).set({
                                            'dateTime': doc['dateTime'],
                                            'orderId': doc['orderId'],
                                            'status': doc['status']
                                          });
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetails2()));
                                        },
                                        icon: Icon(Icons.chevron_right, size: 30.sp, color: Colors.grey)
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(width: 1.w, color: Colors.grey),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Total', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                                        Text('Delivery Charges', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                                        Text('Discount on Delivery Charges', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                                        Text('Discount on Item', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                    SizedBox(width: 20.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(doc['total'] + '0', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey)),
                                        Text(doc['deliveryCharge'] + '.00', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey)),
                                        Text(doc['discountOnDC'] + '0', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey)),
                                        Text(doc['discountOnItem'] + '0', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('Total Amount', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                                    SizedBox(width: 50.w),
                                    Text(doc['from'] == 'restaurant' ? 'BTN ' + doc['totalAmount'].toString() + '0' : 'BTN ' + doc['totalAmount'].toString() + '.00', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }
                  )
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
            ),
          ),
        ],
      )
      ,
    );
  }
}
