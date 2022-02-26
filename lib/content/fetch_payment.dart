import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';

class FetchPayment extends StatefulWidget {
  final List<DocumentSnapshot> p_list;
  final int index;

  const FetchPayment({Key? key, required this.p_list, required this.index}) : super(key: key);
  @override
  _FetchPaymentState createState() => _FetchPaymentState();
}

class _FetchPaymentState extends State<FetchPayment> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  final _formKey= GlobalKey<FormState>();
  TextEditingController _paymentDate = TextEditingController();
  TextEditingController _jrnlNo = TextEditingController();
  TextEditingController _amountPaid = TextEditingController();

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
                    child: Text('Payment Date*', style: GoogleFonts.inter()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        controller: _paymentDate, //editing controller of this TextField
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10.w),
                          hintText: 'Select Date',
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
                              _paymentDate.text = formattedDate; //set output date to TextField value.
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
                    child: Text('Jrnl.No*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _jrnlNo,
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
                    child: Text('Amount*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _amountPaid,
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
                    child: Text('Screen Shot*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Stack(
                    children: [
                      GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: _image.length + 1,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return index == 0
                                ? Container(
                              color: Color(0xFFE8EAF6),
                              margin: EdgeInsets.only(left: 3.w, top: 3.h,),
                              child: IconButton(
                                  icon: Image.asset('assets/add image.png'),
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
                      "Add Payment",
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
                            msg: 'Add Payment Success',
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 13.sp
                        );
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Add Payment Fails',
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
    DocumentReference mainRef = FirebaseFirestore.instance
        .collection('OrderHistory').doc(widget.p_list[widget.index]["orderId"].toString());
    List<String> imageUrlList = [];
    int i = 1;
    var amount = int.parse(_amountPaid.text);
    var totalAmount = widget.p_list[widget.index]["totalAmount"];
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('Payment Image/${Path.basename(img.path)}');
      await ref!.putFile(img).whenComplete(() async {
        final String downloadUrl = await ref!.getDownloadURL();
        imageUrlList.add(downloadUrl);
        i++;
      });
    }
    mainRef.update({
      'paymentDate': _paymentDate.text,
      'jrnlNo': _jrnlNo.text,
      'received from customer': int.parse(_amountPaid.text),
      'screenShot': imageUrlList,
      'status': (amount >= totalAmount) ? 'paid' : 'partially paid'
    });
    FirebaseFirestore.instance
        .collection("Order")
        .doc((_auth.currentUser)!.uid)
        .collection("ConfirmOrder")
        .where('dateTime', isEqualTo: widget.p_list[widget.index]["dateTime"].toString())
        .get()
        .then((value) {
      value.docs.forEach((result) {
        FirebaseFirestore.instance
            .collection('Order')
            .doc((_auth.currentUser)!.uid)
            .collection('ConfirmOrder')
            .doc(result.data()['oId'])
            .update({
          'status': (amount >= totalAmount) ? 'paid' : 'partially paid',
        });
      });
    });
  }
}

class FetchPartiallyPaid extends StatefulWidget {
  final List<DocumentSnapshot> p_list;
  final int index;

  const FetchPartiallyPaid({Key? key, required this.p_list, required this.index}) : super(key: key);
  @override
  _FetchPartiallyPaidState createState() => _FetchPartiallyPaidState();
}

class _FetchPartiallyPaidState extends State<FetchPartiallyPaid> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  final _formKey= GlobalKey<FormState>();
  TextEditingController _jrnlNo = TextEditingController();
  TextEditingController _amountPaid = TextEditingController();

  bool uploading = false;
  double val = 0;
  firebase_storage.Reference ? ref;
  List<File> _image = [];
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    var amountLeft = widget.p_list[widget.index]["totalAmount"] - widget.p_list[widget.index]["received from customer"];
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
                    child: Text('Amount Left to Pay*', style: GoogleFonts.inter()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        controller: TextEditingController(text: amountLeft.toString()),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10.w),
                          hintText: 'Select Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        readOnly: true,
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
                    child: Text('Jrnl.No*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _jrnlNo,
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
                            return 'Please enter jrnl.no';
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
                    child: Text('Amount*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SizedBox(
                      height: 38.h,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 13.sp),
                        textAlign: TextAlign.start,
                        controller: _amountPaid,
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
                          var amount = int.parse(_amountPaid.text);
                          if(value!.isEmpty) {
                            return 'Please enter item name';
                          }
                          if(amount < amountLeft) {
                            return 'The amount can not be lesser than $amountLeft';
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
                    child: Text('Screen Shot*', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                  Stack(
                    children: [
                      GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: _image.length + 1,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return index == 0
                                ? Container(
                              color: Color(0xFFE8EAF6),
                              margin: EdgeInsets.only(left: 3.w, top: 3.h,),
                              child: IconButton(
                                  icon: Image.asset('assets/add image.png'),
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
                      "Add Payment",
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
                            msg: 'Add Payment Success',
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 13.sp
                        );
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Add Payment Fails',
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
    int amountPaid = int.parse(_amountPaid.text);
    DocumentReference mainRef = FirebaseFirestore.instance
        .collection('OrderHistory').doc(widget.p_list[widget.index]["orderId"].toString());
    List<String> imageUrlList = [];
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('Payment Image/${Path.basename(img.path)}');
      await ref!.putFile(img).whenComplete(() async {
        final String downloadUrl = await ref!.getDownloadURL();
        imageUrlList.add(downloadUrl);
        i++;
      });
    }
    mainRef.update({
      'jrnlNo': widget.p_list[widget.index]["jrnlNo"].toString() +'\n'+ _jrnlNo.text,
      'received from customer': amountPaid + widget.p_list[widget.index]["received from customer"],
      'screenShot': FieldValue.arrayUnion(imageUrlList),
      'status': 'paid'
    });
    FirebaseFirestore.instance
        .collection("Order")
        .doc((_auth.currentUser)!.uid)
        .collection("ConfirmOrder")
        .where('dateTime', isEqualTo: widget.p_list[widget.index]["dateTime"].toString())
        .get()
        .then((value) {
      value.docs.forEach((result) {
        FirebaseFirestore.instance
            .collection('Order')
            .doc((_auth.currentUser)!.uid)
            .collection('ConfirmOrder')
            .doc(result.data()['oId'])
            .update({
          'status': 'paid',
        });
      });
    });
  }
}

