import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/shop/shop_item.dart';

class MainShopItem extends StatefulWidget {
  @override
  _MainShopItemState createState() => _MainShopItemState();
}

class _MainShopItemState extends State<MainShopItem> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }


  var dataList;
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        dataList = FirebaseFirestore.instance.collection('StoreItem2').where('uid', isEqualTo: (_auth.currentUser)!.uid)
            .orderBy('dateTime', descending: true).snapshots();
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue = value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      dataList(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['shopItemName'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dataList = FirebaseFirestore.instance.collection('StoreItem2').where('uid', isEqualTo: (_auth.currentUser)!.uid)
        .orderBy('dateTime', descending: true).snapshots();
  }

  var entries = 10;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<ShopItem> items;
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 20.sp,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.sp, color: Colors.white),
              ),
            ),
            margin: EdgeInsets.only(bottom: 2.h),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.search,
                  color: Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w,),
                Expanded(
                  child: TextFormField(
                    style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: "Search Item",
                      hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
                    ),
                    onChanged: (val) {
                      initiateSearch(val);
                      setState(() {
                        dataList = FirebaseFirestore.instance
                            .collection('StoreItem2')
                            .where('uid', isEqualTo: (_auth.currentUser)!.uid)
                            .where('searchKey',
                            isEqualTo: val.substring(0, 1).toUpperCase())
                            .snapshots();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          bottomOpacity: 0.0,
          elevation: 0.0,
          backgroundColor: Color(0xFF1976D2),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Show', style: GoogleFonts.inter(fontSize: 13.sp)),
                        SizedBox(
                          height: 25.h,
                          width: 55.w,
                          child: DropdownButtonFormField<int>(
                              value: entries,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.w),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              items: <int>[10, 25, 50, 100].map((int value) {
                                return new DropdownMenuItem<int>(
                                  value: value,
                                  child: new Text(value.toString(), style: GoogleFonts.inter(fontSize: 13.sp),),
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                setState(() {
                                  entries = newVal!;
                                });
                              }),
                        ),
                        Text('entries', style: GoogleFonts.inter(fontSize: 13.sp)),
                      ],
                    ),
                    ElevatedButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                              "Add Item",
                              style: GoogleFonts.inter(fontSize: 13.sp)
                          ),
                        ),
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF1976D2)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.sp),
                                    side: BorderSide(color: Color(0xFF1976D2))
                                )
                            )
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddShopItem()));
                        }
                    )
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: dataList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: SpinKitWave(
                      size: 30.sp,
                      color: Colors.amber[900],
                      duration:  Duration(milliseconds: 800),
                    ));
                  } else {
                    items = snapshot.data!.docs.map((doc) => ShopItem.fromMap(doc.data() as Map<dynamic, dynamic>)).toList();
                    var itemData = ItemDataSource(items, context);
                    return snapshot.data!.docs.isNotEmpty ? PaginatedDataTable(
                      horizontalMargin: 3.w,
                      columnSpacing: 5.w,
                      dataRowHeight: 50.h,
                      columns: [
                        DataColumn(label: Text('Item Name', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp))),
                        DataColumn(label: Text('Item Type', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp))),
                        DataColumn(label: Text('Price', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp))),
                        DataColumn(label: Text('Action', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp))),
                      ],
                      rowsPerPage: (snapshot.data!.docs.length > 9) ? entries : snapshot.data!.docs.length,
                      source: itemData,
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.folder, size: 80.sp, color: Colors.amber[900]),
                        Text('No Data Found', style: GoogleFonts.inter(fontSize: 20.sp, color: Colors.amber[900])),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemDataSource extends DataTableSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }
  final context;
  List<ShopItem> items;

  ItemDataSource(this.items, this.context);

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
        color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (index % 2 == 0)
                return Color(0xFFEEEEEE).withOpacity(0.35);
              return Colors.white;
            }),
        cells: [
          DataCell(SizedBox(
              width: 80.w,
              child: Text(items[index].shopItemName, style: GoogleFonts.inter(fontSize: 13.sp)))),
          DataCell(SizedBox(
              width: 80.w,
              child: Text(items[index].shopItemType, style: GoogleFonts.inter(fontSize: 13.sp)))),
          DataCell(Text(items[index].price + '.00', style: GoogleFonts.inter(fontSize: 13.sp))),
          DataCell(Row(
            children: [
              GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance.collection('EditItem').doc((_auth.currentUser)!.uid)
                      .collection('StoreItem1').doc((_auth.currentUser)!.uid).set({
                    'uid': items[index].uid,
                    'refId': items[index].refId,
                    'shopName': items[index].shopName,
                    'shopItemName': items[index].shopItemName,
                    'shopItemType': items[index].shopItemType,
                    'shopItem': items[index].shopItem,
                    'price': items[index].price,
                    'description': items[index].description,
                    'discount': items[index].discount,
                    'startDate': items[index].startDate,
                    'endDate': items[index].endDate,
                    'discount2': items[index].discount2,
                    'startDate2': items[index].startDate2,
                    'endDate2': items[index].endDate2,
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShopItem()));
                },
                child: Container(
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Text(
                        "Edit",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                    )),
              ),
              SizedBox(width: 2.w,),
              (items[index].status == 'unblock')
                  ? GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            padding: EdgeInsets.only(left: 20.w, top: 20.h, right: 20.w),
                            width: 300.w,
                            height: 100.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('www.oiewheel.com says?', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                                Text('Do you wish to block it?', style: GoogleFonts.inter(fontSize: 13.sp)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        FirebaseFirestore.instance.collection('StoreItem2').doc(items[index].refId).update({
                                          'status' : 'block',
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                          height: 25.h,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF1976D2),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              "Ok",
                                              style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 13.sp
                                              ),
                                            ),
                                          )),
                                    ),
                                    SizedBox(width: 3.w),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                          height: 25.h,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0xFFBDBDBD),
                                              ),
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.inter(
                                                  color: Color(0xFF1976D2),
                                                  fontSize: 13.sp
                                              ),
                                            ),
                                          )),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  );
                },
                child: Container(
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Block",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                    )),
              )
                  : GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            padding: EdgeInsets.only(left: 20.w, top: 20.h, right: 20.w),
                            width: 300.w,
                            height: 100.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('www.oiewheel.com says?', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                                Text('Do you wish to unblock it?', style: GoogleFonts.inter(fontSize: 13.sp)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        FirebaseFirestore.instance.collection('StoreItem2').doc(items[index].refId).update({
                                          'status' : 'unblock',
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                          height: 25.h,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF1976D2),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              "Ok",
                                              style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 13.sp
                                              ),
                                            ),
                                          )),
                                    ),
                                    SizedBox(width: 3.w,),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                          height: 25.h,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0xFFBDBDBD),
                                              ),
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.inter(
                                                  color: Color(0xFF1976D2),
                                                  fontSize: 13.sp
                                              ),
                                            ),
                                          )),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  );
                },
                child: Container(
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Unblock",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                    )),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            padding: EdgeInsets.only(left: 20.w, top: 20.h, right: 20.w),
                            width: 300.w,
                            height: 100.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('www.oiewheel.com says?', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                                Text('Do you wish to delete it?', style: GoogleFonts.inter(fontSize: 13.sp)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        FirebaseFirestore.instance.collection('StoreItem2').doc(items[index].refId).delete();
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                          height: 25.h,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF1976D2),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              "Ok",
                                              style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 13.sp
                                              ),
                                            ),
                                          )),
                                    ),
                                    SizedBox(width: 3.w,),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                          height: 25.h,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0xFFBDBDBD),
                                              ),
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.inter(
                                                  color: Color(0xFF1976D2),
                                                  fontSize: 13.sp
                                              ),
                                            ),
                                          )),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  );
                },
                child: Container(
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                    )),
              ),
            ],
          )),
        ], index: index);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => 0;
}

