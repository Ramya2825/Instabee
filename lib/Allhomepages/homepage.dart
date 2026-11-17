import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socialmedia_project/Allhomepages/targetpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'InstaBee',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var posts = snapshot.data!.docs.where((post) {
            String uid = post.data()['uid'] ?? '';
            return uid.isNotEmpty;
          }).toList();

          if (posts.isEmpty) {
            return Center(child: Text('No posts available'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];

              String image = post.data()['image_url'] ?? '';
              String content = post.data()['content'] ?? '';
              String uid = post.data()['uid'] ?? '';

              return PostCard(
                uid: uid,
                post: post,
                postId: post.id,
                image: image,
                content: content,
                currentUserId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.uid,
    required this.post,
    required this.image,
    required this.content,
    required this.postId,
    required this.currentUserId,
  });

  final String uid;
  final QueryDocumentSnapshot<Map<String, dynamic>> post;
  final String image;
  final String content;
  final String postId;
  final String currentUserId;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController commentController = TextEditingController();
 String get originalPostId {
  var data = widget.post.data();

  if (data['isReshare'] == true) {
    String id = data['original_post_id'] ?? '';

    if (id.isNotEmpty) {
      return id;
    }
  }

  return widget.postId;
}

  Future<void> likePost() async {
    String myId = widget.currentUserId;

    var likeRef = _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .doc(myId);

    try {
      var likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        await likeRef.delete();
      } else {
        await likeRef.set({
          'uid': myId,
          'likedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Like failed')));
    }
  }

  Future<void> resharePost() async {
    String uid = widget.currentUserId;

    var originalRef = _firestore.collection('posts').doc(originalPostId);

    var reshareRef = _firestore
        .collection('posts')
        .doc('${originalPostId}_$uid');

    try {
      var existing = await reshareRef.get();

      if (existing.exists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Already reshared')));
        return;
      }

      var original = await originalRef.get();
      if (!original.exists) return;
      var postData = original.data()!;

      await reshareRef.set({
        'uid': uid,
        // 'image_url': postData['image_url'] ?? '',
        // 'content': postData['content'] ?? '',
        // 'isReshare': true,
        // 'original_post_id': originalPostId,
        // 'original_uid': postData['uid'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await originalRef.update({'reshareCount': FieldValue.increment(1)});
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post reshared successfully')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Reshare failed')));
    }
  }

  Future<void> savePost() async {
    String uid = widget.currentUserId;

    var savedRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('saved_posts')
        .doc(originalPostId);

    try {
      var saved = await savedRef.get();

      if (saved.exists) {
        await savedRef.delete();
      } else {
        await savedRef.set({
          'postId': originalPostId,
          'image_url': widget.image,
          'content': widget.content,
          'savedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed')));
    }
  }

  Future<void> commentPost() async {
    String comment = commentController.text.trim();

    if (comment.isEmpty) {
      return;
    }

    try {
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
            'uid': widget.currentUserId,
            'comment': comment,
            'createdAt': FieldValue.serverTimestamp(),
          });

      commentController.clear();

      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Comment failed')));
    }
  }

  void showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(bottomContext).size.height * 0.65,
            child: Column(
              children: [
                SizedBox(height: 15),

                Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                Divider(),

                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _firestore
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('comments')
                        .orderBy('createdAt')
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Unable to load comments'));
                      }

                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var comments = snapshot.data!.docs;

                      if (comments.isEmpty) {
                        return Center(child: Text('No comments yet'));
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var comment = comments[index];

                          String commentUid = comment.data()['uid'] ?? '';

                          if (commentUid.isEmpty) {
                            return SizedBox();
                          }

                          return FutureBuilder<
                            DocumentSnapshot<Map<String, dynamic>>
                          >(
                            future: _firestore
                                .collection('users')
                                .doc(commentUid)
                                .get(),

                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return SizedBox();
                              }

                              if (!userSnapshot.data!.exists) {
                                return SizedBox();
                              }

                              var user = userSnapshot.data!.data()!;

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Icon(Icons.person),
                                ),

                                title: Text(
                                  user['user_name'] ?? 'User',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                subtitle: Text(comment.data()['comment'] ?? ''),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                Divider(),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: commentPost,
                        icon: Icon(Icons.send, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deletePost() async {
    try {
      await _firestore.collection('posts').doc(widget.postId).delete();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed')));
    }
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Do you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Cancel'),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await deletePost();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _firestore.collection('users').doc(widget.uid).get(),

      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return SizedBox();
        }

        var user = userSnapshot.data!.data()!;
        String profileUrl = user['profile_url'] ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Targetpage(
                        uid: widget.uid,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: profileUrl.isNotEmpty
                      ? NetworkImage(profileUrl)
                      : null,
                  child: profileUrl.isEmpty ? Icon(Icons.person) : null,
                ),
              ),

              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Targetpage(
                        uid: widget.uid,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                },
                child: Text(
                  user['user_name'] ?? 'User',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              trailing: widget.uid == widget.currentUserId
                  ? IconButton(
                      onPressed: confirmDelete,
                      icon: Icon(Icons.more_vert),
                    )
                  : SizedBox(),
            ),
            Image.network(
              widget.image,
              width: double.infinity,
              height: 450,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            Row(
              children: [
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('likes')
                      .snapshots(),

                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading likes');
                    }

                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    var likes = snapshot.data!.docs;

                    bool isLiked = likes.any(
                      (like) => like.id == widget.currentUserId,
                    );

                    return Row(
                      children: [
                        IconButton(
                          onPressed: likePost,
                          icon: SvgPicture.asset(
                            isLiked
                                ? 'assets/icons/like_fill.svg'
                                : 'assets/icons/like.svg',
                            width: 25,
                            height: 25,
                          ),
                        ),

                        Text(
                          '${likes.length}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .snapshots(),

                  builder: (context, snapshot) {
                    int commentCount = 0;

                    if (snapshot.hasData) {
                      commentCount = snapshot.data!.docs.length;
                    }

                    return Row(
                      children: [
                        IconButton(
                          onPressed: showComments,
                          icon: SvgPicture.asset(
                            'assets/icons/comments.svg',
                            height: 25,
                            width: 25,
                          ),
                        ),

                        Text(
                          '$commentCount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),

                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('posts')
                      .doc(originalPostId)
                      .snapshots(),

                  builder: (context, snapshot) {
                    int count = 0;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      count = (snapshot.data!.data()?['reshareCount'] ?? 0);
                    }

                    return Row(
                      children: [
                        IconButton(
                          onPressed: resharePost,
                          icon: SvgPicture.asset(
                            'assets/icons/reshare.svg',
                            height: 25,
                            width: 25,
                          ),
                        ),

                        Text(
                          '$count',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
                Spacer(),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('users')
                      .doc(widget.currentUserId)
                      .collection('saved_posts')
                      .doc(originalPostId)
                      .snapshots(),

                  builder: (context, snapshot) {
                    bool isSaved = snapshot.data?.exists ?? false;

                    return IconButton(
                      onPressed: savePost,
                      icon: SvgPicture.asset(
                        'assets/icons/saved.svg',
                        height: 25,
                        width: 25,
                        colorFilter: ColorFilter.mode(
                          isSaved ? Colors.white : Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: '${user['user_name'] ?? 'User'} ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    TextSpan(
                      text: widget.content,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),

            Divider(),
          ],
        );
      },
    );
  }
}
