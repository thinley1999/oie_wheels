import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:oie_wheels/content/shop.dart';


class Location2 extends StatefulWidget {
  @override
  _Location2State createState() => _Location2State();
}

class _Location2State extends State<Location2> {

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
        'location': true,
      }).then((value) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Shop()));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
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
            ),
            SizedBox(height: 30.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('DENY', style: GoogleFonts.inter(fontSize: 15.sp))
                  ),
                  TextButton(
                      onPressed: () {
                        _getUserLocation();
                      },
                      child: Text('ACCEPT', style: GoogleFonts.inter(fontSize: 15.sp))
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
