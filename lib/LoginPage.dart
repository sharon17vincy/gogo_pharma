import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/HomePage.dart';
import 'package:gogo_pharma/SignupPage.dart';
import 'package:gogo_pharma/Theme.dart';
import 'package:gogo_pharma/Widgets/SolidButton.dart';
import 'package:gogo_pharma/mixins/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoadingStateMixin  {
  TextEditingController emailcontroller =  TextEditingController();
  TextEditingController passwordcontroller =  TextEditingController();
  TextEditingController otpcontroller =  TextEditingController();
  bool emailenabled = true, passwordenabled = true, isSignin = true;
  final GoGoPharma goPharma = GoGoPharma.getInstance();
  var _passwordVisible = false;

  void showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white,),
      ),
      backgroundColor: Colors.orange,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: appTheme.accentColor,
        disabledTextColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }



  Future<bool> login() async {
    setLoading(true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailcontroller.text.trim(),
          password: passwordcontroller.text.trim()
      );
      print("LOgIN $credential");
      if(credential != null){
        SharedPreferences preferences = await SharedPreferences.getInstance();

        preferences.setString('user', credential.user.toString());
        goPharma.user.image = credential.user!.photoURL ?? "";
        goPharma.user.name = credential.user!.displayName  ?? "";
        goPharma.user.email = credential.user!.email!;

        setLoading(false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(title: "Home")));
      }
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        showSnackBar("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showSnackBar("Wrong password provided for that user.");
      }
      else{
        showSnackBar("Login Failed. Try again!");
      }
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: height/1.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height*.05,),
                  Image.asset("assets/images/logo.png", height: 100,width: MediaQuery.of(context).size.width/2,),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text('Welcome' + "\n" + "Back",
                        textAlign: TextAlign.start,
                        style: titleStyle.copyWith(color: Colors.white, fontSize: 30)),
                  ),
                  SizedBox(height: height*.05,),
                  Container(
                    height: height * 0.06,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: emailcontroller,
                      enabled: emailenabled ? true : false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(width: 1, color: Colors.transparent),
                        ),
                        contentPadding:
                        EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Email",
                        //    prefixIcon: Icon(Icons.person,color: colorblue,),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.010),
                  Container(
                    height: height * 0.06,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      obscureText: !_passwordVisible,
                      controller: passwordcontroller,
                      enabled: passwordenabled ? true : false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Colors.white30,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(width: 1, color: Colors.transparent),
                        ),
                        suffixIcon: IconButton(
                            onPressed: (){
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            )),
                        contentPadding:
                        EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Password",
                        //     prefixIcon: Icon(Icons.lock,color: colorblue,),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  GestureDetector(
                      onTap: (){
                        if (emailcontroller.text
                            .toString()
                            .isEmpty) {
                          showSnackBar("Email cannot be blank.");
                        } else {
                          if (passwordcontroller.text
                              .toString()
                              .isEmpty) {
                            showSnackBar("Password cannot be blank.");
                          } else {
                            login();
                          }
                        }
                      },
                      child: SolidButton(title : "LOGIN", loading: loading, width: double.infinity, solid: true,onTap: (){},)),
                  SizedBox(height: height * 0.03),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text('Forgot password?',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0,
                            color: appTheme.primaryColor)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupPage(title: "Signup Page")));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                height: height * 0.06,
                child:  Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:'New User? ',
                        style: normalStyle.copyWith(color: Colors.white),
                      ),
                      TextSpan(
                        text:'SIGN UP ',
                        style: normalStyle.copyWith(fontWeight: FontWeight.bold, color: appTheme.primaryColor, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}