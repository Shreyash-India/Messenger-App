import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger/helper/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/home.dart';
import 'database.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    // ignore: await_only_futures
    return await auth.currentUser;
  }

  // signInWithGoogle
  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential userCredential =
        await firebaseAuth.signInWithCredential(credential);

    User? userDetails = userCredential.user;

    if (userDetails != null) {
      SharedPreferencesHelper().saveUserEmail(userDetails.email);
      SharedPreferencesHelper().saveUserId(userDetails.uid);
      SharedPreferencesHelper()
          .saveUserName(userDetails.email!.replaceAll("@gmail.com", ""));
      SharedPreferencesHelper().saveDisplayName(userDetails.displayName);
      SharedPreferencesHelper().saveUserProfileUrl(userDetails.photoURL);
    }

    // Update Firebase Databse with the provided SignIn vredentials by Google-SigIn..
    Map<String, dynamic> userInfo = {
      "userId": userDetails!.uid,
      "email": userDetails.email,
      "userName": userDetails.email!.replaceAll("@gmail.com", ""),
      "name": userDetails.displayName,
      "userProfile": userDetails.photoURL,
    };

    DatabaseMethods().addUserInfoToDB(userDetails.uid, userInfo).then((value) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    });
  }

  // signOutWithGoogle
  Future signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    await auth.signOut();
  }
}
