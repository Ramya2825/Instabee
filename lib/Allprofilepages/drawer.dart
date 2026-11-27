import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instabee/Allprofilepages/editpage.dart';
import 'package:instabee/Allprofilepages/qrpage.dart';
import 'package:instabee/Logpages/loginpage.dart';

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
            openSettings(context);
               }),
               ListTile(leading: Icon(Icons.help),
               title: Text("Help & Support"),
               onTap: (){
              openHelp(context);
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
void openSettings(BuildContext context) {
  Navigator.pop(context);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Settings & Privacy',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'ACCOUNT PRIVACY',
                style: TextStyle(color: Colors.orange),
              ),
            ),

            SwitchListTile(
              secondary: Icon(Icons.lock_outline, color: Colors.orange),
              title: Text('Private Account',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Manage who can see your posts',
                style: TextStyle(color: Colors.grey),
              ),
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Privacy setting coming soon')),
                );
              },
            ),

            Divider(color: Colors.white12),

            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'PREFERENCES',
                style: TextStyle(color: Colors.orange),
              ),
            ),

            ListTile(
              leading: Icon(Icons.notifications_none, color: Colors.orange),
              title: Text('Notifications',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Manage your notifications',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.visibility_outlined, color: Colors.orange),
              title: Text('Activity Status',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Manage your activity visibility',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
              onTap: () {},
            ),

            Divider(color: Colors.white12),

            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'SECURITY',
                style: TextStyle(color: Colors.orange),
              ),
            ),

            ListTile(
              leading: Icon(Icons.lock_reset, color: Colors.orange),
              title: Text('Change Password',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Reset your account password',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
              onTap: () async {
                String? email =
                    FirebaseAuth.instance.currentUser?.email;

                if (email == null) return;

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset link sent to $email'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unable to send reset email'),
                    ),
                  );
                }
              },
            ),

            Divider(color: Colors.white12),

            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.orange),
              title: Text('About InstaBee',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Connect. Share. Engage.',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'InstaBee',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Connect. Share. Engage.',
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
void openHelp(BuildContext context) {
  Navigator.pop(context);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Help & Support',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          children: [
            SizedBox(height: 25),

            Center(
              child: Icon(
                Icons.support_agent,
                color: Colors.orange,
                size: 65,
              ),
            ),

            SizedBox(height: 12),

            Center(
              child: Text(
                'How can we help you?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 25),

            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'SUPPORT',
                style: TextStyle(color: Colors.orange),
              ),
            ),

            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.orange),
              title: Text('Help Center',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Learn how to use InstaBee',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                showHelpDialog(
                  context,
                  'Help Center',
                  'InstaBee allows you to create posts, like posts, comment, follow users and share moments.',
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.report_problem_outlined,
                  color: Colors.orange),
              title: Text('Report a Problem',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Report technical issues',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                showHelpDialog(
                  context,
                  'Report a Problem',
                  'Report login issues, upload problems or any technical errors.',
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.flag_outlined, color: Colors.orange),
              title: Text('Report a User',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Report inappropriate accounts',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                showHelpDialog(
                  context,
                  'Report a User',
                  'Report accounts that share inappropriate content or behave in an abusive manner.',
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.shield_outlined, color: Colors.orange),
              title: Text('Privacy & Safety',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Keep your account safe',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                showHelpDialog(
                  context,
                  'Privacy & Safety',
                  'Use a strong password and never share your login details with anyone.',
                );
              },
            ),

            Divider(color: Colors.white12),

            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'FEEDBACK',
                style: TextStyle(color: Colors.orange),
              ),
            ),

            ListTile(
              leading: Icon(Icons.feedback_outlined,
                  color: Colors.orange),
              title: Text('App Feedback',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Share your suggestions',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                showHelpDialog(
                  context,
                  'App Feedback',
                  'Thank you for helping us improve InstaBee!',
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.email_outlined, color: Colors.orange),
              title: Text('Contact Us',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Get in touch with support',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                showHelpDialog(
                  context,
                  'Contact Us',
                  'Contact details will be available soon.',
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void showHelpDialog(
    BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Color(0xff181818),
      title: Text(title, style: TextStyle(color: Colors.orange)),
      content: Text(message, style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(color: Colors.orange)),
        ),
      ],
    ),
  );
}