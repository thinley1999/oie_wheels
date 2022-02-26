import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oie_wheels/authenticate/authenticate.dart';
import 'package:oie_wheels/authenticate/create_account.dart';
import 'package:oie_wheels/authenticate/login.dart';
import 'package:oie_wheels/pages/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.black,
  ));
  runApp(
      ScreenUtilInit(
          builder: () => MaterialApp(
            debugShowCheckedModeBanner: false,
    initialRoute: '/auth',
    routes: {
        '/auth':(context) => Authenticate(),
        '/home':(context) => Home(),
        '/login':(context) => Login(),
        'create': (context) => CreateAccount(),
    },
  ),
        designSize: const Size(360, 640),
      ));
}
