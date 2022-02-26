import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/driver/direction.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
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
            title: Text('Order Details', style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0, backgroundColor: Color(0xFF1976D2)
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("EditItem")
            .doc((_auth.currentUser)!.uid)
            .collection("StoreItem").snapshots(),
        builder: (context,snapshot){
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState){
            case ConnectionState.waiting:
              return Center(
                  child: SpinKitWave(
                size: 30.sp,
                color: Colors.amber[900],
                duration:  Duration(milliseconds: 800),
              ));
            default:return Column(
              children: [
                SizedBox(
                  height: 65.h,
                  child: Center(
                      child: Image.asset(
                        'assets/logo1.png',
                        width: 110.w,
                      )
                  ),
                ),
                Expanded(
                  child: RawScrollbar(
                    thumbColor: Colors.amber[900],
                    thickness: 5.sp,
                    isAlwaysShown: true,
                    child: ListView.builder(
                      shrinkWrap: true,
                        itemCount:snapshot.data!.docs.length,
                        itemBuilder: (_,index){
                          var userDocument = snapshot.data!.docs[index];
                          DateTime formattedDate = DateTime.parse(userDocument['dateTime']);
                          String dateTime = DateFormat.yMMMMd('en_US').add_jm().format(formattedDate);

                          return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("Order")
                                  .doc(userDocument['uid'])
                                  .collection('ConfirmOrder')
                                  .where("dateTime",isEqualTo: userDocument['dateTime']).get(),
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
                                return ListView(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
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
                                        children: [
                                          Icon(FontAwesomeIcons.clock, size: 15.sp, color: Colors.grey),
                                          SizedBox(width: 10.w),
                                          Text(dateTime, style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey)),
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
                                                  .where('uid',isEqualTo: userDocument['uid'])
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
                                                                Padding(
                                                                  padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                                  child: Text('Order Status:',style: GoogleFonts.inter(fontSize: 11.sp, color:Colors.grey, fontWeight: FontWeight.w800)),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(width: 20.w),
                                                            Column(
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
                                                                Padding(
                                                                  padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                                                  child: Text(doc['status'],style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.green, fontWeight: FontWeight.w800)),
                                                                ),
                                                              ],
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
                                                  .where('uid', isEqualTo: userDocument['uid'])
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
                                                                        child:Text(doc['discountOnDC'] + '.0',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
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
                                                                padding: EdgeInsets.only(right: 10.w, top: 10.h, bottom: 15.h),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    Text('Total Amount', style: GoogleFonts.inter(fontSize: 15.sp,)),
                                                                    SizedBox(width: 30.w,),
                                                                    Text('BTN ' + doc['totalAmount'].toString(), style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700))
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
                                                          Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 10.w,),
                                                            child: Card(
                                                              elevation: 2.sp,
                                                              child: Padding(
                                                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('Status', style: GoogleFonts.inter(fontSize: 13.sp)),
                                                                    Row(
                                                                      children: [
                                                                        Text(doc['status'].toUpperCase(), style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.lightBlue[900], fontWeight: FontWeight.bold)),
                                                                        Icon(Icons.arrow_drop_down, size: 25.sp,)
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          (doc['from'] == 'restaurant') ? GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return Dialog(
                                                                      child: Container(
                                                                        height: 150.h,
                                                                        width: MediaQuery.of(context).size.width,
                                                                        child: Form(
                                                                          key: _formKey,
                                                                          child: Stack(
                                                                            children: [
                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                                                    child: Text('Amount Paid To Restaurant',
                                                                                      style: GoogleFonts.inter(
                                                                                          fontSize: 16.sp,
                                                                                          color: Colors.black,
                                                                                          fontWeight: FontWeight.w800
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Text('Please Type Amount', style: GoogleFonts.inter(fontSize: 13.sp)),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                                                    child: TextFormField(
                                                                                      style: GoogleFonts.inter(fontSize: 13.sp),
                                                                                      textAlign: TextAlign.start,
                                                                                      controller: _amountController,
                                                                                      keyboardType: TextInputType.number,
                                                                                      decoration: InputDecoration(
                                                                                        contentPadding: EdgeInsets.only(left: 10.w),
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(0),
                                                                                        ),
                                                                                        errorBorder: OutlineInputBorder(
                                                                                          borderSide: BorderSide(color: Colors.red),
                                                                                          borderRadius: BorderRadius.circular(0),
                                                                                        ),
                                                                                      ),
                                                                                      validator: (String ? value) {
                                                                                        if(value!.isEmpty) {
                                                                                          return 'please enter amount';
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  GestureDetector(
                                                                                    onTap: () {
                                                                                      if(_formKey.currentState!.validate()) {
                                                                                        _formKey.currentState!.save();
                                                                                        FirebaseFirestore.instance.collection('OrderHistory').doc(doc['orderId']).update({
                                                                                          'paid to ros': int.parse(_amountController.text),
                                                                                        }).then((value) {
                                                                                          Navigator.pop(context);
                                                                                          Fluttertoast.showToast(
                                                                                              msg: 'Amount paid to restaurant success!!!',
                                                                                              gravity: ToastGravity.CENTER,
                                                                                              timeInSecForIosWeb: 1,
                                                                                              backgroundColor: Colors.red,
                                                                                              textColor: Colors.white,
                                                                                              fontSize: 13.sp
                                                                                          );
                                                                                        });
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                      color: Color(0xFF1976D2),
                                                                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                                                                                      child: Text('SUBMIT', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Positioned(
                                                                                right: 0,
                                                                                child: IconButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  icon: Icon(Icons.clear, size: 25.sp,),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                              );
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                              width: MediaQuery.of(context).size.width,
                                                              color: Colors.amber[900],
                                                              padding: EdgeInsets.symmetric(vertical: 10.h),
                                                              child: Text('AMOUNT PAID TO RESTAURANT', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                                                            ),
                                                          )
                                                              : SizedBox(),
                                                          GestureDetector(
                                                            onTap: () async{
                                                              List<Location> locations = await locationFromAddress(doc['deliveryAddress']);
                                                              var lat = locations.first.latitude;
                                                              var lon = locations.first.longitude;

                                                              FirebaseFirestore.instance.collection('EditItem').doc((_auth.currentUser)!.uid).collection('Direction').doc((_auth.currentUser)!.uid).set({
                                                               'lat': lat,
                                                               'lon': lon,
                                                              });
                                                              Navigator.push(context, MaterialPageRoute(builder: (context) => Direction1()));
                                                            },
                                                            child: Container(
                                                              color: Color(0xFF1976D2),
                                                              margin: EdgeInsets.symmetric(vertical: 10.h),
                                                              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                                                              child: Text('DIRECTION', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                );
                                              }
                                          );
                                        }),
                                  ],
                                );
                              }
                          );
                        }),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
