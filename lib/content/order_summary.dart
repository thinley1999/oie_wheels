import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/content/order_details.dart';
import 'dart:math' show cos, sqrt, asin;

const kGoogleApiKey = 'AIzaSyAroZNzwV9wOTEmpREoKmkw-XpYTGZN_Xc';

class OrderSummary extends StatefulWidget {
  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  var date = DateTime.now();
  String dateTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  bool check = true;
  bool visibility = false;
  bool notification = false;
  bool change = false;
  var selectedPayment;

  List<String> payment = ['Cash on Delivery', 'Bank'];

  void _onPressed() {
    FirebaseFirestore.instance
        .collection("Order")
        .doc((_auth.currentUser)!.uid)
        .collection("Item")
        .where('status', isEqualTo: 'draft')
        .get()
        .then((value) {
      value.docs.forEach((result) {
        FirebaseFirestore.instance
            .collection('Order')
            .doc((_auth.currentUser)!.uid)
            .collection('PlaceOrder')
            .doc(result.data()['oId'])
            .set({
          'sId': result.data()['sId'],
          'orderCount': result.data()['orderCount'],
          'price': result.data()['price'],
          'orderItem': result.data()['orderItem'],
          'size': result.data()['size'],
          'status': 'placeOrder',
          'oId': result.data()['oId'],
          'orderFrom': result.data()['orderFrom'],
          'from': result.data()['from'],
          'dateTime': dateTime,
          'uid': result.data()['uid'],
        }).then((value) {
          FirebaseFirestore.instance
              .collection('Order')
              .doc((_auth.currentUser)!.uid)
              .collection('Item')
              .doc(result.data()['oId'])
              .delete();
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderDetails()));
      });
    });
  }

  final _formKey= GlobalKey<FormState>();

