import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/navbar/edit_profile.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  Future<DocumentSnapshot> getUserInfo()async{
    return await FirebaseFirestore.instance.collection("Users").doc((_auth.currentUser)!.uid).get();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Profile', style: GoogleFonts.inter(
              fontSize: 15.sp, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottomOpacity: 0.0,
          elevation: 0.0, backgroundColor: Color(0xFF1976D2)
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child:  FutureBuilder(
            future: getUserInfo(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title:
                        Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                snapshot.data!["imageUrl"],
                              ),
                              radius: 70.h,
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
                                SizedBox(width: 10.w,),
                                Text(
                                  snapshot.data!["lastName"],
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: Container(
                                height: 45.h,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Color(0xffBDBDBD))),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: TextFormField(
                                    style: GoogleFonts.inter(fontSize: 13.sp),
                                    textAlign: TextAlign.right,
                                    enabled: false,
                                    controller: TextEditingController(text: "+975-"+ snapshot.data!["phone"]),
                                    decoration: InputDecoration(
                                        floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        icon: Icon(Icons.phone_outlined, color: Colors.amber[700],size: 20.sp,),
                                        prefixText: "Phone",
                                        prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: Container(
                                height: 45.h,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Color(0xffBDBDBD))),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: TextFormField(
                                    style: GoogleFonts.inter(fontSize: 13.sp),
                                    textAlign: TextAlign.right,
                                    enabled: false,
                                    controller: TextEditingController(text: snapshot.data!["email"]),
                                    decoration: InputDecoration(
                                      floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      icon: Icon(Icons.email_outlined, color: Colors.amber[700],size: 20.sp,),
                                      prefixText: "Email",
                                      prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: Container(
                                height: 45.h,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Color(0xffBDBDBD))),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: TextFormField(
                                    style: GoogleFonts.inter(fontSize: 13.sp),
                                    textAlign: TextAlign.right,
                                    enabled: false,
                                    controller: TextEditingController(text: snapshot.data!["deliveryAddress"]),
                                    decoration: InputDecoration(
                                      floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      icon: Icon(Icons.pin_drop_outlined, color: Colors.amber[700],size: 20.sp,),
                                      prefixText: "Address",
                                      prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                              },
                              child: Container(
                                  height: 35.h,
                                  width: 110.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.amber[700],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "EDIT PROFILE",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
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
      ),
    );
  }
}
