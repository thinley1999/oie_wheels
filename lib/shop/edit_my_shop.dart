import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oie_wheels/shop/my_shop.dart';

class EditMyShop extends StatefulWidget {
  @override
  _EditMyShopState createState() => _EditMyShopState();
}

class _EditMyShopState extends State<EditMyShop> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
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
          title: Text('Edit Shop', style: GoogleFonts.inter(
              fontSize: 15.sp, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottomOpacity: 0.0,
          elevation: 0.0,
          backgroundColor: Color(0xFF1976D2),
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
              return  Container(
                height: 200.0,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
                ),
              );
            default:
              return ListView.builder(itemCount:snapshot.data!.docs.length,itemBuilder: (_,index){
                List<DocumentSnapshot> userDocument = snapshot.data!.docs;
                return Column(
                  children: [
                    FetchEditMyStore(r_list: userDocument,index: index,),
                  ],
                );
              });
          }
        },
      ),
    );
  }
}

class FetchEditMyStore extends StatefulWidget {
  final List<DocumentSnapshot> r_list;
  final int index;

  const FetchEditMyStore({Key? key, required this.r_list, required this.index}) : super(key: key);
  @override
  _FetchEditMyStoreState createState() => _FetchEditMyStoreState();
}

class _FetchEditMyStoreState extends State<FetchEditMyStore> {
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("Shop").where("uid",isEqualTo: widget.r_list[widget.index]["uid"].toString()).get().then((value){
      _addressController.text = widget.r_list[widget.index]["shopAddress"].toString();
      _timeController.text = widget.r_list[widget.index]["deliveryTime"].toString();
      _discountChargeController.text = widget.r_list[widget.index]["discount"].toString();
      _startDate.text = widget.r_list[widget.index]["startDate"].toString();
      _endDate.text = widget.r_list[widget.index]["endDate"].toString();
    });
    selectedDistrict = widget.r_list[widget.index]["district"].toString();
    selectedCity = widget.r_list[widget.index]["city"].toString();
    monday = widget.r_list[widget.index]['days'][0]['monday'];
    _mondayOpen.text = widget.r_list[widget.index]['days'][0]['mondayOpen'].toString();
    _mondayClose.text = widget.r_list[widget.index]['days'][0]['mondayClose'].toString();
    tuesday = widget.r_list[widget.index]['days'][1]['tuesday'];
    _tuesdayOpen.text = widget.r_list[widget.index]['days'][1]['tuesdayOpen'].toString();
    _tuesdayClose.text = widget.r_list[widget.index]['days'][1]['tuesdayClose'].toString();
    wednesday = widget.r_list[widget.index]['days'][2]['wednesday'];
    _wednesdayOpen.text = widget.r_list[widget.index]['days'][2]['wednesdayOpen'].toString();
    _wednesdayClose.text = widget.r_list[widget.index]['days'][2]['wednesdayClose'].toString();
    thursday = widget.r_list[widget.index]['days'][3]['thursday'];
    _thursdayOpen.text = widget.r_list[widget.index]['days'][3]['thursdayOpen'].toString();
    _thursdayClose.text = widget.r_list[widget.index]['days'][3]['thursdayClose'].toString();
    friday = widget.r_list[widget.index]['days'][4]['friday'];
    _fridayOpen.text = widget.r_list[widget.index]['days'][4]['fridayOpen'].toString();
    _fridayClose.text = widget.r_list[widget.index]['days'][4]['fridayClose'].toString();
    saturday = widget.r_list[widget.index]['days'][5]['saturday'];
    _saturdayOpen.text = widget.r_list[widget.index]['days'][5]['saturdayOpen'].toString();
    _saturdayClose.text = widget.r_list[widget.index]['days'][5]['saturdayClose'].toString();
    sunday = widget.r_list[widget.index]['days'][6]['sunday'];
    _sundayOpen.text = widget.r_list[widget.index]['days'][6]['sundayOpen'].toString();
    _sundayClose.text = widget.r_list[widget.index]['days'][6]['sundayClose'].toString();
  }
  final _formKey= GlobalKey<FormState>();
  var _addressController = TextEditingController();
  var _timeController = TextEditingController();
  var _discountChargeController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  var selectedDistrict;
  var selectedCity;

  var _mondayOpen = TextEditingController();
  var _mondayClose = TextEditingController();
  var _tuesdayOpen = TextEditingController();
  var _tuesdayClose = TextEditingController();
  var _wednesdayOpen = TextEditingController();
  var _wednesdayClose = TextEditingController();
  var _thursdayOpen = TextEditingController();
  var _thursdayClose = TextEditingController();
  var _fridayOpen = TextEditingController();
  var _fridayClose = TextEditingController();
  var _saturdayOpen = TextEditingController();
  var _saturdayClose = TextEditingController();
  var _sundayOpen = TextEditingController();
  var _sundayClose = TextEditingController();

  TextEditingController _startDate = TextEditingController();
  TextEditingController _endDate = TextEditingController();

  bool monday = false;
  bool tuesday = false;
  bool wednesday = false;
  bool thursday = false;
  bool friday = false;
  bool saturday = false;
  bool sunday = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Address*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _addressController,
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
                            return 'Please enter address';
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('District*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child:  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('District').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return LinearProgressIndicator();
                        else {
                          return Container(
                            padding: EdgeInsets.only(left: 10.w),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1)
                            ),
                            child: DropdownButton(
                              items: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                return DropdownMenuItem<String>(
                                  value: document['districtName'] ,
                                  child: Text(document['districtName']),
                                );
                              }).toList(),
                              onChanged: (districtValue) {
                                setState(() {
                                  selectedDistrict = districtValue;
                                });
                              },
                              value: selectedDistrict,
                              isExpanded: true,
                              underline: SizedBox(),
                              hint: Text(
                                'Select District',
                                style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('City*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('City').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return LinearProgressIndicator();
                        else {
                          return Container(
                            padding: EdgeInsets.only(left: 10.w),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1)
                            ),
                            child: DropdownButton(
                              items: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                return DropdownMenuItem<String>(
                                  value: document['cityName'] ,
                                  child: Text(document['cityName']),
                                );
                              }).toList(),
                              onChanged: (categoryValue) {
                                setState(() {
                                  selectedCity = categoryValue;
                                });
                              },
                              value: selectedCity,
                              isExpanded: true,
                              underline: SizedBox(),
                              hint: Text(
                                'Select City',
                                style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Delivery Time(in minute)*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _timeController,
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
                            return 'Please enter delivery time';
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Opening & closing time*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  DataTable(
                    columnSpacing: 20.w,
                      columns: [
                        DataColumn(label: Text('# Days', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
                        DataColumn(label: Text('Is\nClosed', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
                        DataColumn(label: Text('Opening\nTime', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
                        DataColumn(label: Text('Closing\nTime', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('Monday', style: GoogleFonts.inter(fontSize: 13.sp))),
                          DataCell(
                              Transform.scale(
                                scale: 0.8.sp,
                                child: Checkbox(
                                  value: monday,
                                  onChanged: (value) {
                                    setState(() {
                                      this.monday = value!;
                                    });
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.h,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _mondayOpen, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '09:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  enabled: !monday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );
                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _mondayOpen.text = formattedTime;
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.sp,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _mondayClose, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '23:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  enabled: !monday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );

                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _mondayClose.text = formattedTime; //set the value of text field.
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Tuesday', style: GoogleFonts.inter(fontSize: 13.sp))),
                          DataCell(
                              Transform.scale(
                                scale: 0.8.sp,
                                child: Checkbox(
                                  value: tuesday,
                                  onChanged: (value) {
                                    setState(() {
                                      this.tuesday = value!;
                                    });
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.h,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _tuesdayOpen, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '09:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  enabled: !tuesday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );
                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _tuesdayOpen.text = formattedTime;
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.sp,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _tuesdayClose, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '23:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  enabled: !tuesday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );

                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _tuesdayClose.text = formattedTime; //set the value of text field.
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Wednesday', style: GoogleFonts.inter(fontSize: 13.sp))),
                          DataCell(
                              Transform.scale(
                                scale: 0.8.sp,
                                child: Checkbox(
                                  value: wednesday,
                                  onChanged: (value) {
                                    setState(() {
                                      this.wednesday = value!;
                                    });
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.h,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _wednesdayOpen, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '09:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  enabled: !wednesday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );
                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _wednesdayOpen.text = formattedTime;
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.sp,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _wednesdayClose, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '23:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  enabled: !wednesday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );

                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _wednesdayClose.text = formattedTime; //set the value of text field.
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Thursday', style: GoogleFonts.inter(fontSize: 13.sp))),
                          DataCell(
                              Transform.scale(
                                scale: 0.8.sp,
                                child: Checkbox(
                                  value: thursday,
                                  onChanged: (value) {
                                    setState(() {
                                      this.thursday = value!;
                                    });
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.h,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _thursdayOpen, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '09:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  enabled: !thursday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );
                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _thursdayOpen.text = formattedTime;
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.sp,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _thursdayClose, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '23:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  enabled: !thursday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );

                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _thursdayClose.text = formattedTime; //set the value of text field.
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Friday', style: GoogleFonts.inter(fontSize: 13.sp))),
                          DataCell(
                              Transform.scale(
                                scale: 0.8.sp,
                                child: Checkbox(
                                  value: friday,
                                  onChanged: (value) {
                                    setState(() {
                                      this.friday = value!;
                                    });
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.h,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _fridayOpen, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '09:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  enabled: !friday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );
                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _fridayOpen.text = formattedTime;
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.sp,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _fridayClose, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '23:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  enabled: !friday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );

                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _fridayClose.text = formattedTime; //set the value of text field.
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Saturday', style: GoogleFonts.inter(fontSize: 13.sp))),
                          DataCell(
                              Transform.scale(
                                scale: 0.8.sp,
                                child: Checkbox(
                                  value: saturday,
                                  onChanged: (value) {
                                    setState(() {
                                      this.saturday = value!;
                                    });
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.h,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _saturdayOpen, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '09:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  enabled: !saturday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );
                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _saturdayOpen.text = formattedTime;
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.sp,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _saturdayClose, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '23:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  enabled: !saturday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );

                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _saturdayClose.text = formattedTime; //set the value of text field.
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Sunday', style: GoogleFonts.inter(fontSize: 13.sp))),
                          DataCell(
                              Transform.scale(
                                scale: 0.8.sp,
                                child: Checkbox(
                                  value: sunday,
                                  onChanged: (value) {
                                    setState(() {
                                      this.sunday = value!;
                                    });
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.h,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _sundayOpen, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '09:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  enabled: !sunday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );
                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _sundayOpen.text = formattedTime;
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                          DataCell(
                              Container(
                                height: 30.sp,
                                child: TextFormField(
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                  controller: _sundayClose, //editing controller of this TextField
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.w),
                                    hintText: '23:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  enabled: !sunday,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =  await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );

                                    if(pickedTime != null ){
                                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                                      String formattedTime = DateFormat('HH:mm').format(parsedTime);
                                      setState(() {
                                        _sundayClose.text = formattedTime; //set the value of text field.
                                      });
                                    }else{
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              )
                          ),
                        ]),
                      ]
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Discount on delivery charge(%)*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _discountChargeController,
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
                            return 'Please enter discount n delivery charge';
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Discount valid Date from', style: GoogleFonts.inter()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        controller: _startDate, //editing controller of this TextField
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10.w),
                          hintText: 'Validate Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        readOnly: true,  //set it true, so that user will not able to edit text
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context, initialDate: DateTime.now(),
                              firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101)
                          );

                          if(pickedDate != null ){
                            String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                            setState(() {
                              _startDate.text = formattedDate; //set output date to TextField value.
                            });
                          }else{
                            print("Date is not selected");
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Discount valid Date To', style: GoogleFonts.inter()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        controller: _endDate, //editing controller of this TextField
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10.w),
                          hintText: 'Validate Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        readOnly: true,  //set it true, so that user will not able to edit text
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context, initialDate: DateTime.now(),
                              firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101)
                          );

                          if(pickedDate != null ){
                            String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                            setState(() {
                              _endDate.text = formattedDate; //set output date to TextField value.
                            });
                          }else{
                            print("Date is not selected");
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                  child: Text(
                      "Edit Shop",
                      style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600)
                  ),
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF1976D2)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                              side: BorderSide(color: Color(0xFF1976D2))
                          )
                      )
                  ),
                  onPressed: () {
                    if(_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      FirebaseFirestore.instance.collection('Shop').doc( widget.r_list[widget.index]["uid"].toString())
                          .update({
                        'shopAddress': _addressController.text,
                        'deliveryTime': _timeController.text,
                        'district' : selectedDistrict.toString(),
                        'city': selectedCity.toString(),
                        'days':[
                          {'day': 'Monday', 'isClosed': monday, 'openingTime': _mondayOpen.text, 'closingTime': _mondayClose.text},
                          {'day': 'Tuesday', 'isClosed': tuesday, 'openingTime': _tuesdayOpen.text, 'closingTime': _tuesdayClose.text},
                          {'day': 'Wednesday', 'isClosed': wednesday, 'openingTime': _wednesdayOpen.text, 'closingTime': _wednesdayClose.text},
                          {'day': 'Thursday', 'isClosed': thursday, 'openingTime': _thursdayOpen.text, 'closingTime': _thursdayClose.text},
                          {'day': 'Friday', 'isClosed': friday, 'openingTime': _fridayOpen.text, 'closingTime': _fridayClose.text},
                          {'day': 'Saturday', 'isClosed': saturday, 'openingTime': _saturdayOpen.text, 'closingTime': _saturdayClose.text},
                          {'day': 'Sunday', 'isClosed': sunday, 'openingTime': _sundayOpen.text, 'closingTime': _sundayClose.text},
                        ],
                        'discount': _discountChargeController.text,
                        'startDate': _startDate.text,
                        'endDate': _endDate.text,
                      }).then((value) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyShop()));
                        Fluttertoast.showToast(
                            msg: 'Update Shop Success',
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 13.sp
                        );
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Update Shop fails',
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 13.sp
                      );
                    }
                  }
              )
            ],
          ),
        ),
      ),
    );
  }
}

