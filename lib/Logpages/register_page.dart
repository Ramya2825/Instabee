import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instabee/instabee.dart';
import 'package:instabee/Logpages/loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailcontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final usernamecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool showPassword = false;

  Future<void> register(
    String email,
    String password,
    String fullName,
    String username,
  ) async {
    if (email.trim().isEmpty ||
        password.isEmpty ||
        fullName.trim().isEmpty ||
        username.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all the fields')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'email': email.trim(),
        'user_name': username.trim(),
        'full_name': fullName.trim(),
        'uid': uid,
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Socialmedia()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    namecontroller.dispose();
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Column(
              children: [
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Join InstaBee and share your moments',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),

                SizedBox(height: 30),

                // REGISTER CARD
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Color(0xff181818),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white12),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EMAIL
                      Text(
                        'Email Address',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 10),

                      TextField(
                        controller: emailcontroller,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.orange,
                          ),
                          filled: true,
                          fillColor: Color(0xff252525),
                          contentPadding: EdgeInsets.symmetric(vertical: 17),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // FULL NAME
                      Text(
                        'Full Name',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 10),

                      TextField(
                        controller: namecontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.orange,
                          ),
                          filled: true,
                          fillColor: Color(0xff252525),
                          contentPadding: EdgeInsets.symmetric(vertical: 17),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // USERNAME
                      Text(
                        'Username',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 10),

                      TextField(
                        controller: usernamecontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Choose a username',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.alternate_email,
                            color: Colors.orange,
                          ),
                          filled: true,
                          fillColor: Color(0xff252525),
                          contentPadding: EdgeInsets.symmetric(vertical: 17),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // PASSWORD
                      Text(
                        'Password',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 10),

                      TextField(
                        controller: passwordcontroller,
                        obscureText: !showPassword,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Create a password',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.orange,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: Color(0xff252525),
                          contentPadding: EdgeInsets.symmetric(vertical: 17),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // SIGN UP BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 53,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  register(
                                    emailcontroller.text,
                                    passwordcontroller.text,
                                    namecontroller.text,
                                    usernamecontroller.text,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            disabledBackgroundColor: Colors.orange.shade200,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.black)
                              : Text(
                                  'CREATE ACCOUNT',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 25),

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),

                      SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Loginpage(),
                                ),
                              );
                            },
                            child: Text(
                              'Log In',
                              style: GoogleFonts.poppins(
                                color: Colors.orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
