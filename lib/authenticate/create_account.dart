import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:oie_wheels/authenticate/methods.dart';
import 'package:validators/validators.dart';

const kGoogleApiKey = 'AIzaSyAroZNzwV9wOTEmpREoKmkw-XpYTGZN_Xc';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  MobileVerificationState currentState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmpassword = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final otpController = TextEditingController();
  final _formKey= GlobalKey<FormState>();
  double lat = 0.0;
  double lon = 0.0;

  bool isLoading = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String verificationId;
  bool showLoading = false;
  bool _seepassword = true;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
      await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if(authCredential?.user != null){
        Navigator.of(context).pushReplacementNamed('/login');
        FirebaseAuth.instance.currentUser?.delete();
        await FirebaseAuth.instance.signOut();
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });

      _scaffoldKey.currentState
          ?.showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }


  getOtpFormWidget(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: otpController,
          decoration: InputDecoration(
            hintText: "Enter OTP",
          ),
        ),
        SizedBox(
          height: 16,
        ),
        FlatButton(
          onPressed: () async {
            PhoneAuthCredential phoneAuthCredential =
            PhoneAuthProvider.credential(
                verificationId: verificationId, smsCode: otpController.text);

            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          child: Text("VERIFY"),
          color: Colors.amber[700],
          textColor: Colors.white,
        ),
        Spacer(),
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();


  Future<bool?>showWarning(BuildContext context)async {
    await FirebaseFirestore.instance.collection('Users').doc((_auth.currentUser)!.uid).delete();
    await FirebaseAuth.instance.currentUser?.delete();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'Unknown error'),
      ),
    );
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
            icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white, size: 20.sp,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Customer Registration', style: GoogleFonts.inter(
              fontSize: 15.sp, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottomOpacity: 0.0,
          elevation: 0.0,
          backgroundColor: Color(0xFF1976D2),
        ),
      ),
      body: isLoading
          ? Center(
        child: Container(
          height: size.height / 20,
          width: size.height / 20,
          child: CircularProgressIndicator(),
        ),
      )
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 10.h),
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
                      controller: _firstname,
                      decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          icon: Icon(Icons.person_outline, color: Colors.amber[700], size: 20.sp,),
                          labelText: 'First Name',
                          labelStyle: GoogleFonts.inter(fontSize: 13.sp)
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
              SizedBox(height: 8.h),
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
                      controller: _lastname,
                      decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          icon: Icon(Icons.person_outline, color: Colors.amber[700], size: 20.sp,),
                          labelText: 'Last Name',
                          labelStyle: GoogleFonts.inter(fontSize: 13.sp)
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
              SizedBox(height: 8.h,),
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
                        controller: _email,
                        decoration: InputDecoration(
                            floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            icon: Icon(Icons.mail_outline, color: Colors.amber[700], size: 20.sp),
                            labelText: 'Email',
                            labelStyle: GoogleFonts.inter(fontSize: 13.sp)
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
              SizedBox(height: 8.h),
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
                              child: Icon(CupertinoIcons.clear)),
                          icon: Icon(Icons.lock_outlined, color: Colors.amber[700], size: 20.sp),
                          labelText: 'Password',
                          labelStyle: GoogleFonts.inter(fontSize: 13.sp)
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
              SizedBox(height: 8.h),
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
                      controller: _confirmpassword,
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
                              child: Icon(CupertinoIcons.clear)),
                          icon: Icon(Icons.lock_outline, color: Colors.amber[700], size: 20.sp,),
                          labelText: 'Confirm Password',
                          labelStyle: GoogleFonts.inter(fontSize: 13.sp)
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
              SizedBox(height: 8.h),
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
                      controller: _phone,
                      decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          icon: Icon(Icons.phone_outlined, color: Colors.amber[700], size: 20.sp),
                          prefixText: "+975",
                          labelText: 'Phone Number',
                          labelStyle: GoogleFonts.inter(fontSize: 13.sp)
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
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
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Container(
                  height: size.height / 14,
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
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      style: GoogleFonts.inter(fontSize: 13.sp),
                      controller: _location,
                      onTap: () async{
                        var place = await PlacesAutocomplete.show(
                          context: context,
                          apiKey: kGoogleApiKey,
                          onError: onError,
                          mode: Mode.overlay,
                          language: 'en',
                          components: [Component(Component.country, 'bt')],
                        );
                        if(place != null){
                          final plist = GoogleMapsPlaces(apiKey:kGoogleApiKey, apiHeaders: await const GoogleApiHeaders().getHeaders(),);
                          String placeid = place.placeId ?? "0";
                          final detail = await plist.getDetailsByPlaceId(placeid);
                          final geometry = detail.result.geometry!;

                          setState(() {
                            _location.text = place.description.toString();
                            lat = geometry.location.lat;
                            lon = geometry.location.lng;
                          });
                        }
                      },
                      decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.amber[700]),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.amber[700],size: 20.sp,),
                          labelText: 'Delivery Address',
                          labelStyle: GoogleFonts.inter(fontSize: 13.sp)
                      ),
                      validator: (String ? value) {
                        if(value!.isEmpty) {
                          return 'Please enter delivery address';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {

                    _formKey.currentState!.save();

                    createAccount(_firstname.text, _lastname.text, _email.text, _password.text, _confirmpassword.text, _phone.text, _location.text, lat, lon).then((user) {
                      if (user != null) {
                        setState(() {
                          isLoading = false;
                        });

                        _auth.verifyPhoneNumber(
                          phoneNumber: '+975'+ _phone.text,
                          verificationCompleted: (phoneAuthCredential) async {
                            setState(() {
                              showLoading = false;
                            });
                          },
                          verificationFailed: (verificationFailed) async {
                            setState(() {
                              showLoading = false;
                            });
                          },

                          codeSent: (verificationId, resendingToken) async {
                            setState(() {
                              showLoading = false;
                              currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                              this.verificationId = verificationId;
                            });
                          },
                          codeAutoRetrievalTimeout: (verificationId) async {},
                        );

                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return WillPopScope(
                                onWillPop: () async{
                                  print('Back Button pressed');

                                  final shouldPop = await showWarning(context);
                                  return shouldPop ?? false;
                                },
                                child: Dialog(
                                    child: Container(
                                        width: 50,
                                        height: 250,
                                        key: _scaffoldKey,
                                        child: Container(
                                          child: showLoading
                                              ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                              : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                                              ? getOtpFormWidget(context)
                                              : null,
                                          padding: const EdgeInsets.all(16),
                                        )
                                    )
                                ),
                              );
                            });
                        // Navigator.push(
                        //     context, MaterialPageRoute(builder: (_) => LoginScreen()));
                        print("Account Created Sucessfull");
                      } else {
                        print("Login Failed");
                        setState(() {
                          isLoading = false;
                        });
                      }
                    });
                  } else {
                    print("Please enter Fields");
                  }
                  //phone verification
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
                      "REGISTER",
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
    );
  }

}
