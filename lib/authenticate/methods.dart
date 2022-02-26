import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oie_wheels/authenticate/login.dart';

Future<User?> createAccount(String firstname, String lastname, String email, String password, String confirmPassword, String phone, String location, double lat, double lon) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    UserCredential userCrendetial = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    print("Account created Succesfull");

    userCrendetial.user!.updateDisplayName(firstname + lastname);

    await _firestore.collection('Users').doc(_auth.currentUser!.uid).set({
      "firstName": firstname,
      "lastName": lastname,
      "email": email,
      "phone": phone,
      "deliveryAddress": location,
      "password": password,
      "confirmPassword": confirmPassword,
      "lat": lat,
      "lon": lon,
      "imageUrl": "https://i1.wp.com/www.baytekent.com/wp-content/uploads/2016/12/facebook-default-no-profile-pic1.jpg?resize=300%2C300&ssl=1",
      "role": "users",
      "searchKey": firstname[0],
      "uid": _auth.currentUser!.uid,
      "dateTime": DateTime.now(),
    });

    await _firestore.collection('AllUsers').doc(_auth.currentUser!.uid).set({
      "role": "users",
    });

    return userCrendetial.user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logIn(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    return userCredential.user;
  } catch (e) {
    Fluttertoast.showToast(
        msg: e.toString(),
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    return null;
  }
}


Future logOut(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    await _auth.signOut().then((value) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
      print('Log Out');
    });
  } catch (e) {
    print("error");
  }
}