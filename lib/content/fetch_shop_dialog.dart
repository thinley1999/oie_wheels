import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:readmore/readmore.dart';

class FetchShopDialog extends StatefulWidget {
  final List<DocumentSnapshot> d_list;
  final int index;

  const FetchShopDialog({Key? key, required this.d_list, required this.index}) : super(key: key);
  @override
  _FetchShopDialogState createState() => _FetchShopDialogState();
}

class _FetchShopDialogState extends State<FetchShopDialog> {
  @override
  void initState() {
    super.initState();
    _getName();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  bool ? _serviceEnabled;
  PermissionStatus ? _permissionGranted;
  LocationData ? _userLocation;

  Future<void> _getUserLocation() async {
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();
    setState(() {
      _userLocation = _locationData;
    });
    if(_userLocation != null){
      FirebaseFirestore.instance.collection('Users').doc((_auth.currentUser)!.uid).update({
        'lat': _userLocation!.latitude,
        'lon': _userLocation!.longitude,
      });
    }
  }

  String formattedDate = DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now());
  int counter = 1;
  int _count = 0;

  void _incrementCount(){
    setState(() {
      _count++;
    });
  }

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

  void _getName() {
    FirebaseFirestore.instance.collection('Users').doc((_auth.currentUser)!.uid).get().then((value){
      firstName = value.data()!['firstName'];
      lastName = value.data()!['lastName'];
      phone = value.data()!['phone'];
      lat = value.data()!['lat'];
      lon = value.data()!['lon'];
    }).then((value) async{
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        lat,
        lon,
      );

      geo.Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.street}, ${place.locality}, ${place.country}";
      });
    });
    FirebaseFirestore.instance
        .collection("Shop")
        .where('shopName', isEqualTo: widget.d_list[widget.index]["shopName"].toString())
        .get()
        .then((value) {
      value.docs.forEach((result) {
        shopdiscount = result.data()['discount'];
        shopStartDate = result.data()['startDate'];
        shopEndDate = result.data()['endDate'];
      });
    });
    FirebaseFirestore.instance
        .collection("ShopDiscount")
        .where('shopName', isEqualTo: widget.d_list[widget.index]["shopName"].toString())
        .where('category', isEqualTo: widget.d_list[widget.index]["shopItemType"].toString())
        .get()
        .then((value) {
      value.docs.forEach((result) {
        categorydiscount = result.data()['discount'];
        categoryStartDate = result.data()['startDate'];
        categoryEndDate = result.data()['endDate'];
      });
    });
  }

  var date = DateTime.now();
  var firstName;
  var lastName;
  var phone;
  String ? _currentAddress;
  var lat;
  var lon;
  var selectedSize;
  var selectedQuantity;
  var shopdiscount;
  var shopStartDate;
  var shopEndDate;
  var categorydiscount;
  var categoryStartDate;
  var categoryEndDate;

  List<DropdownMenuItem> dropDownItems = <DropdownMenuItem>[];
  final _formKey= GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("StoreItem2").where("refId",isEqualTo: widget.d_list[widget.index]["refId"].toString()).get(),
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
            return ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  List<dynamic> image = snapshot.data!.docs[index]['imageUrl'];
                  var doc = snapshot.data!.docs[index];
                  dropDownItems = [];
                  for(int i = 0; i < doc['size'].length; i++){
                    var quantity = doc['size'][i]['quantity'];
                    (quantity > 0) ? dropDownItems.add(DropdownMenuItem<dynamic>(
                      value: doc['size'][i]['size'],
                      child:Text(doc['size'][i]['size'], style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                    )): SizedBox();
                  }
                  var discount = int.parse(doc['discount'])/100*int.parse(doc['price']);
                  var discountPrice = int.parse(doc['price']) - discount;
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 150.h,
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
                        Text('Available Quantity', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                        (dropDownItems.isNotEmpty) ? Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: doc['size'].length,
                              itemBuilder: (context, index) {
                              var doc2 = doc['size'][index];
                                return (doc2['quantity']>0) ? Table(
                                  border: TableBorder.all(color: Colors.black),
                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                  children: [
                                    TableRow(
                                      children: [
                                        Text(doc2['size'], style: GoogleFonts.inter(fontSize: 13.sp), textAlign: TextAlign.center),
                                        Text(doc2['quantity'].toString(), style: GoogleFonts.inter(fontSize: 13.sp), textAlign: TextAlign.center),
                                      ]
                                    ),
                                  ],
                                )
                                : SizedBox();
                              }
                          ),
                        )
                        :  Text('Out of Stock', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.red)),
                        Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Item Name:', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                                  Text('Item Price:', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                                  (doc['discount'] != '0' && date.isAfter(DateTime.parse(doc['startDate'])) && date.isBefore(DateTime.parse(doc['endDate']))) ? Text('Discount:', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800))
                                  : SizedBox(),
                                  (doc['discount'] != '0' && date.isAfter(DateTime.parse(doc['startDate'])) && date.isBefore(DateTime.parse(doc['endDate']))) ? Text('Discount Price:', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800))
                                  : SizedBox(),
                                  if(shopdiscount == '100' && date.isAfter(DateTime.parse(shopStartDate)) && date.isBefore(DateTime.parse(shopEndDate)))...[
                                    Text('Delivery Charge:', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                                  ] else if(categorydiscount == 100 && date.isAfter(DateTime.parse(categoryStartDate)) && date.isBefore(DateTime.parse(categoryEndDate)))...[
                                    Text('Delivery Charge:', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                                  ] else if(doc['discount2'] == '100' && date.isAfter(DateTime.parse(doc['startDate2'])) && date.isBefore(DateTime.parse(doc['endDate2'])))...[
                                    Text('Delivery Charge:', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                                  ] else...[
                                    SizedBox()
                                  ]
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doc['shopItemName'], style: GoogleFonts.inter(fontSize: 13.sp)),
                                  Text('Nu. '+ doc['price'] + '.0', style: GoogleFonts.inter(fontSize: 13.sp)),
                                  (doc['discount'] != '0' && date.isAfter(DateTime.parse(doc['startDate'])) && date.isBefore(DateTime.parse(doc['endDate']))) ? Text(doc['discount'] + '%', style: GoogleFonts.inter(fontSize: 13.sp))
                                  : SizedBox(),
                                  (doc['discount'] != '0' && date.isAfter(DateTime.parse(doc['startDate'])) && date.isBefore(DateTime.parse(doc['endDate']))) ? Text('Nu. '+ discountPrice.toString(), style: GoogleFonts.inter(fontSize: 13.sp))
                                  : SizedBox(),
                                  if(shopdiscount == '100' && date.isAfter(DateTime.parse(shopStartDate)) && date.isBefore(DateTime.parse(shopEndDate)))...[
                                    Text('Free', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.red)),
                                  ] else if(categorydiscount == 100 && date.isAfter(DateTime.parse(categoryStartDate)) && date.isBefore(DateTime.parse(categoryEndDate)))...[
                                    Text('Free', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.red)),
                                  ] else if(doc['discount2'] == '100' && date.isAfter(DateTime.parse(doc['startDate2'])) && date.isBefore(DateTime.parse(doc['endDate2'])))...[
                                    Text('Free', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.red)),
                                  ] else...[
                                    SizedBox()
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text('Description', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                        ReadMoreText(
                          doc['description'],
                            trimLines: 3,
                            trimMode: TrimMode.Line,
                            style: GoogleFonts.inter(fontSize: 13.sp,)
                        ),
                        (doc['shopItem'] == 'Cloths' && dropDownItems.isNotEmpty)
                            ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: DropdownButtonFormField<dynamic>(
                            style: GoogleFonts.inter(fontSize: 15.sp),
                            icon: (dropDownItems.isNotEmpty) ? Icon(Icons.arrow_drop_down_sharp, color: Colors.white)
                            : SizedBox(),
                            iconSize: 30.sp,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 5.w),
                              fillColor: Colors.amber[900],
                              filled: true,
                              border: InputBorder.none,
                              errorBorder: InputBorder.none,
                              errorStyle: GoogleFonts.inter(fontSize: 13.sp)
                            ),
                            dropdownColor: Colors.amber[900],
                            items: dropDownItems,
                            onChanged: (value) {
                              setState(() {
                                selectedSize = value;
                              });
                              for(int i = 0; i < doc['size'].length; i++){
                                if(selectedSize == doc['size'][i]['size']) {
                                  setState(() {
                                    selectedQuantity = doc['size'][i]['quantity'];
                                    print(selectedQuantity);
                                  });
                                }
                              }
                            },
                            value: selectedSize,
                            isExpanded: true,
                            hint: Text(
                              (dropDownItems.isNotEmpty) ? 'Select Size' : 'Out of Stock',
                              style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Size is required';
                              }
                            },
                          ),
                        )
                        : SizedBox(),
                        (dropDownItems.isNotEmpty) ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:35.h,
                                width:35.w,
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
                                    if (_formKey.currentState!.validate()) {
                                      showOverlay(context);
                                      var a = await FirebaseFirestore.instance
                                          .collection('Order')
                                          .doc((_auth.currentUser)!.uid)
                                          .collection('Item').doc(widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate)
                                          .get();
                                      if(a.exists){
                                        FirebaseFirestore.instance
                                            .collection('Order')
                                            .doc((_auth.currentUser)!.uid)
                                            .collection('Item')
                                            .doc(widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate)
                                            .update({
                                          'orderCount': FieldValue.increment(-1),
                                        });
                                      }
                                      if(!a.exists){
                                        print('Not exists');
                                        return null;
                                      }
                                    }
                                  },
                                ),
                              ),
                              Container(
                                height:35.h,
                                width:35.w,
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
                                        .collection('Order').doc((_auth.currentUser)!.uid).collection('Item').where('orderItem', isEqualTo: doc['shopItemName'])
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
                                            }) : Text('0', style: GoogleFonts.inter(fontSize: 13.sp), textAlign: TextAlign.center);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:35.h,
                                width:35.w,
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
                                    _getUserLocation().then((value) {
                                      if(_userLocation != null) {
                                        FirebaseFirestore.instance.collection('Users').doc((_auth.currentUser)!.uid).update({
                                          'lat': _userLocation!.latitude,
                                          'lon': _userLocation!.longitude,
                                        });
                                      }
                                    }).then((value) async {
                                      if (_formKey.currentState!.validate()) {
                                        showOverlay(context);
                                        _incrementCount();
                                        if(selectedQuantity == null){
                                          for(int i = 0; i < doc['size'].length; i++){
                                            if(doc['size'][i]['size'] == 'freeSize') {
                                              setState(() {
                                                selectedQuantity = doc['size'][i]['quantity'];
                                                print(selectedQuantity);
                                              });
                                            }
                                          }
                                          if(_count <= selectedQuantity) {
                                            var a = await FirebaseFirestore.instance
                                                .collection('Order')
                                                .doc((_auth.currentUser)!.uid)
                                                .collection('Item').doc(widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate)
                                                .get();
                                            if(a.exists){
                                              FirebaseFirestore.instance
                                                  .collection('Order')
                                                  .doc((_auth.currentUser)!.uid)
                                                  .collection('Item')
                                                  .doc(widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate)
                                                  .update({
                                                'orderCount': FieldValue.increment(1),
                                              });
                                            }

                                            if(!a.exists){
                                              FirebaseFirestore.instance
                                                  .collection('Order')
                                                  .doc((_auth.currentUser)!.uid)
                                                  .collection('Item')
                                                  .doc(widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate)
                                                  .set({
                                                'sId': doc['refId'],
                                                'orderCount': counter,
                                                'price': int.parse(doc['price']),
                                                'orderItem': doc['shopItemName'],
                                                // 'itemType': doc['shopItemType'],
                                                'size': (doc['shopItem'] == 'Cloths') ? selectedSize.toString(): 'freeSize',
                                                'status': 'draft',
                                                'oId': widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate,
                                                'orderFrom': widget.d_list[widget.index]["shopName"].toString(),
                                                'orderBy': firstName + ' ' + lastName,
                                                'lat': lat,
                                                'lon': lon,
                                                'phone': phone,
                                                'deliverAddress': _currentAddress,
                                                'discount': int.parse(doc['discount']),
                                                'startDate': doc['startDate'],
                                                'endDate': doc['endDate'],
                                                'from': 'shop',
                                                'packingPrice': int.parse('0'),
                                                'dateTime': 'unknown',
                                                'uid': (_auth.currentUser)!.uid,
                                              });
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: 'Out of Stock',
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 13.sp
                                            );
                                          }
                                        } else {
                                          if(_count <= selectedQuantity) {
                                            var a = await FirebaseFirestore.instance
                                                .collection('Order')
                                                .doc((_auth.currentUser)!.uid)
                                                .collection('Item').doc(widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate)
                                                .get();
                                            if(a.exists){
                                              FirebaseFirestore.instance
                                                  .collection('Order')
                                                  .doc((_auth.currentUser)!.uid)
                                                  .collection('Item')
                                                  .doc(widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate)
                                                  .update({
                                                'orderCount': FieldValue.increment(1),
                                              });
                                            }

                                            if(!a.exists){
                                              FirebaseFirestore.instance
                                                  .collection('Order')
                                                  .doc((_auth.currentUser)!.uid)
                                                  .collection('Item')
                                                  .doc(widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate)
                                                  .set({
                                                'sId': doc['refId'],
                                                'orderCount': counter,
                                                'price': int.parse(doc['price']),
                                                'orderItem': doc['shopItemName'],
                                                // 'itemType': doc['shopItemType'],
                                                'size': (doc['shopItem'] == 'Cloths') ? selectedSize.toString(): 'freeSize',
                                                'status': 'draft',
                                                'oId': widget.d_list[widget.index]["shopName"].toString() + doc['shopItemName'] + formattedDate,
                                                'orderFrom': widget.d_list[widget.index]["shopName"].toString(),
                                                'orderBy': firstName + ' ' + lastName,
                                                'lat': lat,
                                                'lon': lon,
                                                'phone': phone,
                                                'deliverAddress': _currentAddress,
                                                'discount': int.parse(doc['discount']),
                                                'startDate': doc['startDate'],
                                                'endDate': doc['endDate'],
                                                'from': 'shop',
                                                'packingPrice': int.parse('0'),
                                                'dateTime': 'unknown',
                                                'uid': (_auth.currentUser)!.uid,
                                              });
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: 'Out of Stock',
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 13.sp
                                            );
                                          }
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                            : SizedBox(),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: IconButton(
                            icon: Icon(FontAwesomeIcons.angleLeft, size: 25.sp),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )),
                      ],
                    ),
                  );
                }
            );
          }
      ),
    );
  }
}
