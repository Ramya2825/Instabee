import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:socialmedia_project/Allhomepages/homepage.dart';
import 'package:socialmedia_project/postpage.dart';
import 'package:socialmedia_project/Allprofilepages/profilepage.dart';

class Socialmedia extends StatefulWidget {
  const Socialmedia({super.key});

  @override
  State<Socialmedia> createState() => _SocialmediaState();
}

class _SocialmediaState extends State<Socialmedia> {
  int currentIndex = 0;

  final List<Widget> pages = [
    Homepage(),
    Postpage(onPublished: () {}),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(color: Colors.black),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    currentIndex = 0;
                  });
                },
              
            
                  child: SvgPicture.asset(
                    'assets/icons/home.svg',
                    height: 99,
                    width:99,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      currentIndex == 0 ? Colors.orange : Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/post.svg',
                    height: 70,
                    width: 70,
                    colorFilter: ColorFilter.mode(
                      currentIndex == 1 ? Colors.orange : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    currentIndex = 2;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),

                      builder: (context, snapshot) {
                        String? imageUrl;

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          imageUrl = data['profile_url'];
                        }

                        return Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: currentIndex == 2
                                  ? Colors.orange
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade700,
                            backgroundImage:
                                imageUrl != null && imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null || imageUrl.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
