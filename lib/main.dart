import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lostitems/SignUpScreen.dart';
import 'package:lostitems/landingpage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log initialized Firebase apps
  print('Existing Firebase apps: ${Firebase.apps.map((app) => app.name).toList()}');

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCfyRl5jQOrLzuRY_PQrkl01wLxAbptrAw",
        projectId: "jeff-c8ca2",
        messagingSenderId: "309391763854",
        appId: "1:309391763854:android:d6f7e8a567e670844ddcdf",

      ),
    );
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );

  }
}


