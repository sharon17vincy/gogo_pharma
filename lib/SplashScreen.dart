import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/HomePage.dart';
import 'package:gogo_pharma/LoginPage.dart';
import 'package:gogo_pharma/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<SplashScreen> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  final GoGoPharma goPharma = GoGoPharma.getInstance();
  late AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if(goPharma.user.email == "")
      {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LoginPage(title: "Login")));
      }
      else
      {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage(title: "Home")));
      }
    });
  }


  initScreen(BuildContext context)
  {
    return Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldKey,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", height: 100,width: MediaQuery.of(context).size.width/2,),
              const SizedBox(height: 20,),
              SpinKitThreeBounce(
                color: appTheme.primaryColor,
                size: 20,
              ),
            ],
          ),));
  }

}
