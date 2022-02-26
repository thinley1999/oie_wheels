import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oie_wheels/pages/home.dart';
import 'package:validators/validators.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async{
    return (_auth.currentUser)!.uid;
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("ShopOwner").doc((_auth.currentUser)!.uid).get().then((value){
      print(value.data()!["firstName"]);
      _firstname.text = value.data()!["firstName"];
      _lastname.text = value.data()!["lastName"];
      _email.text = value.data()!["email"];
      _password.text = value.data()!["password"];
      _confirmpassword.text = value.data()!["confirmPassword"];
      _phone.text = value.data()!["phone"];
    });
  }

  var _firstname = TextEditingController();
  var _lastname = TextEditingController();
  var  _email = TextEditingController();
  var _password = TextEditingController();
  var  _confirmpassword = TextEditingController();
  var  _phone = TextEditingController();
  var newPassword = "";
  final _scrollController = ScrollController();
  final _formKey= GlobalKey<FormState>();

  bool _seepassword = true;
  bool isLoading = false;
  File ? _selectedFile;

  //for selecting and uploading image
  getImage(ImageSource source) async {
    this.setState((){
      isLoading = true;
    });
    XFile? image = await ImagePicker().pickImage(source: source);
    if(image != null){
      File? cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(
              ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Color(0xFF01579B),
            toolbarTitle: "Crop Image",
            toolbarWidgetColor: Colors.white,
            statusBarColor: Color(0xFF01579B),
            backgroundColor: Colors.white,
          )
      );

      this.setState((){
        _selectedFile = cropped;
        isLoading = false;
      });
    } else {
      this.setState((){
        isLoading = false;
      });
    }
  }

  void _uploadImage(){
    String imageFileName = (_auth.currentUser)!.uid;

    final Reference storageReference  = FirebaseStorage.instance.ref().child('Shop Owner').child(imageFileName);

    final UploadTask uploadTask = storageReference.putFile(_selectedFile!);
    uploadTask.then((TaskSnapshot taskSnapshot){
      taskSnapshot.ref.getDownloadURL().then((imageUrl){
        //saving of info to firestore
        _saveData(imageUrl);
      });
    }).catchError((error){
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: error.toString(),
      );
    });
  }

  void _saveData(String imageUrl){
    FirebaseFirestore.instance.collection("ShopOwner").doc((_auth.currentUser)!.uid)
        .update({
      "imageUrl": imageUrl,
    }).then((_) {
      print("success!");
    });
  }

  //fetching firestore data
  Future<DocumentSnapshot> getUserInfo()async{
    return await FirebaseFirestore.instance.collection("ShopOwner").doc((_auth.currentUser)!.uid).get();
  }

  //changing password
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  changePassword() async {
    try {
      await currentUser!.updatePassword(newPassword);
      await currentUser!.updatePassword(newPassword).then((_){
        FirebaseFirestore.instance.collection("ShopOwner").doc((_auth.currentUser)!.uid).update(
            {
              "password" : _password.text,
              "confirmPassword": _confirmpassword.text,
            }).then((_){
          print('Password reset successful');
        });
      }).catchError((error){
        print('error' + error.toString());
      });
    } catch (e) {}
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
            title: Text('Edit Profile', style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottomOpacity: 0.0,
            elevation: 0.0,
            backgroundColor: Color(0xFF1976D2),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 150.h,
                  padding: const EdgeInsets.only(top: 20),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          getImage(ImageSource.camera);
                                        },
                                        icon: Icon(Icons.camera_alt_outlined, size: 30.sp,color: Color(0xFF01579B),)
                                    ),
                                    _selectedFile != null ?
                                    ClipOval(
                                      child: Image.file(
                                        _selectedFile!,
                                        width: 140.sp,
                                        height: 140.sp,
                                      ),
                                    ) :
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        snapshot.data!["imageUrl"],
                                      ),
                                      radius: 70.sp,
                                      backgroundColor: Colors.transparent,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          getImage(ImageSource.gallery);
                                        },
                                        icon: Icon(Icons.image_outlined, size: 28.sp,color: Color(0xFF01579B),)
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
                SizedBox(height: 5.h,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w,),
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
                        controller: _firstname,
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          icon: Icon(Icons.person_outline, color: Colors.amber[700], size: 20.sp,),
                          prefixText: "First Name",
                          prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                        ),
                        validator: (String ? value) {
                          if(value!.isEmpty) {
                            return 'Please enter first name';
                          }
                          if(value.contains(" ")){
                            return 'Please remove space after first name';
                          }
                          if(value != null && value.isNotEmpty && isUppercase(value[0])){
                            return null;
                          }
                          return 'Please enter first letter in capital';
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w,),
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
                        controller: _lastname,
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          icon: Icon(Icons.person_outline, color: Colors.amber[700], size: 20.sp,),
                          prefixText: "Last Name",
                          prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                        ),
                        validator: (String ? value) {
                          if(value!.isEmpty) {
                            return 'Please enter last name';
                          }
                          if(value.contains(" ")){
                            return 'Please remove space after last name';
                          }
                          if(value != null && value.isNotEmpty && isUppercase(value[0])){
                            return null;
                          }
                          return 'Please enter first letter in capital';
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                          controller: _email,
                          decoration: InputDecoration(
                            floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            icon: Icon(Icons.mail_outline, color: Colors.amber[700],size: 20.sp,),
                            prefixText: "Email",
                            prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                          ),
                          validator: (String ? value) {
                            if(value!.isEmpty)
                            {
                              return 'Please enter email';
                            }
                            if(value.contains(" ")){
                              return 'Please remove space after email';
                            }
                            if(!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)){
                              return 'Please a enter valid email';
                            }
                            return null;
                          }
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                        controller: _password,
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          suffixIcon: _seepassword?GestureDetector(onTap: (){ setState(() {
                            _seepassword = false;});},
                              child: Icon(CupertinoIcons.eye_solid, color: Colors.amber[700], size: 20.sp,)):
                          GestureDetector(onTap: (){setState(() {
                            _seepassword = true;
                          });},
                              child: Icon(CupertinoIcons.clear, size: 20.sp,)),
                          icon: Icon(Icons.lock_outlined, color: Colors.amber[700], size: 20.sp,),
                          prefixText: "Password",
                          prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                        ),
                        validator: (input) {
                          if(input!.isEmpty) {
                            return 'Please enter password';
                          }
                          if(input.length < 6) {
                            return 'Password must be at least 6 character long';
                          }
                        },
                        obscureText: _seepassword,
                        // onSaved: (input) => _password = input,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                        controller: _confirmpassword,
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          suffixIcon: _seepassword?GestureDetector(onTap: (){ setState(() {
                            _seepassword = false;});},
                              child: Icon(CupertinoIcons.eye_solid, color: Colors.amber[700],size: 20.sp,)):
                          GestureDetector(onTap: (){setState(() {
                            _seepassword = true;
                          });},
                              child: Icon(CupertinoIcons.clear, size: 20.sp,)),
                          icon: Icon(Icons.lock_outline, color: Colors.amber[700],size: 20.sp,),
                          prefixText: "Confirm Password",
                          prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                        ),
                        validator: (String ? value) {
                          if(value!.isEmpty) {
                            return 'Please enter confirm password';
                          }
                          if (value != _password.value.text) {
                            return 'Passwords do not match!';
                          }
                          else {
                          }
                        },
                        obscureText: _seepassword,
                        // onSaved: (input) => _password = input,
                      ),
                    ),
                  ),
                ),
                isLoading ? Padding(padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.blue[200],
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                    )): SizedBox.shrink(),
                SizedBox(height: 3.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                        controller: _phone,
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          icon: Icon(Icons.phone_outlined, color: Colors.amber[700],size: 20.sp,),
                          prefixText: "Phone",
                          prefixStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (input) {
                          if(input!.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (input.length < 8 ) {
                            return "Phone Number must be at least 8 digit long";
                          }
                          if (input.length > 8) {
                            return "Phone Number must be  8 digit only";
                          }
                          // if(!RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(input)){
                          //   return 'Please enter valid phone number';
                          // }
                          else {
                            return null;
                          }
                        },
                      ),),
                  ),
                ),
                SizedBox(height: 3.h),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 18.w),
                //   child: Container(
                //     height: 45.h,
                //     decoration: BoxDecoration(
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.white,
                //           ),
                //         ],
                //         borderRadius: BorderRadius.circular(5),
                //         border: Border.all(color: Color(0xffBDBDBD))),
                //     child: Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 8.w),
                //       child: TextFormField(
                //         style: GoogleFonts.inter(fontSize: 13.sp),
                //         controller: api.addressController,
                //         decoration: InputDecoration(
                //             floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                //             focusedBorder: InputBorder.none,
                //             enabledBorder: InputBorder.none,
                //             prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.amber[700],size: 20.sp,),
                //             labelText: 'Search & Enter address',
                //             labelStyle: GoogleFonts.inter(fontSize: 13.sp)
                //         ),
                //         // validator: (String ? value) {
                //         //   if(value!.isEmpty) {
                //         //     return 'Please enter delivery address';
                //         //   }
                //         //   return null;
                //         // },
                //         onChanged: api.handleSearch,
                //       ),
                //     ),
                //   ),
                // ),
                // Container(
                //   height: 50.h,
                //   width: 330.w,
                //   color: Colors.blue[100]?.withOpacity(.3),
                //   child: StreamBuilder<List<Place>>(
                //       stream: api.controllerOut,
                //       builder: (context, snapshot) {
                //         if(snapshot.data == null) {
                //           return Center(child: Text('No data address found', style: GoogleFonts.inter(fontSize: 13.sp),));
                //         }
                //         final data = snapshot.data;
                //         return Scrollbar(
                //           controller: _scrollController,
                //           child: SingleChildScrollView(
                //             child: Builder(
                //                 builder: (context) {
                //                   return Column(
                //                     children: List.generate(
                //                         data!.length, (index) {
                //                       final place = data[index];
                //                       return ListTile(
                //                         onTap: () {
                //                           api.addressController.text =
                //                           '${place.street}, ${place.locality}, ${place.country}';
                //                         },
                //                         title: Text('${place.street}, ${place.locality}'),
                //                         subtitle: Text('${place.country}'),
                //                       );
                //                     }),
                //                   );
                //                 }
                //             ),
                //           ),
                //         );
                //       }
                //   ),
                // ) ,
                // SizedBox(height: 10.h,),
                GestureDetector(
                  onTap: () {
                    if(_formKey.currentState!.validate()) {
                      setState(() {
                        newPassword = _password.text;
                      });
                      _formKey.currentState!.save();
                      changePassword();
                      FirebaseFirestore.instance.collection("ShopOwner").doc((_auth.currentUser)!.uid)
                          .update({
                        'firstName': _firstname.text,
                        "lastName": _lastname.text,
                        "email": _email.text,
                        "phone": _phone.text,
                      }).then((_) {
                        Fluttertoast.showToast(
                            msg: 'Update success',
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Update fails',
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                    if(_selectedFile != null) {
                      _uploadImage();
                    } else {
                      print('Nothing to worry Thinley Yoezer');
                    }

                  },
                  child: Container(
                      height: 35.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.amber[700],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "SAVE",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
              ],
            ),
          ),
        )
      // SearchInjector(
      //   child: SafeArea(
      //     child: Consumer<LocationApi>(
      //       builder: (_, api, child) => ,
      //     ),
      //   ),
      // )
    );
  }
}
