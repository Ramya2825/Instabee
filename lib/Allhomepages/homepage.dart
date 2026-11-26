import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialmedia_project/Allhomepages/targetpage.dart';
import 'package:socialmedia_project/map_page.dart';

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
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        leading: Padding(
          padding: EdgeInsets.all(12),

          child: Image.asset(
            'assets/icons/logo.png',
            width: 130,
            height: 60,
            fit: BoxFit.fill,
          ),
        ),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Insta',
                      style: GoogleFonts.orbitron(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Bee',
                      style: GoogleFonts.orbitron(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BeeNearbyPage()),
              );
            },
            icon: Icon(Icons.location_on, color: Colors.orange, size: 35),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var posts = snapshot.data!.docs.where((post) {
            String uid = post.data()['uid'] ?? '';
            return uid.isNotEmpty;
          }).toList();

          if (posts.isEmpty) {
            return Center(
              child: Text(
                'No posts available',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(top: 10, bottom: 20),
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
      String? id = data['original_post_id'];
      if (id != null && id.isNotEmpty) {
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

  bool isResharing = false;
  Future<void> resharePost() async {
    if (isResharing) return;

    setState(() {
      isResharing = true;
    });
    String uid = widget.currentUserId;
    var postRef = _firestore.collection('posts').doc(originalPostId);
    var reshareRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('reshared_posts')
        .doc(originalPostId);

    try {
      var postSnapshot = await postRef.get();

      if (!postSnapshot.exists) {
        throw Exception('Original post not found');
      }

      var existing = await reshareRef.get();
      if (existing.exists) {
        await reshareRef.delete();
        await postRef.update({'reshareCount': FieldValue.increment(-1)});
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Reshare Removed')));
      } else {
        await reshareRef.set({
          'original_post_id': originalPostId,
          'original_uid': postSnapshot.data()?['uid'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        await postRef.update({'reshareCount': FieldValue.increment(1)});
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post reshared Successfully')));
      }
    } catch (e) {
      print('RESHARE ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          isResharing = false;
        });
      }
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
          .showSnackBar(SnackBar(content: Text('Saved Collection')));
    } finally {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('UnSaved Collection')));
    }
  }

  Future<void> commentPost() async {
    String comment = commentController.text.trim();

    if (comment.isEmpty) return;

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
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
      ),
      builder: (bottomContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(bottomContext).size.height * 0.50,
            child: Column(
              children: [
                SizedBox(height: 15),
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),

                Divider(color: Colors.white24),

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
                        return Center(
                          child: Text(
                            'Unable to load comments',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      var comments = snapshot.data!.docs;

                      if (comments.isEmpty) {
                        return Center(
                          child: Text(
                            'No comments yet',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
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
                              if (!userSnapshot.hasData ||
                                  !userSnapshot.data!.exists) {
                                return SizedBox();
                              }

                              var user = userSnapshot.data!.data()!;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                ),
                                title: Text(
                                  user['user_name'] ?? 'User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  comment.data()['comment'] ?? '',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Color(0xFF303030),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: commentPost,
                        icon: Icon(Icons.send, color: Colors.white),
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
          backgroundColor: Color(0xFF252525),
          title: Text('Delete Post', style: TextStyle(color: Colors.white)),
          content: Text(
            'Do you want to delete this post?',
            style: TextStyle(color: Colors.white70),
          ),
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
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
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

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 3,
                ),
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
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: profileUrl.isNotEmpty
                        ? NetworkImage(profileUrl)
                        : null,
                    child: profileUrl.isEmpty
                        ? Icon(Icons.person, color: Colors.black)
                        : null,
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                trailing: widget.uid == widget.currentUserId
                    ? IconButton(
                        onPressed: confirmDelete,
                        icon: Icon(Icons.more_vert, color: Colors.white),
                      )
                    : SizedBox(),
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.network(
                  widget.image,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: [
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _firestore
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('likes')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Error loading likes',
                            style: TextStyle(color: Colors.white),
                          );
                        }

                        if (!snapshot.hasData) {
                          return SizedBox(
                            width: 35,
                            height: 35,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
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
                                colorFilter: ColorFilter.mode(
                                  isLiked ? Colors.redAccent : Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Text(
                              '${likes.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Text(
                              '$commentCount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                          count = snapshot.data!.data()?['reshareCount'] ?? 0;
                        }

                        return Row(
                          children: [
                            IconButton(
                              onPressed: isResharing ? null : resharePost,
                              icon: SvgPicture.asset(
                                'assets/icons/reshare.svg',
                                height: 25,
                                width: 25,
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    Spacer(),
                    SizedBox(width: 50),

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
                            isSaved
                                ? 'assets/icons/fillbookmark.svg'
                                : 'assets/icons/unbookmark.svg',
                            height: 22,
                            width: 22,
                            colorFilter: ColorFilter.mode(
                              isSaved ? Colors.white : Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    children: [
                      TextSpan(
                        text: '${user['user_name'] ?? 'User'} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: widget.content,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
