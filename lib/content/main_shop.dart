import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/content/shop.dart';
import 'package:scroll_indicator/scroll_indicator.dart';

class MainShop extends StatefulWidget {
  @override
  _MainShopState createState() => _MainShopState();
}

class _MainShopState extends State<MainShop> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
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

  final controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async{
        _onPressed();
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFE8EAF6),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.h),
          child: AppBar(
              leading: IconButton(
                icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
                onPressed: () {
                  _onPressed();
                  Navigator.pop(context);
                },
              ),
              title: Text('Shop', style: GoogleFonts.inter(
                  fontSize: 15.sp, fontWeight: FontWeight.bold)),
              centerTitle: true,
              bottomOpacity: 0.0,
              elevation: 0.0, backgroundColor: Color(0xFF1976D2)
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('ShopItemCategory').orderBy('dateTime', descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  SizedBox(
                    height: 220.h,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        controller: controller,
                        itemBuilder: (BuildContext context, int index) {
                          final document = snapshot.data!.docs[index];
                          return Card(
                            elevation: 5,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Ink.image(
                                  image: NetworkImage(
                                      document['imageUrl']
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      FirebaseFirestore.instance.collection('View').doc((_auth.currentUser)!.uid).collection('Shop').doc((_auth.currentUser)!.uid).set(
                                          {
                                            'shopItemType': document['shopItemType'],
                                            'shopName': 'Kay Clothing',
                                          }
                                      );
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Shop()));
                                    },
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  width: size.width,
                                  color: Color.fromRGBO(0, 0, 0, 0.4),
                                  child: Text(
                                    document['shopItemType'],
                                    style: GoogleFonts.cinzel(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: snapshot.data!.docs.length,
                      ),
                    ),
                  ),
                  ScrollIndicator(
                    scrollController: controller,
                    width: 50.w,
                    height: 10.h,
                    indicatorWidth: 20.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.sp),
                        color: Colors.grey[400]),
                    indicatorDecoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(10.sp)),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('ShopItemCategory').orderBy('shopItemType', descending: false).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AlphabetScrollView(
                              list: snapshot.data!.docs.map((e) => AlphaModel(e['shopItemType'])).toList(),
                              alignment: LetterAlignment.right,
                              itemExtent: 35.h,
                              selectedTextStyle: GoogleFonts.inter(fontSize: 16.sp),
                              unselectedTextStyle: GoogleFonts.inter(fontSize: 16.sp),
                              overlayWidget: (value) => Container(
                                height: 40.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                    color: Color(0xFF1976D2),
                                    borderRadius: BorderRadius.circular(5.sp)
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$value'.toUpperCase(),
                                  style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                              itemBuilder: (_, k, id) {
                                var document = snapshot.data!.docs[k];

                                return ListTile(
                                  title: Text('$id', style: GoogleFonts.inter(fontSize: 16.sp)),
                                  leading: Container(
                                    height: 30.h,
                                    width: 30.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber[900],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${document['searchKey']}'.toUpperCase(),
                                      style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  onTap: () {
                                    FirebaseFirestore.instance.collection('View').doc((_auth.currentUser)!.uid).collection('Shop').doc((_auth.currentUser)!.uid).set(
                                        {
                                          'shopItemType': document['shopItemType'],
                                          'shopName': 'Kay Clothing',
                                        }
                                    );
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Shop()));
                                  },
                                );
                              }
                          );
                        }
                        return Center(
                          child: SpinKitWave(
                            size: 30.sp,
                            color: Colors.amber[900],
                            duration:  Duration(milliseconds: 800),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: SpinKitWave(
                size: 30.sp,
                color: Colors.amber[900],
                duration:  Duration(milliseconds: 800),
              ),
            );
          },
        ),
      ),
    );
  }
}