class ShopItem{
  final String shopName;
  final String shopItemName;
  final String shopItemType;
  final String shopItem;
  final String price;
  final String description;
  final String discount;
  final String startDate;
  final String endDate;
  final String discount2;
  final String startDate2;
  final String endDate2;
  final String refId;
  final String uid;
  final String status;
  DocumentReference ? reference;

  ShopItem.fromMap(Map<dynamic, dynamic> map, {this.reference})
      : assert(map['shopName'] != null),
        assert(map['shopItemName'] != null),
        assert(map['shopItemType'] != null),
        assert(map['shopItem'] != null),
        assert(map['price'] != null),
        assert(map['description'] != null),
        assert(map['discount'] != null),
        assert(map['startDate'] != null),
        assert(map['endDate'] != null),
        assert(map['discount2'] != null),
        assert(map['startDate2'] != null),
        assert(map['endDate2'] != null),
        assert(map['refId'] != null),
        assert(map['uid'] != null),
        assert(map['status'] != null),
        shopName = map['shopName'],
        shopItemName = map['shopItemName'],
        shopItemType = map['shopItemType'],
        shopItem = map['shopItem'],
        price = map['price'],
        description = map['description'],
        discount = map['discount'],
        startDate = map['startDate'],
        endDate = map['endDate'],
        discount2 = map['discount2'],
        startDate2 = map['startDate2'],
        endDate2 = map['endDate2'],
        status = map['status'],
        refId = map['refId'],
        uid = map['uid'];


  ShopItem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<dynamic, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "Users<$shopName:$shopItemName:$shopItemType:$shopItem:$price:$description:"
      "$discount:$startDate:$endDate:$discount2:$startDate2:$endDate2:$refId:$uid:$status>";
}