  List<String> screenShot = [];

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    super.initState();
    _setting();
  }

  void _setting(){
    FirebaseFirestore.instance.collection('Setting').doc('16031999').get().then((value){
      freeDistance = value.data()!['freeDistance'];
      sCharge = value.data()!['deliveryCharge'];
      sCharge2 = value.data()!['deliveryCharge2'];
      lat1 = value.data()!['lat'];
      lon1 = value.data()!['lon'];
      minDistance = value.data()!['minDistance'];
    });
    FirebaseFirestore.instance
        .collection("Order")
        .doc((_auth.currentUser)!.uid)
        .collection("Item")
        .where('status', isEqualTo: 'draft')
        .get()
        .then((value) {
      value.docs.forEach((result){
       FirebaseFirestore.instance
            .collection("RestaurantDiscount")
            .where('restaurantName', isEqualTo: result.data()['orderFrom'])
            .where('category', isEqualTo: result.data()['itemType'])
            .get()
            .then((value){
          value.docs.forEach((result1) {
            if(result1.data()['discount'] != 0 && date.isAfter(DateTime.parse(result.data()['startDate'])) && date.isBefore(DateTime.parse(result1.data()['endDate']))){
              num value = result1.data()['discount'];
              sum = sum + value;
            }
          });
        });
       FirebaseFirestore.instance
           .collection("ShopDiscount")
           .where('shopName', isEqualTo: result.data()['orderFrom'])
           .where('category', isEqualTo: result.data()['itemType'])
           .get()
           .then((value){
         value.docs.forEach((result1) {
           if(result1.data()['discount'] != 0 && date.isAfter(DateTime.parse(result.data()['startDate'])) && date.isBefore(DateTime.parse(result1.data()['endDate']))){
             num value = result1.data()['discount'];
             sum = sum + value;
           }
         });
       });
       FirebaseFirestore.instance
           .collection("StoreItem1")
           .where('restaurantName', isEqualTo: result.data()['orderFrom'])
           .where('itemType', isEqualTo: result.data()['itemType'])
           .get()
           .then((value){
         value.docs.forEach((result1) {
           if(result1.data()['discount2'] != '0' && date.isAfter(DateTime.parse(result.data()['startDate2'])) && date.isBefore(DateTime.parse(result1.data()['endDate2']))){
             num value = int.parse(result1.data()['discount2']);
             sum2 = sum2 + value;
           }
         });
       });
       FirebaseFirestore.instance
           .collection("StoreItem1")
           .where('shopName', isEqualTo: result.data()['orderFrom'])
           .where('shopItemType', isEqualTo: result.data()['itemType'])
           .get()
           .then((value){
         value.docs.forEach((result1) {
           if(result1.data()['discount2'] != '0' && date.isAfter(DateTime.parse(result.data()['startDate2'])) && date.isBefore(DateTime.parse(result1.data()['endDate2']))){
             num value = int.parse(result1.data()['discount2']);
             sum2 = sum2 + value;
           }
         });
       });
      });
    });
  }

  var freeDistance;
  var sCharge;
  var sCharge2;
  var lat1;
  var lon1;
  var lat2;
  var lon2;
  var deliveryAddress;
  var restaurantDiscount;
  var minDistance;
  num sum = 0.0;
  num sum2 = 0.0;

  final TextEditingController _location = TextEditingController();
  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'Unknown error'),
      ),
    );
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
            title: Text('Order Summary', style: GoogleFonts.inter(
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
            .collection("Item").where('status', isEqualTo: 'draft').snapshots(),
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
            var dsLength = snapshot.data!.docs.length;

            double itemValue = 0.00;
            double packingPrice = 0.00;
            double discountOnItem = 0.00;

            for(int i=0; i<ds.length;i++) itemValue+=(ds[i]['price']*ds[i]['orderCount']).toDouble();
            for(int i=0; i<ds.length;i++) packingPrice+=(ds[i]['packingPrice']*ds[i]['orderCount']).toDouble();
            for(int i=0; i<ds.length;i++) discountOnItem+=(
                (ds[i]['discount'] != 0 && date.isAfter(DateTime.parse(ds[i]['startDate'])) && date.isBefore(DateTime.parse(ds[i]['endDate']))) ?
                ds[i]['discount']/100*ds[i]['price']*ds[i]['orderCount'] : 0
            ).toDouble();
              return Form(
              key: _formKey,
              child: Column(
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
                            padding: EdgeInsets.only(left: 10.w, top: 10.h),
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
                            margin: EdgeInsets.symmetric(horizontal: 15.w),
                            color: Colors.white,
                            child: GroupedListView<dynamic, String>(
                              shrinkWrap: true,
                              elements: snapshot.data!.docs,
                              groupBy: (element) => element['orderFrom'],
                              groupSeparatorBuilder: (String groupByValue) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: Row(
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
                                                  padding: EdgeInsets.symmetric(vertical: 10.h),
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
                                  ),
                                );
                              },
                              itemBuilder: (context, dynamic element) {
                                final price = element['price']*element['orderCount'];
                                return Container(
                                  decoration: BoxDecoration(
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
                                return (doc1['from'] == 'restaurant')
                                    ?FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance.collection("Restaurant").where("restaurantName",isEqualTo: doc1["orderFrom"]).get(),
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

                                            DateTime startDate = DateTime.parse(doc['startDate']);
                                            DateTime endDate = DateTime.parse(doc['endDate']);
                                            var discount = int.parse(doc['discount']);

                                            var bst = int.parse(doc['bst']);
                                            var serviceCharge = int.parse(doc['serviceCharge']);

                                            double dsToRestaurant = 0;
                                            double restaurantToCustomer = 0;
                                            double totalDistance = 0;
                                            int pricePerKm = sCharge;
                                            int pricePerKm2 = sCharge2;
                                            dsToRestaurant += calculateDistance(doc['lat'], doc['lon'], lat1, lon1);
                                            restaurantToCustomer += (change == false) ? calculateDistance(doc['lat'], doc['lon'], doc1['lat'], doc1['lon'])
                                            : calculateDistance(doc['lat'], doc['lon'], lat2, lon2);
                                            totalDistance = (dsToRestaurant < freeDistance) ? restaurantToCustomer : dsToRestaurant + restaurantToCustomer;
                                            var charge = (totalDistance.round() < minDistance) ? totalDistance.round() * pricePerKm : totalDistance.round() * pricePerKm2;

                                            var mainBst = bst/100*itemValue;

                                            var discountOnDc;
                                            if(discount != 0 && date.isAfter(startDate) && date.isBefore(endDate)) {
                                              discountOnDc = discount/100*charge;
                                            }else if(sum != 0){
                                              discountOnDc = ((sum/100)/dsLength)*charge;
                                            }else if(sum2 != 0){
                                              discountOnDc = ((sum2/100)/dsLength)*charge;
                                            }else {
                                              discountOnDc = 0.0;
                                            }
                                            var mainDeliveryCharge = charge - discountOnDc;
                                            var totalAmount = itemValue + mainBst + serviceCharge + mainDeliveryCharge + packingPrice - discountOnItem;

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
                                                              child: Text('$itemValue',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text('$mainBst',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text(doc['serviceCharge'] + '.0',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text('$charge' + '.0',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child:Text('$discountOnDc',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text('$discountOnItem',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text('$packingPrice',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
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
                                                          Text('BTN ' + '$totalAmount', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.amber[900], fontWeight: FontWeight.w700))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                  child: Card(
                                                    elevation: 2.sp,
                                                    child: DropdownButtonFormField(
                                                      icon: Icon(Icons.arrow_drop_down_sharp, color: Color(0xFF1976D2)),
                                                      iconSize: 30.sp,
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
                                                      hint: Text(
                                                        'Select Payment Type',
                                                        style: GoogleFonts.inter(fontSize: 13.sp),
                                                      ),
                                                      value: selectedPayment,
                                                      isExpanded: true,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          selectedPayment = newValue;
                                                        });
                                                      },
                                                      items: payment.map((value) {
                                                        return DropdownMenuItem(
                                                          child: Text(value),
                                                          value: value,
                                                        );
                                                      }).toList(),
                                                      validator: (value) {
                                                        if (value == null) {
                                                          return 'please select payment type';
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                                                  child: Card(
                                                    elevation: 2.sp,
                                                    child: Padding(
                                                      padding: EdgeInsets.fromLTRB(10.w, 5.h, 0, 5.h),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                height: 30.h,
                                                                width: 30.w,
                                                                child: Transform.scale(
                                                                  scale: 1.2.sp,
                                                                  child: Checkbox(
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        this.check = value!;
                                                                        change = false;
                                                                      });
                                                                      if(visibility == false) {
                                                                        setState(() {
                                                                          visibility = true;
                                                                        });
                                                                      } else {
                                                                        visibility = false;
                                                                      }
                                                                    },
                                                                    value: check,
                                                                    activeColor: const Color(0xFF1976D2),
                                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 5.w),
                                                              Text('Current Location as delivery address', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),)
                                                            ],
                                                          ),
                                                          Visibility(
                                                            visible: visibility,
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(bottom: 5.h),
                                                                    child: Text('Delivery Address', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w600)),
                                                                  ),
                                                                  Container(
                                                                    height: MediaQuery.of(context).size.height/14,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(2.sp),
                                                                        border: Border.all(color: Color(0xffBDBDBD))),
                                                                    child: Padding(
                                                                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                                                                      child: TextFormField(
                                                                        minLines: 1,
                                                                        maxLines: 5,
                                                                        keyboardType: TextInputType.multiline,
                                                                        style: GoogleFonts.inter(fontSize: 13.sp),
                                                                        controller: _location,
                                                                        onTap: () async{
                                                                          var place = await PlacesAutocomplete.show(
                                                                            context: context,
                                                                            apiKey: kGoogleApiKey,
                                                                            onError: onError,
                                                                            mode: Mode.overlay,
                                                                            language: 'en',
                                                                            components: [Component(Component.country, 'bt')],
                                                                          );
                                                                          if(place != null){
                                                                            final plist = GoogleMapsPlaces(apiKey:kGoogleApiKey, apiHeaders: await const GoogleApiHeaders().getHeaders(),);
                                                                            String placeid = place.placeId ?? "0";
                                                                            final detail = await plist.getDetailsByPlaceId(placeid);
                                                                            final geometry = detail.result.geometry!;

                                                                            setState(() {
                                                                              change = true;
                                                                              _location.text = place.description.toString();
                                                                              lat2 = geometry.location.lat;
                                                                              lon2 = geometry.location.lng;
                                                                              deliveryAddress = place.description.toString();
                                                                            });
                                                                          }
                                                                        },
                                                                        decoration: InputDecoration(
                                                                            floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                                                                            focusedBorder: InputBorder.none,
                                                                            enabledBorder: InputBorder.none,
                                                                            prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.amber[700],size: 20.sp,),
                                                                            labelText: 'Search Address',
                                                                            labelStyle: GoogleFonts.inter(fontSize: 13.sp)
                                                                        ),
                                                                        validator: (String ? value) {
                                                                          if(value!.isEmpty) {
                                                                            return 'Please enter delivery address';
                                                                          }
                                                                          return null;
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async{
                                                    if (_formKey.currentState!.validate()) {
                                                      QuerySnapshot _myDoc = await FirebaseFirestore.instance.collection('OrderHistory').get();
                                                      List<DocumentSnapshot> _myDocCount = _myDoc.docs;
                                                      int count = _myDocCount.length + 1;
                                                      String orderId;

                                                      if(count < 10) {
                                                        orderId = 'OW000000' + count.toString();
                                                      } else if(count < 100) {
                                                        orderId = 'OW00000' + count.toString();
                                                      } else if(count < 1000) {
                                                        orderId = 'OW0000' + count.toString();
                                                      } else if(count < 10000) {
                                                        orderId = 'OW000' + count.toString();
                                                      } else if(count < 100000) {
                                                        orderId = 'OW00' + count.toString();
                                                      } else if(count < 1000000) {
                                                        orderId = 'OW0' + count.toString();
                                                      } else {
                                                        orderId = 'OW' + count.toString();
                                                      }

                                                      FirebaseFirestore.instance
                                                          .collection('OrderHistory')
                                                          .doc(orderId)
                                                          .set({
                                                        'dateTime': dateTime,
                                                        'orderId': orderId,
                                                        'orderFrom': doc['restaurantName'],
                                                        'phone': ds[index]['phone'],
                                                        'orderBy': ds[index]['orderBy'],
                                                        'paid to ros': int.parse('0'),
                                                        'received from customer': int.parse('0'),
                                                        'driver': '',
                                                        'from': doc1['from'],
                                                        'totalAmount': totalAmount,
                                                        'total': '$itemValue',
                                                        'bst': mainBst,
                                                        'serviceCharge': doc['serviceCharge'],
                                                        'deliveryAddress': (change == false) ? doc1['deliverAddress'] : deliveryAddress,
                                                        'deliveryCharge': "$charge",
                                                        'discountOnDC': '$discountOnDc',
                                                        'discountOnItem': '$discountOnItem',
                                                        'packingCharge': "$packingPrice",
                                                        'paymentType': selectedPayment.toString(),
                                                        'paymentDate': '',
                                                        'jrnlNo': '',
                                                        'screenShot': screenShot,
                                                        'admin': notification,
                                                        'cancel': notification,
                                                        'seen': notification,
                                                        'rating': 1.0,
                                                        'comment': '',
                                                        'isRated': false,
                                                        'paymentStatus': 'not paid',
                                                        'status': 'unassigned orders',
                                                        'uid': (_auth.currentUser)!.uid,
                                                      });
                                                      // FirebaseFirestore.instance.collection('Rating5')
                                                      //     .doc(orderId).set({
                                                      //   'dateTime': dateTime,
                                                      //   'orderId': orderId,
                                                      //   'orderFrom': doc['restaurantName'],
                                                      //   'orderBy': ds[index]['orderBy'],
                                                      //   'rating': 1.0,
                                                      //   'comment': '',
                                                      //   'isRated': false,
                                                      //   'uid': (_auth.currentUser)!.uid,
                                                      // }).then((value) => print('Success'));
                                                      _onPressed();
                                                    }
                                                  },
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    color: Colors.amber[900],
                                                    margin: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                                      child: Center(child: Text('PLACE ORDER', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w800))),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                      );
                                    }
                                )
                                : FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance.collection("Shop").where("shopName",isEqualTo: doc1["orderFrom"]).get(),
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

                                            DateTime startDate = DateTime.parse(doc['startDate']);
                                            DateTime endDate = DateTime.parse(doc['endDate']);
                                            var discount = int.parse(doc['discount']);
                                            var bst = int.parse(doc['bst']);
                                            var serviceCharge = int.parse(doc['serviceCharge']);

                                            double dsToCustomer = 0;
                                            double totalDistance = 0;
                                            int pricePerKm = sCharge;
                                            int pricePerKm2 = sCharge2;
                                            dsToCustomer += (change == false) ? calculateDistance(doc['lat'], doc['lon'], doc1['lat'], doc1['lon'])
                                            : calculateDistance(doc['lat'], doc['lon'], lat2, lon2);
                                            totalDistance = dsToCustomer;
                                            var charge = (totalDistance.round() < minDistance) ? totalDistance.round() * pricePerKm : totalDistance.round() * pricePerKm2;

                                            var mainBst = bst/100*itemValue;

                                            var discountOnDc;
                                            if(discount != 0 && date.isAfter(startDate) && date.isBefore(endDate)) {
                                              discountOnDc = discount/100*charge;
                                            }
                                            else if(sum != 0){
                                              discountOnDc = ((sum/100)/dsLength)*charge;
                                            }
                                            else if(sum2 != 0){
                                              discountOnDc = ((sum2/100)/dsLength)*charge;
                                            }
                                            else {
                                              discountOnDc = 0.0;
                                            }

                                            var mainDeliveryCharge = charge - discountOnDc;
                                            var totalAmount = (itemValue + mainBst + serviceCharge + mainDeliveryCharge + packingPrice - discountOnItem).round();

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
                                                              child: Text('$itemValue',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text('$mainBst',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text(doc['serviceCharge'] + '.0',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text('$charge' + '.0',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child:Text('$discountOnDc',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text('$discountOnItem',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.h),
                                                              child: Text('$packingPrice',style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600)),
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
                                                          Text('BTN ' + '$totalAmount' + '.0', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.amber[900], fontWeight: FontWeight.w700))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                                  child: Card(
                                                    elevation: 2.sp,
                                                    child: DropdownButtonFormField(
                                                      icon: Icon(Icons.arrow_drop_down_sharp, color: Color(0xFF1976D2)),
                                                      iconSize: 30.sp,
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
                                                      hint: Text(
                                                        'Select Payment Type',
                                                        style: GoogleFonts.inter(fontSize: 13.sp),
                                                      ),
                                                      value: selectedPayment,
                                                      isExpanded: true,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          selectedPayment = newValue;
                                                        });
                                                      },
                                                      items: payment.map((value) {
                                                        return DropdownMenuItem(
                                                          child: Text(value),
                                                          value: value,
                                                        );
                                                      }).toList(),
                                                      validator: (value) {
                                                        if (value == null) {
                                                          return 'please select payment type';
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                                                  child: Card(
                                                    elevation: 2.sp,
                                                    child: Padding(
                                                      padding: EdgeInsets.fromLTRB(10.w, 5.h, 0, 5.h),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                height: 30.h,
                                                                width: 30.w,
                                                                child: Transform.scale(
                                                                  scale: 1.2.sp,
                                                                  child: Checkbox(
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        this.check = value!;
                                                                        change = false;
                                                                      });
                                                                      if(visibility == false) {
                                                                        setState(() {
                                                                          visibility = true;
                                                                        });
                                                                      } else {
                                                                        visibility = false;
                                                                      }
                                                                    },
                                                                    value: check,
                                                                    activeColor: const Color(0xFF1976D2),
                                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 5.w),
                                                              Text('Current Location as delivery address', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),)
                                                            ],
                                                          ),
                                                          Visibility(
                                                            visible: visibility,
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(bottom: 5.h),
                                                                    child: Text('Delivery Address', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w600)),
                                                                  ),
                                                                  Container(
                                                                    height: MediaQuery.of(context).size.height/14,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(2.sp),
                                                                        border: Border.all(color: Color(0xffBDBDBD))),
                                                                    child: Padding(
                                                                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                                                                      child: TextFormField(
                                                                        minLines: 1,
                                                                        maxLines: 5,
                                                                        keyboardType: TextInputType.multiline,
                                                                        style: GoogleFonts.inter(fontSize: 13.sp),
                                                                        controller: _location,
                                                                        onTap: () async{
                                                                          var place = await PlacesAutocomplete.show(
                                                                            context: context,
                                                                            apiKey: kGoogleApiKey,
                                                                            onError: onError,
                                                                            mode: Mode.overlay,
                                                                            language: 'en',
                                                                            components: [Component(Component.country, 'bt')],
                                                                          );
                                                                          if(place != null){
                                                                            final plist = GoogleMapsPlaces(apiKey:kGoogleApiKey, apiHeaders: await const GoogleApiHeaders().getHeaders(),);
                                                                            String placeid = place.placeId ?? "0";
                                                                            final detail = await plist.getDetailsByPlaceId(placeid);
                                                                            final geometry = detail.result.geometry!;

                                                                            setState(() {
                                                                              change = true;
                                                                              _location.text = place.description.toString();
                                                                              lat2 = geometry.location.lat;
                                                                              lon2 = geometry.location.lng;
                                                                              deliveryAddress = place.description.toString();
                                                                            });
                                                                          }
                                                                        },
                                                                        decoration: InputDecoration(
                                                                            floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                                                                            focusedBorder: InputBorder.none,
                                                                            enabledBorder: InputBorder.none,
                                                                            prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.amber[700],size: 20.sp,),
                                                                            labelText: 'Search Address',
                                                                            labelStyle: GoogleFonts.inter(fontSize: 13.sp)
                                                                        ),
                                                                        validator: (String ? value) {
                                                                          if(value!.isEmpty) {
                                                                            return 'Please enter delivery address';
                                                                          }
                                                                          return null;
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (_formKey.currentState!.validate()) {
                                                      QuerySnapshot _myDoc = await FirebaseFirestore.instance.collection('OrderHistory').get();
                                                      List<DocumentSnapshot> _myDocCount = _myDoc.docs;
                                                      int count = _myDocCount.length + 1;
                                                      String orderId;

                                                      if(count < 10) {
                                                        orderId = 'OW000000' + count.toString();
                                                      } else if(count < 100) {
                                                        orderId = 'OW00000' + count.toString();
                                                      } else if(count < 1000) {
                                                        orderId = 'OW0000' + count.toString();
                                                      } else if(count < 10000) {
                                                        orderId = 'OW000' + count.toString();
                                                      } else if(count < 100000) {
                                                        orderId = 'OW00' + count.toString();
                                                      } else if(count < 1000000) {
                                                        orderId = 'OW0' + count.toString();
                                                      } else {
                                                        orderId = 'OW' + count.toString();
                                                      }

                                                      FirebaseFirestore.instance
                                                          .collection('OrderHistory')
                                                          .doc(orderId)
                                                          .set({
                                                        'dateTime': dateTime,
                                                        'orderId': orderId,
                                                        'orderFrom': doc['shopName'],
                                                        'orderBy': ds[index]['orderBy'],
                                                        'phone': ds[index]['phone'],
                                                        'paid to ros': int.parse('0'),
                                                        'received from customer': int.parse('0'),
                                                        'driver': '',
                                                        'from': doc1['from'],
                                                        'totalAmount': totalAmount,
                                                        'total': '$itemValue',
                                                        'bst': mainBst,
                                                        'serviceCharge': doc['serviceCharge'],
                                                        'deliveryAddress': (change == false) ? doc1['deliverAddress'] : deliveryAddress,
                                                        'deliveryCharge': "$charge",
                                                        'discountOnDC': '$discountOnDc',
                                                        'discountOnItem': '$discountOnItem',
                                                        'packingCharge': "$packingPrice",
                                                        'paymentType': selectedPayment.toString(),
                                                        'paymentDate': '',
                                                        'jrnlNo': '',
                                                        'screenShot': screenShot,
                                                        'admin': notification,
                                                        'cancel': notification,
                                                        'seen': notification,
                                                        'rating': 1.0,
                                                        'comment': '',
                                                        'isRated': false,
                                                        'status': 'unassigned orders',
                                                        'paymentStatus': 'not paid',
                                                        'uid': (_auth.currentUser)!.uid,
                                                      });
                                                      // FirebaseFirestore.instance.collection('Rating5')
                                                      //     .doc(orderId).set({
                                                      //   'dateTime': dateTime,
                                                      //   'orderId': orderId,
                                                      //   'orderFrom': doc['shopName'],
                                                      //   'orderBy': ds[index]['orderBy'],
                                                      //   'rating': 1.0,
                                                      //   'comment': '',
                                                      //   'isRated': false,
                                                      //   'uid': (_auth.currentUser)!.uid,
                                                      // }).then((value) => print('Success'));
                                                      _onPressed();

                                                      for(int i=0; i<ds.length;i++) {
                                                        var sId = ds[i]['sId'];
                                                        var size = ds[i]['size'];
                                                        int quantity = ds[i]['orderCount'];

                                                        FirebaseFirestore.instance
                                                            .collection("StoreItem2").doc(sId)
                                                            .get().then((value){
                                                          for(int j =0; j<value.data()!['size'].length; j++) {
                                                            var array = [];
                                                            var array2 = [{'size': value.data()!["size"][j]["size"], 'quantity': value.data()!["size"][j]["quantity"],}];
                                                            if(size == value.data()!["size"][j]["size"]) {
                                                              array = [{'size': value.data()!["size"][j]["size"], 'quantity': value.data()!["size"][j]["quantity"] - quantity,}];
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
                                                    }
                                                  },
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    color: Colors.amber[900],
                                                    margin: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                                      child: Center(child: Text('PLACE ORDER', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w800))),
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
              ),
            );
          }
      ),
    );
  }
}
