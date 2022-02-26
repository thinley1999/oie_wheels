import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oie_wheels/authenticate/create_account.dart';
import 'package:oie_wheels/authenticate/methods.dart';
import 'package:oie_wheels/driver/driver_home.dart';
import 'package:oie_wheels/pages/home.dart';
import 'package:oie_wheels/shop/shop_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  verifyUser() async{
    String a = _auth.currentUser!.uid;
    DocumentSnapshot result = await FirebaseFirestore.instance.collection("AllUsers").doc(a).get();
    if(result['role'] == 'driver'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverHome()));
    }
    else if(result['role'] == 'shop owner'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShopHome()));
    }
    else if(result['role'] == 'block') {
      logOut(context);
      Fluttertoast.showToast(
          msg: "Your account has been block.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else if(result['role'] == 'restaurant owner') {
      logOut(context);
      Fluttertoast.showToast(
          msg: "This portal is not for restaurant owner",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  showOverlay(BuildContext context) async{
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Align(
          alignment: Alignment.center,
          child: SpinKitWave(
            size: 30.sp,
            color: Colors.amber[900],
          ),
        ));
    overlayState!.insert(overlayEntry);
    await Future.delayed(Duration(seconds: 1)).then((value) {
      overlayEntry.remove();
      verifyUser();
    });
  }

  bool _isChecked = false;
  bool isLoading = false;
  bool _seepassword = true;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _myKey = GlobalKey<FormState>();

  late DateTime backButtonPressTime;

  @override
  void initState() {
    _loadUserEmailPassword();
    super.initState();
  }
  alert() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
                height: 300.h,
                child: Form(
                  key: _myKey,
                  child: Stack(
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Forgot Password?",
                              style: GoogleFonts.inter(fontSize: 25.sp, color: Colors.black
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text("Enter the email address associated",style: GoogleFonts.inter(fontSize: 14.sp)),
                            Text("with the account", style: GoogleFonts.inter(fontSize: 14.sp)),
                            SizedBox(height: 5.h),
                            Text("We will email you a link to reset", style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black54)),
                            Text(" your password", style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black54)),
                            SizedBox(height: 5.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Padding(
                                padding: EdgeInsets.only(right: 8, left: 8),
                                child: TextFormField(
                                    style: GoogleFonts.inter(fontSize: 14.sp),
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 10.w),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      hintText: 'Email',
                                      hintStyle: GoogleFonts.inter(fontSize: 14.sp),
                                    ),
                                    validator: (String ? value) {
                                      if(value!.isEmpty)
                                      {
                                        return 'Please enter email';
                                      }
                                      return null;
                                    }
                                ),
                              ),
                            ),
                            FlatButton.icon(
                              onPressed: () async{
                                resetPassword();
                              },
                              icon: Icon(Icons.send, color: Colors.white, size: 20.sp,),
                              label: Text('Send',style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp)),
                              color: Color(0xFF1976D2),
                            ),
                          ]
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.clear, size: 25.sp,),
                        ),
                      ),
                    ],
                  ),
                )
            ),
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: DoubleBackToCloseApp(
          snackBar: SnackBar(
            backgroundColor: Color(0xFF1976D2),
            content: Text('Press back again to exit', style: GoogleFonts.inter(color: Colors.white, fontSize: 15.sp), textAlign: TextAlign.center),
          ),
          child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    children: [
                      Container(
                        height: 240.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(85.sp)),
                          color: Color(0xff0d47a1),
                          gradient: LinearGradient(colors: [(Color(0xff0d47a1)), Colors.blue],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 30.h),
                                  child: CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/logo.jpg',
                                    ),
                                    radius: 50.sp,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 18.w, top: 18.h),
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.inter(
                                        fontSize: 18.sp,
                                        color: Colors.white
                                    ),
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 18.w, right: 18.w, top: 55.h),
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        height: 44.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.sp),
                          color: Colors.amber[700],
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 10),
                                blurRadius: 50.sp,
                                color: Color(0xffEEEEEE)
                            ),
                          ],
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: _emailController,
                            style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              icon: Container(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  decoration: BoxDecoration(
                                    border: Border(right: BorderSide(color: Colors.white)),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.only(right: 10.w),
                                      child: Icon(Icons.mail, color: Colors.white, size: 22.sp,)
                                  )
                              ),
                              hintText: "Enter Email",
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.inter(fontSize: 15.sp, color: Colors.white),
                              enabledBorder: InputBorder.none,
                              errorStyle: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white),
                              errorBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            autofillHints: [AutofillHints.username],
                            validator: (String ? value) {
                              if(value!.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 18.w, right: 18.w, top: 15.h),
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        height: 44.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.sp),
                          color: Colors.amber[700],
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 10),
                                blurRadius: 50.sp,
                                color: Color(0xffEEEEEE)
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            suffixIcon: _seepassword?GestureDetector(onTap: (){ setState(() {
                              _seepassword = false;});},
                                child: Icon(CupertinoIcons.eye_solid, color: Colors.white, size: 20.sp,)):
                            GestureDetector(onTap: (){setState(() {
                              _seepassword = true;
                            });},
                                child: Icon(CupertinoIcons.clear, size: 20.sp, color: Colors.white)),
                            icon: Container(
                                padding: EdgeInsets.symmetric(vertical: 5.h),
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(color: Colors.white)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10.w),
                                  child: Icon(Icons.vpn_key, color: Colors.white, size: 22.sp,),
                                )
                            ),
                            hintText: "Enter Password",
                            border: InputBorder.none,
                            hintStyle: GoogleFonts.inter(fontSize: 15.sp, color: Colors.white),
                            enabledBorder: InputBorder.none,
                            errorStyle: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white),
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          autofillHints: [AutofillHints.password],
                          onEditingComplete: () => TextInput.finishAutofillContext(),
                          validator: (String ? value) {
                            if(value!.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          obscureText: _seepassword,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: Transform.scale(
                                    scale: 1.sp,
                                    child: Checkbox(
                                      value: _isChecked,
                                      onChanged: _handleRemember,
                                      activeColor: const Color(0xFF1976D2),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text("REMEMBER ME",
                                    style: GoogleFonts.inter(fontSize: 12.sp)
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => alert(),
                              child: Text("FORGOT PASSWORD?", style: GoogleFonts.inter(fontSize: 12.sp),),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            _formKey.currentState!.save();

                            logIn(_emailController.text, _passwordController.text).then((user) {
                              if (user != null) {
                                print("Login Sucessfull");
                                setState(() {
                                  isLoading = false;
                                });
                                showOverlay(context);
                              } else {
                                print("Login Failed");
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            });
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 18.w, right: 18.w, top: 55.h),
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          height: 44.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [(Color(0xff0d47a1)), Colors.blue],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight
                            ),
                            borderRadius: BorderRadius.circular(50.sp),
                            color: Colors.grey[200],
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 10),
                                  blurRadius: 50.sp,
                                  color: Color(0xffEEEEEE)
                              ),
                            ],
                          ),
                          child: Text(
                            "LOGIN",
                            style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't Have Any Account?  ",
                                style: GoogleFonts.inter(
                                    fontSize: 13.sp)),
                            GestureDetector(
                              child: Text(
                                "SIGN UP NOW",
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: Colors.amber[700]
                                ),
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount(),)
                                );
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
          ),
        )
    );
  }
  void _handleRemember(bool ? value) {
    print("Handle Rember Me");
    _isChecked = value!;
    SharedPreferences.getInstance().then(
          (prefs) {
        prefs.setBool("remember_me", value);
        prefs.setString('email', _emailController.text);
        prefs.setString('password', _passwordController.text);
      },
    );
    setState(() {
      _isChecked = value;
    });
  }

  void _loadUserEmailPassword() async {
    print("Load Email");
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _email = _prefs.getString("email") ?? "";
      var _password = _prefs.getString("password") ?? "";
      var _remeberMe = _prefs.getBool("remember_me") ?? false;

      if (_remeberMe) {
        setState(() {
          _isChecked = true;
        });
        _emailController.text = _email;
        _passwordController.text = _password;
      }
    } catch (e) {
      print(e);
    }
  }

  resetPassword() async {
    String email = _emailController.text.toString();
    if (_myKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      _myKey.currentState!.save();
      try {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
        Fluttertoast.showToast(
            msg: 'Kindly reset your password using the link sent on your mail',
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
      }
      catch (e) {
        Fluttertoast.showToast(
            msg: e.toString(),
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      }
    }
  }
}