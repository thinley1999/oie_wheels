import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQ extends StatefulWidget {
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  bool isReadMore = false;

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
          title: Text('FAQ', style: GoogleFonts.inter(
              fontSize: 15.sp, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottomOpacity: 0.0,
          elevation: 0.0,
          backgroundColor: Color(0xFF1976D2),
        ),
      ),
      body:  StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Faq').orderBy('dateTime', descending: false).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: SpinKitWave(
                  size: 30.sp,
                  color: Colors.amber[900],
                  duration:  Duration(milliseconds: 800),
                ),
              );
            }
            return Column(
              children: [
                Container(
                  height: 70.h,
                  child: Center(
                      child: Image.asset(
                        'assets/logo.jpg',
                        width: size.width,
                      )
                  ),
                ),
                Expanded(child: ListView(children: getExpenseItems(snapshot))),
              ],
            );
          })
    );
  }
  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((doc) => (doc['status'] == 'unblock' ) ? Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Card(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ExpansionTile(
            childrenPadding: EdgeInsets.all(16).copyWith(top: 0),
              title: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(doc["title"], style: GoogleFonts.inter(fontSize: 13.sp)),
              ),
              children: [
                Text(doc["description"], style: GoogleFonts.inter(fontSize: 13.sp))
              ],
          ),
        ),
      ),
    ) : Container()).toList();
  }

}


