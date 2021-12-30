// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("दो लफ्ज़"),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/app_logo.png"),
                      fit: BoxFit.fill),
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "कुछ  ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color.fromARGB(255, 241, 33, 33)),
                  ),
                  Text(
                    "बातें  ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 236, 221, 9)),
                  ),
                  Text(
                    "हो  ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color.fromARGB(255, 241, 33, 33)),
                  ),
                  Text(
                    "जाए ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 245, 241, 29)),
                  ),
                ],
              ),
              SizedBox(height: 100),
              GestureDetector(
                onTap: () {
                  Auth().signInWithGoogle(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color.fromARGB(255, 111, 161, 248),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: const Text(
                    "Sign In with Google",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
