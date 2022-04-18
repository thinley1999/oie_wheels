import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/authenticate/login.dart';
import 'package:oie_wheels/authenticate/methods.dart';
import 'package:oie_wheels/driver/driver_home.dart';
import 'package:oie_wheels/pages/home.dart';
import 'package:oie_wheels/shop/shop_home.dart';

class Authenticate extends StatefulWidget {
  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  verifyUser() async{
    String a = _auth.currentUser!.uid;
    DocumentSnapshot result = await FirebaseFirestore.instance.collection("AllUsers").doc(a).get();
    if(result['role'] == 'driver'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverHome()));
    }
    else if(result['role'] == 'shop owner'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShopHome()));
    }
    else if(result['role'] == 'block') {
      logOut(context);
      Fluttertoast.showToast(
          msg: "Your account has been block.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else if(result['role'] == 'restaurant owner') {
      logOut(context);
      Fluttertoast.showToast(
          msg: "This portal is not for restaurant owner",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      verifyUser();
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 30.sp, color: Colors.blue),
              Text('Use your location', style: GoogleFonts.inter(fontSize: 25.sp, color: Colors.black)),
              SizedBox(height: 30.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.sp),
                child: Text('OieWheels collects location data to enable delivery address even when the app is closed or not in use.', style: GoogleFonts.inter(fontSize: 13.sp)),
              ),
              SizedBox(height: 30.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.sp),
                child: Image.asset('assets/location.jpg'),
              )
            ],
          ),
        ),
      );
    } else {
      return Login();
    }
  }
}

