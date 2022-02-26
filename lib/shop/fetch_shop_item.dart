import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:transparent_image/transparent_image.dart';

class FetchShopItem extends StatefulWidget {
  final List<DocumentSnapshot> s_list;
  final int index;

  const FetchShopItem({Key? key, required this.s_list, required this.index}) : super(key: key);
  @override
  _FetchShopItemState createState() => _FetchShopItemState();
}

class _FetchShopItemState extends State<FetchShopItem> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  final _formKey= GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("StoreItem2").where("refId",isEqualTo: widget.s_list[widget.index]["refId"].toString()).get().then((value){
      _nameController.text = widget.s_list[widget.index]["shopItemName"].toString();
      _priceController.text = widget.s_list[widget.index]["price"].toString();
      _discountChargeController.text = widget.s_list[widget.index]["discount"].toString();
      _startDate.text = widget.s_list[widget.index]["startDate"].toString();
      _endDate.text = widget.s_list[widget.index]["endDate"].toString();
      _discountChargeController2.text = widget.s_list[widget.index]["discount2"].toString();
      _startDate2.text = widget.s_list[widget.index]["startDate2"].toString();
      _endDate2.text = widget.s_list[widget.index]["endDate2"].toString();

      value.docs.forEach((result) {
        for(int i = 0; i<result.data()['size'].length; i++) {
          var array = [{'size': result.data()["size"][i]["size"], 'quantity': result.data()["size"][i]["quantity"],}];
          print(array);
          if(result.data()["size"][i]["size"] == 'small') {
            _small.text = result.data()["size"][i]["quantity"].toString();
          } else if(result.data()["size"][i]["size"] == 'medium') {
            _medium.text = result.data()["size"][i]["quantity"].toString();
          } else if(result.data()["size"][i]["size"] == 'large') {
            _large.text = result.data()["size"][i]["quantity"].toString();
          } else if(result.data()["size"][i]["size"] == 'xl') {
            _xl.text = result.data()["size"][i]["quantity"].toString();
          } else if(result.data()["size"][i]["size"] == 'xxl') {
            _xxl.text = result.data()["size"][i]["quantity"].toString();
          } else if(result.data()["size"][i]["size"] == 'xxxl') {
            _xxxl.text = result.data()["size"][i]["quantity"].toString();
          } else if(result.data()["size"][i]["size"] == 'freeSize') {
            _freeSize.text = result.data()["size"][i]["quantity"].toString();
          } else {
          }
        }
      });
    });
    selectedCatrgory = widget.s_list[widget.index]["shopItemType"].toString();
    selectedItem = widget.s_list[widget.index]["shopItem"].toString();
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _discountChargeController = TextEditingController();
  TextEditingController _startDate = TextEditingController();
  TextEditingController _endDate = TextEditingController();
  TextEditingController _discountChargeController2 = TextEditingController();
  TextEditingController _startDate2 = TextEditingController();
  TextEditingController _endDate2 = TextEditingController();

  TextEditingController _small = TextEditingController();
  TextEditingController _medium = TextEditingController();
  TextEditingController _large = TextEditingController();
  TextEditingController _xl = TextEditingController();
  TextEditingController _xxl = TextEditingController();
  TextEditingController _xxxl = TextEditingController();
  TextEditingController _freeSize = TextEditingController();

  var selectedCatrgory;
  var selectedItem;
  var shopName;
  List<String> items = <String>['Cloths', 'Others'];

  bool uploading = false;
  double val = 0;
  firebase_storage.Reference ? ref;

  List<File> _image = [];
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Shop Item Name*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _nameController,
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
                            return 'Please enter item name';
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
                    child: Text('Shop Item Category*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child:  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('ShopItemCategory').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return LinearProgressIndicator();
                        else {
                          return DropdownButtonFormField(
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
                            items: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              return DropdownMenuItem<String>(
                                value: document['shopItemType'] ,
                                child: Text(document['shopItemType']),
                              );
                            }).toList(),
                            onChanged: (categoryValue) {
                              setState(() {
                                selectedCatrgory = categoryValue;
                              });
                            },
                            value: selectedCatrgory,
                            isExpanded: true,
                            hint: Text(
                              'Select Item Category',
                              style: GoogleFonts.inter(fontSize: 13.sp),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'please enter item category';
                              }
                            },
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
                    child: Text('Shop Item Type*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child:  DropdownButtonFormField(
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
                        'Select Item Type',
                        style: GoogleFonts.inter(fontSize: 13.sp),
                      ),
                      value: selectedItem,
                      isExpanded: true,
                      onChanged: (newValue) {
                        setState(() {
                          selectedItem = newValue;
                        });
                      },
                      items: items.map((value) {
                        return DropdownMenuItem(
                          child: Text(value),
                          value: value,
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'please enter item type';
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
                    child: Text('Price*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _priceController,
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
                            return 'Please enter price';
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
                    child: Text('Discount on Item(%)*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
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
                            return 'Please enter discount on item';
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
                    child: Text('Item discount valid Date from', style: GoogleFonts.inter()),
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
                            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
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
                    child: Text('Item discount valid Date To', style: GoogleFonts.inter()),
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
                            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Discount on Delivery Charge(%)*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _discountChargeController2,
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
                            return 'Please enter discount on delivery charge';
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
                    child: Text('Delivery discount valid Date from', style: GoogleFonts.inter()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        controller: _startDate2, //editing controller of this TextField
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
                            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                            setState(() {
                              _startDate2.text = formattedDate; //set output date to TextField value.
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
                    child: Text('Delivery discount valid Date To', style: GoogleFonts.inter()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        controller: _endDate2, //editing controller of this TextField
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
                            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                            setState(() {
                              _endDate2.text = formattedDate; //set output date to TextField value.
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
              DataTable(
                  horizontalMargin: 3.w,
                  columnSpacing: 15.w,
                  columns: [
                    DataColumn(label: Text('Size', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
                    DataColumn(label: Text('Quantity', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Small', style: GoogleFonts.inter(fontSize: 13.sp))),
                      DataCell(
                          SizedBox(
                            height: 30.h,
                            width: 260.w,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13.sp),
                              textAlign: TextAlign.start,
                              controller: _small,
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
                                  return 'Please enter small size';
                                }
                              },
                            ),
                          )
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Medium', style: GoogleFonts.inter(fontSize: 13.sp))),
                      DataCell(
                          SizedBox(
                            height: 30.h,
                            width: 260.w,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13.sp),
                              textAlign: TextAlign.start,
                              controller: _medium,
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
                                  return 'Please enter small size';
                                }
                              },
                            ),
                          )
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Large', style: GoogleFonts.inter(fontSize: 13.sp))),
                      DataCell(
                          SizedBox(
                            height: 30.h,
                            width: 260.w,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13.sp),
                              textAlign: TextAlign.start,
                              controller: _large,
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
                                  return 'Please enter small size';
                                }
                              },
                            ),
                          )
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('XL', style: GoogleFonts.inter(fontSize: 13.sp))),
                      DataCell(
                          SizedBox(
                            height: 30.h,
                            width: 260.w,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13.sp),
                              textAlign: TextAlign.start,
                              controller: _xl,
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
                                  return 'Please enter small size';
                                }
                              },
                            ),
                          )
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('XXL', style: GoogleFonts.inter(fontSize: 13.sp))),
                      DataCell(
                          SizedBox(
                            height: 30.h,
                            width: 260.w,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13.sp),
                              textAlign: TextAlign.start,
                              controller: _xxl,
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
                                  return 'Please enter small size';
                                }
                              },
                            ),
                          )
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('XXXL', style: GoogleFonts.inter(fontSize: 13.sp))),
                      DataCell(
                          SizedBox(
                            height: 30.h,
                            width: 260.w,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13.sp),
                              textAlign: TextAlign.start,
                              controller: _xxxl,
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
                                  return 'Please enter small size';
                                }
                              },
                            ),
                          )
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Free Size', style: GoogleFonts.inter(fontSize: 13.sp))),
                      DataCell(
                          SizedBox(
                            height: 30.h,
                            width: 260.w,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13.sp),
                              textAlign: TextAlign.start,
                              controller: _freeSize,
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
                                  return 'Please enter small size';
                                }
                              },
                            ),
                          )
                      ),
                    ]),
                  ]
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: Text('Item Image*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('StoreItem2').where('refId', isEqualTo: widget.s_list[widget.index]["refId"].toString()).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('No Data');
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            List<dynamic> image = snapshot.data!.docs[index]['imageUrl'];
                            return GridView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount: image.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(3),
                                        child: FadeInImage.memoryNetwork(
                                            fit: BoxFit.cover,
                                            placeholder: kTransparentImage,
                                            image: image[index]),
                                      ),
                                      IconButton(onPressed: () {
                                        var val=[image[index]];
                                        FirebaseStorage.instance.refFromURL(image[index]).delete();
                                        FirebaseFirestore.instance.collection('StoreItem2').doc(widget.s_list[widget.index]["refId"].toString()).update({
                                          'imageUrl': FieldValue.arrayRemove(val),
                                        });
                                      },
                                          icon: Icon(Icons.delete, size: 20.sp, color: Colors.grey))
                                    ],
                                  );
                                });
                          });

                    },
                  ),
                  Stack(
                    children: [
                      GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: _image.length + 1,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                          itemBuilder: (context, index) {
                            return index == 0
                                ? Container(
                              color: Color(0xFFE8EAF6),
                              margin: EdgeInsets.only(left: 3.w, top: 3.h,),
                              child: IconButton(
                                  icon: Icon(Icons.add, size: 25.sp),
                                  onPressed: () =>
                                  !uploading ? chooseImage() : null),
                            )
                                : Container(
                              margin: EdgeInsets.only(left: 3.w, top: 3.h),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(_image[index - 1]),
                                      fit: BoxFit.cover)),
                            );
                          }),
                      uploading
                          ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                child: Text(
                                  'uploading...\nPlease wait...',
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CircularProgressIndicator(
                                value: val,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              )
                            ],
                          ))
                          : Container(),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                  child: Text(
                      "Update Shop Item",
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
                    setState(() {
                      uploading = true;
                    });
                    if(_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      uploadFile().whenComplete(() {
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                            msg: 'Update Shop Item Success',
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 13.sp
                        );
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Update Shop Item fails',
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
  chooseImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
    if (pickedFile!.path == null) retrieveLostData();
  }
  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file!.path));
      });
    } else {
      print(response.file);
    }
  }
  Future uploadFile() async {
    List<String> imageUrlList = [];
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('Store Item/${Path.basename(img.path)}');
      await ref!.putFile(img).whenComplete(() async {
        final String downloadUrl = await ref!.getDownloadURL();
        imageUrlList.add(downloadUrl);
        i++;
      });
    }
    FirebaseFirestore.instance.collection('StoreItem2').doc(widget.s_list[widget.index]["refId"].toString()).update({
      'searchKey': _nameController.text[0].toUpperCase(),
      'shopItemName' : _nameController.text,
      'shopItemType': selectedCatrgory.toString(),
      'shopItem': selectedItem.toString(),
      'price': _priceController.text,
      'shopName': 'Kay Clothing',
      'discount': _discountChargeController.text,
      'startDate': _startDate.text,
      'endDate': _endDate.text,
      'discount2': _discountChargeController2.text,
      'startDate2': _startDate2.text,
      'endDate2': _endDate2.text,
      'size':[
        {'size': 'small', 'quantity': int.parse(_small.text)},
        {'size': 'medium', 'quantity': int.parse(_medium.text)},
        {'size': 'large', 'quantity': int.parse(_large.text)},
        {'size': 'xl', 'quantity': int.parse(_xl.text)},
        {'size': 'xxl', 'quantity': int.parse(_xxl.text)},
        {'size': 'xxxl', 'quantity': int.parse(_xxxl.text)},
        {'size': 'freeSize', 'quantity': int.parse(_freeSize.text)},
      ],
      'status': 'unblock',
      'imageUrl': FieldValue.arrayUnion(imageUrlList),
    });
  }
}