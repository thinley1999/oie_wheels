import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/content/fetch_payment.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
              onPressed: () =>  Navigator.pop(context),
            ),
            title: Text('Add Payment Details', style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0, backgroundColor: Color(0xFF1976D2)
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("EditItem")
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
              return ListView.builder(itemCount:snapshot.data!.docs.length,itemBuilder: (_,index){
                List<DocumentSnapshot> userDocument = snapshot.data!.docs;
                return Column(
                  children: [
                    FetchPayment(p_list: userDocument,index: index,),
                  ],
                );
              });
          }
        },
      )
    );
  }
}

class PartiallyPaid extends StatefulWidget {
  @override
  _PartiallyPaidState createState() => _PartiallyPaidState();
}

class _PartiallyPaidState extends State<PartiallyPaid> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFE8EAF6),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.h),
          child: AppBar(
              leading: IconButton(
                icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
                onPressed: () =>  Navigator.pop(context),
              ),
              title: Text('Add Payment Details', style: GoogleFonts.inter(
                  fontSize: 15.sp, fontWeight: FontWeight.bold)),
              centerTitle: true,
              bottomOpacity: 0.0,
              elevation: 0.0, backgroundColor: Color(0xFF1976D2)
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("EditItem")
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
                return ListView.builder(itemCount:snapshot.data!.docs.length,itemBuilder: (_,index){
                  List<DocumentSnapshot> userDocument = snapshot.data!.docs;
                  return Column(
                    children: [
                      FetchPartiallyPaid(p_list: userDocument,index: index,),
                    ],
                  );
                });
            }
          },
        )
    );
  }
}

