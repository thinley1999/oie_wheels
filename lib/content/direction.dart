import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class Direction extends StatefulWidget {
  @override
  _DirectionState createState() => _DirectionState();
}

class _DirectionState extends State<Direction> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  GoogleMapController? mapController; //contrller for Google map
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyAroZNzwV9wOTEmpREoKmkw-XpYTGZN_Xc";

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  double distance = 0.0;


  @override
  void initState() {
    _getAddress();
    super.initState();
  }

  void _getAddress() {
    FirebaseFirestore.instance
        .collection('EditItem')
        .doc((_auth.currentUser)!.uid)
        .collection('Direction')
        .doc((_auth.currentUser)!.uid)
        .get().then((value){
      lat1 = value.data()!['lat2'];
      lon1 = value.data()!['lon2'];
      lat2 = value.data()!['lat'];
      lon2 = value.data()!['lon'];
      setState(() {
        markers.add(Marker( //add distination location marker
          markerId: MarkerId(LatLng(lat1, lon1).toString()),
          position: LatLng(lat1, lon1), //position of marker
          infoWindow: InfoWindow( //popup info
            title: 'Driver Location',
            snippet: 'Starting Point',
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
        markers.add(Marker( //add distination location marker
          markerId: MarkerId(LatLng(lat2, lon2).toString()),
          position: LatLng(lat2, lon2), //position of marker
          infoWindow: InfoWindow( //popup info
            title: 'Your Location',
            snippet: 'Destination Point',
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
      });
    }).then((value) =>  getDirections());
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(LatLng(lat1, lon1).latitude, LatLng(lat1, lon1).longitude),
      PointLatLng(LatLng(lat2, lon2).latitude, LatLng(lat2, lon2).longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for(var i = 0; i < polylineCoordinates.length-1; i++){
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i+1].latitude,
          polylineCoordinates[i+1].longitude);
    }

    setState(() {
      distance = totalDistance;
    });

    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color(0xFF1976D2),
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  var lat1;
  var lon1;
  var lat2;
  var lon2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.h),
          child: AppBar(
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Direction', style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0,
            backgroundColor: Color(0xFF1976D2),
          ),
        ),
        body: (lat1 != null && lat2 != null && lon1 != null && lon2 != null) ? Stack(
            children:[
              GoogleMap(
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat1, lon1),
                  zoom: 13,
                ),
                markers: markers, //markers to show on map
                polylines: Set<Polyline>.of(polylines.values), //polylines
                mapType: MapType.normal, //map type
                onMapCreated: (controller) { //method called when map is created
                  setState(() {
                    mapController = controller;
                  });
                },
              ),
              Positioned(
                  bottom: 200,
                  left: 50,
                  child: Container(
                      child: Card(
                        child: Container(
                            padding: EdgeInsets.all(20),
                            child: Text("Total Distance: " + distance.toStringAsFixed(2) + " KM",
                                style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold))
                        ),
                      )
                  )
              )
            ]
        )
            : Center(child: SpinKitWave(
          size: 30.sp,
          color: Colors.amber[900],
          duration:  Duration(milliseconds: 800),
        ))
    );
  }
}
