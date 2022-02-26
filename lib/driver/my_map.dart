import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  final String user_id;
  MyMap(this.user_id);
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  @override
  void initState(){
  super.initState();
  setCustomMarker();
  }

  late BitmapDescriptor mapMarker;
  void setCustomMarker() async{
    mapMarker = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/driver.png');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Driver').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (_added) {
              mymap(snapshot);
            }
            if (snapshot.hasData) {
              for(int i =0; i<snapshot.data!.docs.length; i++){
                return GoogleMap(
                  mapType: MapType.normal,
                  markers: {
                    Marker(
                      markerId: MarkerId('id'),
                        position: LatLng(
                          snapshot.data!.docs[i]['latitude'],
                          snapshot.data!.docs[i]['longitude'],
                        ),
                        infoWindow: InfoWindow(
                          title: 'Name: ' + snapshot.data!.docs[i]['firstName'] + ' ' + snapshot.data!.docs[i]['lastName'],
                          snippet: 'Contact: ' + snapshot.data!.docs[i]['phone'],
                        ),
                        icon: mapMarker,
                    ),
                  },
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                        snapshot.data!.docs.singleWhere(
                                (element) => element.id == widget.user_id)['latitude'],
                        snapshot.data!.docs.singleWhere(
                                (element) => element.id == widget.user_id)['longitude'],
                      ),
                      zoom: 14.47),
                  onMapCreated: (GoogleMapController controller) async {
                    setState(() {
                      _controller = controller;
                      _added = true;
                    });
                  },
                );
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
          snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['latitude'],
          snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['longitude'],
        ),
        zoom: 14.47)));
  }
}