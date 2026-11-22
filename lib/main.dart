import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia_project/firebase_options.dart';
import 'package:socialmedia_project/instabee.dart';
import 'package:socialmedia_project/Logpages/loginpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: checkAuth(),
    );
  }

  Widget checkAuth() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return  Socialmedia();
    }
    return Loginpage();
  }
}
