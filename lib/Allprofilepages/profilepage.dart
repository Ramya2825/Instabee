import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socialmedia_project/Allprofilepages/qrpage.dart';
import 'package:socialmedia_project/Allprofilepages/drawer.dart';
import 'package:socialmedia_project/Allprofilepages/editpage.dart';
import 'package:socialmedia_project/postpage.dart';
import 'package:socialmedia_project/widgets/button_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget postGrid(List posts) {
    if (posts.isEmpty) {
      return Center(child: Text('No posts yet'));
    }
    return GridView.builder(
      itemCount: posts.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        String imageUrl = posts[index]['image_url'] ?? '';
        return imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Container(color: Colors.grey[300], child: Icon(Icons.image));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('InstaUser', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Postpage(
                    onPublished: () {
                      setState(() {});
                    },
                  ),
                ),
              );
            },
            icon: Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileDrawer(
                    currentUserId: currentUserId,
                    onSavedPosts: () => tabController.animateTo(2),
                    onReshares: () => tabController.animateTo(1),
                  ),
                ),
              );
            },
            icon: Icon(Icons.menu),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: _firestore
                .collection('users')
                .doc(currentUserId)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var user = userSnapshot.data!.data() ?? {};
              String name = user['name'] ?? '';
              String bio = user['bio'] ?? '';
              String profileUrl = user['profile_url'] ?? '';

              int followers = (user['followersCount'] ?? 0);
              int following = (user['followingCount'] ?? 0);

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: profileUrl.isNotEmpty
                              ? NetworkImage(profileUrl)
                              : null,
                          child: profileUrl.isEmpty
                              ? Icon(Icons.person, size: 40)
                              : null,
                        ),

                        SizedBox(width: 25),

                        Expanded(
                          child: StreamBuilder(
                            stream: _firestore
                                .collection('posts')
                                .where('uid', isEqualTo: currentUserId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              int postCount = 0;

                              if (snapshot.hasData) {
                                postCount = snapshot.data!.docs
                                    .where(
                                      (post) =>
                                          post.data()['isReshare'] != true,
                                    )
                                    .length;
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '$postCount',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text('Posts'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '$followers',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text('Followers'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '$following',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text('Following'),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(bio),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: ButtonWidget(
                            text: 'Edit Profile',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(uid: currentUserId),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(width: 8),

                        Expanded(
                          child: ButtonWidget(
                            text: 'Share Profile',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Qrpage(uid: currentUserId),
                                ),
                              );
                            },
                            textColor: Colors.grey.shade700,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 10),
          TabBar(
            controller: tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(
                icon: SvgPicture.asset(
                  'assets/icons/posts.svg',
                  height: 24,
                  width: 24,
                ),
              ),
              Tab(
                icon: SvgPicture.asset(
                  'assets/icons/reshare.svg',
                  height: 24,
                  width: 24,
                ),
              ),
              Tab(
                icon: SvgPicture.asset(
                  'assets/icons/saved.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                StreamBuilder(
                  stream: _firestore
                      .collection('posts')
                      .where('uid', isEqualTo: currentUserId)
                      .snapshots(),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var posts = snapshot.data!.docs.toList();

                    return postGrid(posts);
                  },
                ),
              
StreamBuilder(
  stream: _firestore
      .collection('users')
      .doc(currentUserId)
      .collection('reshared_posts')
      .snapshots(),

  builder: (context, snapshot) {

    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }

    var reshares = snapshot.data!.docs;

    if (reshares.isEmpty) {
      return Center(
        child: Text('No reshared posts yet'),
      );
    }

    return GridView.builder(
      itemCount: reshares.length,

      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),

      itemBuilder: (context, index) {

        String postId =
            reshares[index]['original_post_id'];

        return FutureBuilder(
          future: _firestore
              .collection('posts')
              .doc(postId)
              .get(),

          builder: (context, postSnapshot) {

            if (!postSnapshot.hasData ||
                !postSnapshot.data!.exists) {
              return SizedBox();
            }

            var data = postSnapshot.data!.data()!;

            return Image.network(
              data['image_url'] ?? '',
              fit: BoxFit.cover,
            );
          },
        );
      },
    );
  },
)
,
                StreamBuilder(
                  stream: _firestore
                      .collection('users')
                      .doc(currentUserId)
                      .collection('saved_posts')
                      .snapshots(),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var posts = snapshot.data!.docs;

                    return postGrid(posts);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
