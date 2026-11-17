import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia_project/Allprofilepages/editpage.dart';
import 'package:socialmedia_project/Allprofilepages/qrpage.dart';
import 'package:socialmedia_project/Logpages/loginpage.dart';

class ProfileDrawer extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onSavedPosts;
  final VoidCallback onReshares;

  ProfileDrawer({
    super.key,
    required this.currentUserId,
    required this.onSavedPosts,
    required this.onReshares,
  });

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder(
        stream: firestore
            .collection('users')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return  Center(
              child: CircularProgressIndicator(),
            );
          }
        var user = snapshot.data!.data() ?? {};
          String name = user['name'] ?? '';
          String username =
              user['username'] ?? user['user_name'] ?? '';
          String profileUrl = user['profile_url'] ?? '';
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration:  BoxDecoration(
                  color: Colors.black,
                ),
                accountName: Text(name),
                accountEmail: Text(
                  username.isNotEmpty ? '@$username' : '',
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                  child: profileUrl.isEmpty ?  Icon(Icons.person) : null,
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 16,top: 10),
              child: Text("ACCOUNT",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,),),),
              ListTile(
                leading:  Icon(Icons.person_outline),
                title:  Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfilePage(uid: currentUserId),
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Icon(Icons.qr_code),
                title:  Text('Share Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Qrpage(uid: currentUserId),
                    ),
                  );
                },
              ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 10),
          child: Text(
            'YOUR ACTIVITY',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

              ListTile(
                leading:  Icon(Icons.bookmark_border),
                title:  Text('Saved Posts'),
                onTap: () {
                  Navigator.pop(context);
                  onSavedPosts();
                },
              ),

              ListTile(
                leading:  Icon(Icons.repeat),
                title:  Text('Your Reshares'),
                onTap: () {
                  Navigator.pop(context);
                  onReshares();
                },
              ),
               Divider(),
                 Padding(
          padding: EdgeInsets.only(left: 16, top: 10),
          child: Text(
            'SETTINGS',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
               ListTile(leading: Icon(Icons.settings),
               title: Text("Settings & Privacy"),
               onTap: (){
              Navigator.pop(context);
               }),
               ListTile(leading: Icon(Icons.help),
               title: Text("Help & Support"),
               onTap: (){
                Navigator.pop(context);
               },
               ),
           
              ListTile(
                leading:  Icon(Icons.info_outline),
                title:  Text('About InstaBee'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'InstaBee',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Connect. Share. Engage.'
                  );
                },
              ),
Divider(),
              ListTile(
                leading:  Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title:  Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.signOut();
                 
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  Loginpage(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
