import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/content/fetch_store.dart';
import 'package:oie_wheels/content/order_summary.dart';

class Store extends StatefulWidget {
  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  Future<DocumentSnapshot> getRestaurant()async{
    return await FirebaseFirestore.instance
        .collection("View")
        .doc((_auth.currentUser)!.uid)
        .collection("StoreItem")
        .doc((_auth.currentUser)!.uid)
        .get();
  }

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
            .collection('Item')
            .doc(result.data()['oId'])
            .delete();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
        onWillPop: () async{
          _onPressed();
          Navigator.of(context).pop();
          return true;
        },
        child: Scaffold(
          backgroundColor: Color(0xFFE8EAF6),
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(90.h),
              child:  Column(
                children: [
                  Expanded(
                    child: AppBar(
                        leading: IconButton(
                          icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
                          onPressed: () {
                            _onPressed();
                            Navigator.of(context).pop();
                          },
                        ),
                        title: FutureBuilder(
                          future: getRestaurant(),
                          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return Text(
                                  snapshot.data!['restaurantName'], style: GoogleFonts.roboto(
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
                    height: 50.h,
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
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: TabBar(
                              isScrollable: true,
                              indicatorColor: Colors.amber[900],
                              indicatorWeight: 5.sp,
                              tabs: [
                                Text('MENU', style: GoogleFonts.roboto(fontSize: 12.sp)),
                                Text('RESTAURANT FACTS', style: GoogleFonts.roboto(fontSize: 12.sp)),
                                Text('CUSTOMER FEEDBACK', style: GoogleFonts.roboto(fontSize: 12.sp)),
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
              _menu(context),
              RestaurantFacts(),
              CustomerFeedBack()
            ],
          )
          ,
        ),
      ),
    );
  }
  Widget _menu(BuildContext context){
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("View")
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
                return ListView.builder(
                  shrinkWrap: true,
                    itemCount:snapshot.data!.docs.length,
                    itemBuilder: (_,index){
                  List<DocumentSnapshot> userDocument = snapshot.data!.docs;
                  return FetchStore(s_list: userDocument,index: index);
                });
            }
          },
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Order').doc((_auth.currentUser)!.uid).collection('Item').where('status', isEqualTo: 'draft')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var ds = snapshot.data!.docs;
                  double sum = 0.0;
                  for(int i=0; i<ds.length;i++) sum+=(ds[i]['price']*ds[i]['orderCount']).toDouble();
                  return (ds.length>0)
                      ?Container(
                    height: 40.h,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: MediaQuery.of(context).size.width/2,
                            color: Colors.black.withOpacity(0.65),
                            child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.w),
                                      child: Row(
                                        children: [
                                          Stack(
                                            children: [
                                              Icon(FontAwesomeIcons.shoppingBasket, size: 20.sp, color: Colors.white),
                                              Positioned(
                                                  left: 6.5.w,
                                                  bottom: 5.h,
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        width: 13.w,
                                                        height: 13.h,
                                                        decoration: BoxDecoration(
                                                            color: Color(0xFFFF6F00).withOpacity(0.9),
                                                            shape: BoxShape.circle
                                                        ),
                                                        child: Center(child: Text(snapshot.data!.size.toString(), style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white))),
                                                      )
                                                    ],
                                                  )
                                              )
                                            ],
                                          ),
                                          SizedBox(width: 10.w),
                                          Text('TOTAL',style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.sp)),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 10.w),
                                      child: Text('BTN $sum',style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.sp)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> OrderSummary()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width/2,
                            color: Color(0xFFFF6F00).withOpacity(0.9),
                            child: Center(
                                child: Text('PLACE ORDER', style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900))
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  :Container();
                }
                return Container();
              },
            ),
          ),
        )
      ],
    );
  }
}

class RestaurantFacts extends StatefulWidget {
  @override
  _RestaurantFactsState createState() => _RestaurantFactsState();
}

class _RestaurantFactsState extends State<RestaurantFacts> {
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
            return ListView.builder(
                shrinkWrap: true,
                itemCount:snapshot.data!.docs.length,
                itemBuilder: (_,index){
                  List<DocumentSnapshot> userDocument = snapshot.data!.docs;
                  return FetchRestaurantFacts(f_list: userDocument,index: index);
                });
        }
      },
    );
  }
}

class CustomerFeedBack extends StatefulWidget {
  @override
  _CustomerFeedBackState createState() => _CustomerFeedBackState();
}

class _CustomerFeedBackState extends State<CustomerFeedBack> {
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
            return ListView.builder(
                shrinkWrap: true,
                itemCount:snapshot.data!.docs.length,
                itemBuilder: (_,index){
                  List<DocumentSnapshot> userDocument = snapshot.data!.docs;
                  return FetchCustomerFeedBack(c_list: userDocument,index: index);
                });
        }
      },
    );
  }
}






