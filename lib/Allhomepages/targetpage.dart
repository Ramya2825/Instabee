import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia_project/widgets/button_widget.dart';

class Targetpage extends StatefulWidget {
  const Targetpage({super.key, required this.uid, required this.currentUserId});

  final String uid;
  final String currentUserId;

  @override
  State<Targetpage> createState() => _TargetpageState();
}

class _TargetpageState extends State<Targetpage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> followUser() async {
    String myId = widget.currentUserId;
    String targetUid = widget.uid;
    if (myId == targetUid) return;
    var myFollowing = _firestore
        .collection('users')
        .doc(myId)
        .collection('following')
        .doc(targetUid);
    var otherFollowers = _firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(myId);
    var followingSnapshot = await myFollowing.get();
    if (followingSnapshot.exists) {
      await myFollowing.delete();
      await otherFollowers.delete();
      await _firestore.collection('users').doc(myId).update({
        'followingCount': FieldValue.increment(-1),
      });

      await _firestore.collection('users').doc(targetUid).update({
        'followersCount': FieldValue.increment(-1),
      });
    } else {
      await myFollowing.set({'uid': targetUid});

      await otherFollowers.set({'uid': myId});

      await _firestore.collection('users').doc(myId).update({
        'followingCount': FieldValue.increment(1),
      });

      await _firestore.collection('users').doc(targetUid).update({
        'followersCount': FieldValue.increment(1),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('users').doc(widget.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }
          final user = userSnapshot.data!.data() ?? <String, dynamic>{};

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('users')
                .doc(widget.currentUserId)
                .collection('following')
                .doc(widget.uid)
                .snapshots(),
            builder: (context, followingSnapshot) {
              if (followingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final isFollowing = followingSnapshot.data?.exists ?? false;
              return ListView(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              user['profile_url'] != null &&
                                  user['profile_url'].toString().isNotEmpty
                              ? NetworkImage(user['profile_url'])
                              : null,
                          child:
                              user['profile_url'] == null ||
                                  user['profile_url'].toString().isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(height: 12),
                        Text(
                          '@${user['username'] ?? user['user_name'] ?? ''}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: _firestore
                                  .collection('posts')
                                  .where('uid', isEqualTo: widget.uid)
                                  .snapshots(),
                              builder: (context, postCountSnap) {
                                if (!postCountSnap.hasData) {
                                  return CircularProgressIndicator();
                                }
                                final postCount =
                                    postCountSnap.data!.docs.length;
                                return Column(
                                  children: [
                                    Text(
                                      '${postCount}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('Posts'),
                                  ],
                                );
                              },
                            ),
                            Column(
                              children: [
                                Text(
                                  '${user['followersCount'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Followers'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${user['followingCount'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Following'),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        if (widget.uid != widget.currentUserId)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ButtonWidget(
                                    text: isFollowing ? 'Following' : 'Follow',
                                    onPressed: followUser,
                                  ),
                                ),
                                SizedBox(width: 8),

                                Expanded(
                                  child: ButtonWidget(
                                    text: ("Message"),
                                    onPressed: () {},
                                    backgroundColor: Colors.grey.shade300,
                                    textColor: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 20),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Posts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          child: StreamBuilder(
                            stream: _firestore
                                .collection('posts')
                                .where('uid', isEqualTo: widget.uid)
                                .snapshots(),
                            builder: (context, postSnapshot) {
                              if (postSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!postSnapshot.hasData ||
                                  postSnapshot.data!.docs.isEmpty) {
                                return Center(child: Text('No posts yet'));
                              }
                              var posts = postSnapshot.data!.docs;
                              return GridView.builder(
                                shrinkWrap: true,
                                itemCount: posts.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                    ),
                                itemBuilder: (context, index) {
                                  var post = posts[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(
                                      post['image_url'],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
