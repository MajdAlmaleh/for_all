import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/auth_provider.dart';
import 'package:for_all/screens/posting.dart';
import 'package:for_all/widgets/post.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.uid});
  final String uid;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? userImage;
  String? username;
  bool? isFollowing;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    userImage =
        await ref.read(authProvider.notifier).getUserImage(uid: widget.uid);
    if (mounted) {
      username =
          await ref.read(authProvider.notifier).getUserName(uid: widget.uid);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(children: [
          buildProfileHeader(),
          if (username != null) Text(username!), //todo add bio
          if (widget.uid != FirebaseAuth.instance.currentUser!.uid)
            buildFollowButton(),
          if (widget.uid == FirebaseAuth.instance.currentUser!.uid)
            buildNewPostButton(),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collectionGroup('post')
                .where('userId', isEqualTo: widget.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final posts = snapshot.data!.docs;
              if (!snapshot.hasData || posts.isEmpty) {
                return const Text('No posts yet');
              }

              posts.sort((a, b) {
                int timestampA = a['createdAt'];
                int timestampB = b['createdAt'];
                return timestampB.compareTo(timestampA);
              });

              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = posts[index].data();
                    return Center(
                        child: Post(
                      postText: data['post_text'],
                      username: data['username'],
                      userImage: data['userImage'],
                      postMedia: data['post_data'],
                      mediaType: data['mediaType'],
                    ));
                  },
                ),
              );
            },
          )
        ]),
      ),
    );
  }

  Widget buildProfileHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Hero(
          tag: 0,
          child: CircleAvatar(
            radius: 70,
            backgroundImage:
                userImage != null ? NetworkImage(userImage!) : null,
          ),
        ),
      ),
    );
  }

  Widget buildFollowButton() {
    return GestureDetector(
      onTap: () async {
        if (isFollowing == null) {
          return;
        } else if (!isFollowing!) {
          // Follow the user
          final snapshot1 = await FirebaseFirestore.instance
              .collection('chats')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('chat')
              .where('chat_id', isEqualTo: widget.uid)
              .get();
          // ignore: avoid_function_literals_in_foreach_calls
          snapshot1.docs.forEach((document) async {
            await document.reference.delete();
          });

          final snapshot2 = await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.uid)
              .collection('chat')
              .where('chat_id',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .get();
          // ignore: avoid_function_literals_in_foreach_calls
          snapshot2.docs.forEach((document) async {
            await document.reference.delete();
          });

          await FirebaseFirestore.instance
              .collection('follows')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('follow')
              .add({
            'follow_id': widget.uid,
          });

          await FirebaseFirestore.instance
              .collection('chats')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('chat')
              .add({
            'chat_id': widget.uid,
          });
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.uid)
              .collection('chat')
              .add({
            'chat_id': FirebaseAuth.instance.currentUser!.uid,
          });

          isFollowing = true;
        } else if (isFollowing!) {
          // Unfollow the user
          final snapshot = await FirebaseFirestore.instance
              .collection('follows')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('follow')
              .where('follow_id', isEqualTo: widget.uid)
              .get();
          // ignore: avoid_function_literals_in_foreach_calls
          snapshot.docs.forEach((document) async {
            await document.reference.delete();
          });

          final snapshot1 = await FirebaseFirestore.instance
              .collection('chats')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('chat')
              .where('chat_id', isEqualTo: widget.uid)
              .get();
          // ignore: avoid_function_literals_in_foreach_calls
          snapshot1.docs.forEach((document) async {
            await document.reference.delete();
          });

          final snapshot2 = await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.uid)
              .collection('chat')
              .where('chat_id',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .get();
          // ignore: avoid_function_literals_in_foreach_calls
          snapshot2.docs.forEach((document) async {
            await document.reference.delete();
          });

          isFollowing = false;
        }
        if (mounted) {
          setState(() {});
        }
      },
      child: Chip(
        label: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('follows')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('follow')
              .where('follow_id', isEqualTo: widget.uid)
              .get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              isFollowing = null;
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData ||
                snapshot.hasError ||
                snapshot.data.docs.isEmpty) {
              isFollowing = false;
            } else {
              isFollowing = true;
            }
            return Text(isFollowing! ? 'Unfollow' : 'Follow');
          },
        ),
        avatar: const Icon(Icons.add),
      ),
    );
  }

  Widget buildNewPostButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const PostingScreen(),
        ));
      },
      child: const Chip(
        label: Text('New post'),
        avatar: Icon(Icons.add),
      ),
    );
  }
}
