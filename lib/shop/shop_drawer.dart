import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/authenticate/methods.dart';
import 'package:oie_wheels/shop/customer_feedback.dart';
import 'package:oie_wheels/shop/edit_profile.dart';
import 'package:oie_wheels/shop/main_order_management.dart';
import 'package:oie_wheels/shop/main_shop_item.dart';
import 'package:oie_wheels/shop/my_shop.dart';
import 'package:oie_wheels/shop/notification.dart';

class ShopDrawer extends StatefulWidget {
  @override
  _ShopDrawerState createState() => _ShopDrawerState();
}

class _ShopDrawerState extends State<ShopDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  Future<DocumentSnapshot> getUserInfo()async{
    return await FirebaseFirestore.instance.collection("ShopOwner").doc((_auth.currentUser)!.uid).get();
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('ShopOwner').doc((_auth.currentUser)!.uid).get().then((value){
      setState(() {
        shopName = value.data()!['shopName'];
      });
    });
  }

  var shopName;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Color(0xFFE8EAF6),
        //other styles
      ),
      child: Container(
        width: 250.w,
        child: Drawer(
          child:  Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 210.h,
                    padding: const EdgeInsets.all(8),
                    child:  FutureBuilder(
                      future: getUserInfo(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          snapshot.data!["imageUrl"],
                                        ),
                                        radius: 70.sp,
                                        backgroundColor: Colors.transparent,
                                      ),
                                      SizedBox(height: 10.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(snapshot.data!["firstName"],
                                            style: GoogleFonts.inter(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            snapshot.data!["lastName"],
                                            style: GoogleFonts.inter(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
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
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.home, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Home',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.bell, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Notification',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection("OrderHistory")
                            .where('orderFrom', isEqualTo: shopName)
                            .where('status', isEqualTo: 'unassigned orders')
                            .where('seen', isEqualTo: false)
                            .get()
                            .then((value) {
                          value.docs.forEach((result) {
                            FirebaseFirestore.instance
                                .collection('OrderHistory')
                                .doc(result.data()['orderId'])
                                .update({
                              'seen': true,
                            });
                          });
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications()));
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.shoppingCart, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Order Management',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainOrderManagement()));
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.fileAlt, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Item List',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainShopItem()));
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.comment, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Customer Feedback',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerFeedback()));
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.building, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'My Shop Details',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyShop()));
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.signOutAlt, color: Colors.amber[700],size: 28.sp),
                      title: Text(
                        'Logout',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        logOut(context);
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 30.h,
                right: 10.w,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                  },
                  icon: Icon(Icons.edit, color: Color(0xFF757575), size: 20.sp,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
