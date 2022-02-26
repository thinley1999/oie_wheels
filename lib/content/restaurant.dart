import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/content/fetch_restaurant.dart';

class Restaurant extends StatefulWidget {
  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<Restaurant> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  Future<DocumentSnapshot> getItemType()async{
    return await FirebaseFirestore.instance
        .collection("View")
        .doc((_auth.currentUser)!.uid)
        .collection("Restaurant")
        .doc((_auth.currentUser)!.uid)
        .get();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFFE8EAF6),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(140.h),
          child:  Column(
            children: [
              Expanded(
                child: AppBar(
                    leading: IconButton(
                      icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: FutureBuilder(
                      future: getItemType(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Text(
                              snapshot.data!['cuisineType'], style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 18.sp,
                          ));
                        } else if (snapshot.connectionState == ConnectionState.none) {
                          return Text("No data");
                        }
                        return Center(child: SpinKitWave(
                          size: 30.sp,
                          color: Colors.amber[900],
                          duration:  Duration(milliseconds: 800),
                        ));
                      },
                    ),
                    centerTitle: true,
                    bottomOpacity: 0.0,
                    elevation: 0.0, backgroundColor: Color(0xFF1976D2)
                ),
              ),
              SizedBox(
                height: 100.h,
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Container(
                      color: Color.fromRGBO(0, 0, 0, 0.4),
                    ),
                    Ink.image(
                      image: AssetImage(
                        'assets/main_restaurant.jpg',
                      ),
                      child: InkWell(
                        onTap: () async{
                        },
                      ),
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w, top: 20.h),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.utensils, color: Colors.amber[900], size: 20.sp),
                          SizedBox(width: 10.w),
                          Text(
                            'RESTAURANTS',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: TabBar(
                        isScrollable: false,
                          indicatorColor: Colors.amber[900],
                          indicatorWeight: 5.sp,
                          tabs: [
                            Text('ALL', style: GoogleFonts.roboto(fontSize: 12.sp)),
                            Text('OPEN NOW', style: GoogleFonts.roboto(fontSize: 12.sp)),
                            Text('CLOSE TODAY', style: GoogleFonts.roboto(fontSize: 12.sp)),
                          ]
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ),
        body: TabBarView(
          children: [
            AllRestaurant(),
            OpenNow(),
            CloseToday(),
          ],
        )
        ,
      ),
    );
  }
}

class AllRestaurant extends StatefulWidget {
  @override
  _AllRestaurantState createState() => _AllRestaurantState();
}

class _AllRestaurantState extends State<AllRestaurant> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("View")
          .doc((_auth.currentUser)!.uid)
          .collection("Restaurant").snapshots(),
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
                  FetchAllRestaurant(r_list: userDocument,index: index),
                ],
              );
            });
        }
      },
    );
  }
}

class OpenNow extends StatefulWidget {
  @override
  _OpenNowState createState() => _OpenNowState();
}

class _OpenNowState extends State<OpenNow> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("View")
          .doc((_auth.currentUser)!.uid)
          .collection("Restaurant").snapshots(),
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
                  FetchOpenNow(r_list: userDocument,index: index),
                ],
              );
            });
        }
      },
    );
  }
}

class CloseToday extends StatefulWidget {
  @override
  _CloseTodayState createState() => _CloseTodayState();
}

class _CloseTodayState extends State<CloseToday> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("View")
          .doc((_auth.currentUser)!.uid)
          .collection("Restaurant").snapshots(),
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
                  FetchCloseToday(r_list: userDocument,index: index),
                ],
              );
            });
        }
      },
    );
  }
}



