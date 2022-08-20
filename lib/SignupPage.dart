import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/HomePage.dart';
import 'package:gogo_pharma/LoginPage.dart';
import 'package:gogo_pharma/Widgets/SolidButton.dart';
import 'package:gogo_pharma/mixins/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with LoadingStateMixin {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  bool emailenabled = true, passwordenabled = true, isSignin = true;
  final GoGoPharma goPharma = GoGoPharma.getInstance();


  var _passwordVisible = false;
  var _confirmVisible = false;


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

  Future<bool> signup() async {
    setLoading(true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );
      var user = FirebaseAuth.instance.currentUser;
      print("USER : $user");
      user!.updateDisplayName(namecontroller.text).then((value) async {
        print("Profile has been changed successfully");
        SharedPreferences preferences = await SharedPreferences.getInstance();

        preferences.setString('user', credential.user.toString());
        goPharma.user.image = credential.user!.photoURL ?? "";
        goPharma.user.name = credential.user!.displayName  ?? "";
        goPharma.user.email = credential.user!.email!;
      }).catchError((e){
        print("There was an error updating profile");
      });

      if(credential != null){
        setLoading(false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(title: "Home")));
      }
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        showSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        showSnackBar('The account already exists for that email.');
      }
      else{
        showSnackBar(e);
      }
    } catch (e) {
      setLoading(false);
      print(e);
      showSnackBar(e);
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
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height*.05,),
                  Image.asset("assets/images/logo.png", height: 100,width: MediaQuery.of(context).size.width/2,),
                  const Text(
                    'or sign up with Email', style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: height* 0.02,),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: height * 0.06,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent),
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(8)),
                          child: TextField(
                            controller: namecontroller,
                            enabled:  true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(width: 1, color: Colors.transparent),
                              ),
                              contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "User Name",
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
                            controller: confirmpasswordcontroller,
                            enabled: true,
                            obscureText: !_confirmVisible,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(width: 1, color: Colors.transparent),
                              ),
                              suffixIcon: IconButton(
                                  onPressed: (){
                                    setState(() {
                                      _confirmVisible = !_confirmVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _confirmVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black,
                                  )),
                              contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Confirm Password",
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Container(
                          height: height * 0.06,
                          width: width,
                          child:
                          GestureDetector(
                              onTap: (){
                                if(namecontroller.text.isEmpty || passwordcontroller.text.isEmpty || confirmpasswordcontroller.text.isEmpty
                                 || emailcontroller.text.isEmpty)
                                  {
                                    showSnackBar("Please enter all feilds");
                                  }
                                else
                                {
                                  signup();
                                }
                              },
                              child: SolidButton(title : "CONTINUE", loading: loading, width: double.infinity, solid: true,onTap: (){},)),
                        ),
                        SizedBox(height: height * 0.03),
                      ],
                    ),
                  ),
                  SizedBox(height: height* 0.02,),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 30.0, right: 30),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'By signing up, you agree to our ',style: TextStyle(color: Colors.grey, fontSize: 16)),
                          TextSpan(
                              text: 'Terms ',
                              style: TextStyle(color: appTheme.primaryColor, fontSize: 16)
                          ),
                          const TextSpan(text: 'and ', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          TextSpan(
                              text: 'Privacy',
                              style: TextStyle(color: appTheme.primaryColor, fontSize: 16)
                          ),
                        ],
                      ),
                    ),
                  )


                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: "Login Page")));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                height: height * 0.06,
                child:  Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:'Already have an account? ',
                        style: normalStyle.copyWith(color: Colors.white),
                      ),
                      TextSpan(
                        text:'LOGIN ',
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
