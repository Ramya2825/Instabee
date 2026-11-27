import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instabee/Logpages/loginpage.dart';
import 'package:instabee/instabee.dart';
import 'package:instabee/services/biometric_service.dart';
import 'package:vonto_biometric/vonto_biometric.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final auth = FirebaseAuth.instance;
  final biometric_service = BiometricService();

  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(controller);
    scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );
    controller.forward();
    checkAvailability();
  }

  Future<void> checkAvailability() async {
    final available = await biometric_service.checkBiometric();
    final ready = await biometric_service.authenticate();
    if (ready) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Socialmedia()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Loginpage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error issue')));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Image.asset(
              'assets/icons/logo.png',
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
