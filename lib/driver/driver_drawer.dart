import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/authenticate/methods.dart';
import 'package:oie_wheels/driver/edit_profile.dart';
import 'package:oie_wheels/driver/notification.dart';
import 'package:oie_wheels/driver/profile.dart';

class DriverDrawer extends StatefulWidget {
  @override
  _DriverDrawerState createState() => _DriverDrawerState();
}

class _DriverDrawerState extends State<DriverDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  Future<DocumentSnapshot> getUserInfo()async{
    return await FirebaseFirestore.instance.collection("Driver").doc((_auth.currentUser)!.uid).get();
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
                  ListTile(
                    leading: Icon(FontAwesomeIcons.fileAlt, color: Colors.amber[700], size: 28.sp,),
                    title: Text(
                      'Orders',
                      style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                    },
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.bell, color: Colors.amber[700], size: 28.sp,),
                    title: Text(
                      'Notification',
                      style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications()));
                    },
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.user, color: Colors.amber[700], size: 28.sp,),
                    title: Text(
                      'Profile',
                      style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                    },
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.signOutAlt, color: Colors.amber[700],size: 28.sp),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      logOut(context);
                    },
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
