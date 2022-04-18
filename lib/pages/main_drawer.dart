import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/authenticate/methods.dart';
import 'package:oie_wheels/content/order_history.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:oie_wheels/navbar/about_us.dart';
import 'package:oie_wheels/navbar/edit_profile.dart';
import 'package:oie_wheels/navbar/faq.dart';
import 'package:oie_wheels/navbar/notification.dart';
import 'package:oie_wheels/navbar/profile.dart';
import 'package:oie_wheels/pages/utils.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  Future<DocumentSnapshot> getUserInfo()async{
    return await FirebaseFirestore.instance.collection("Users").doc((_auth.currentUser)!.uid).get();
  }

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
          child: Stack(
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
                      leading: Icon(Icons.home_outlined, color: Colors.amber[700], size: 28.sp,),
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
                    leading: Icon(Icons.watch_later_outlined, color: Colors.amber[700], size: 28.sp,),
                    title: Text(
                      'Order History',
                      style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderHistory()));
                    },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.notifications_outlined, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Notification',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications()));
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.person_outline, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Profile',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()),);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.people_alt_outlined, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'About Us',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUs()));
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.phone_android_outlined, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Call Us',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Utils.openPhoneCall(phoneNumber:  '1254');
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.star_outline, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'Rate Us',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        StoreRedirect.redirect(androidAppId: 'com.druksmart.oie_wheels');
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.question_answer_outlined, color: Colors.amber[700], size: 28.sp,),
                      title: Text(
                        'FAQ',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FAQ()));
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.logout_outlined, color: Colors.amber[700],size: 28.sp),
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
