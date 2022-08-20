import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/SplashScreen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  runApp(MyApp());
}

class MyApp extends StatefulWidget
{
@override
State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final GoGoPharma goPharma = GoGoPharma.getInstance();

  void initState() {
    super.initState();
    getData();

  }

  getData() async {

    var user = FirebaseAuth.instance.currentUser;

    print(user);


    setState(() {
      if(user != null)
      {
        goPharma.user.image = user.photoURL ?? "";
        goPharma.user.name = user.displayName  ?? "";
        goPharma.user.email = user.email ?? "";

      }

    });

  }

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
        title: 'GoGo Pharma',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
    );
  }
}