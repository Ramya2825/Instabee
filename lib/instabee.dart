import 'package:flutter/material.dart';
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

  final List<Widget> pages = [Homepage(),Postpage(
      onPublished: () {},
    ), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
           
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Post'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],

        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
