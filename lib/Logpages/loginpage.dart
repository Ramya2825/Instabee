import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instabee/instabee.dart';
import 'package:instabee/Logpages/register_page.dart';
class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}
class _LoginpageState extends State<Loginpage> {
  final namecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool showPassword = false;

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Socialmedia()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login failed'),
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

  Future<void> forgotPassword() async {
    String email = namecontroller.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to your email!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    namecontroller.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 45),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Insta',
                          style: GoogleFonts.orbitron(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Bee',
                          style: GoogleFonts.orbitron(
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            color: Colors.orange,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 25),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Connect with friends & share your moments',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),

                SizedBox(height: 28),

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

                      SizedBox(height: 9),

                      TextField(
                        controller: namecontroller,
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

                      SizedBox(height: 18),

                      // PASSWORD
                      Text(
                        'Password',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 9),

                      TextField(
                        controller: passwordcontroller,
                        obscureText: !showPassword,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
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

                      // FORGOT PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: forgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 53,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  login(
                                    namecontroller.text,
                                    passwordcontroller.text,
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
                                  'LOGIN',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 22),

                      // OR DIVIDER
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

                      SizedBox(height: 20),

                      // FACEBOOK
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.facebook, color: Colors.blue, size: 27),
                            SizedBox(width: 10),
                            Text(
                              'Log in with Facebook',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22),

                // REGISTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
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
        ),
      ),
    );
  }
}
