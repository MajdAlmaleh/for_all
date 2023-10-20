import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/user_provider.dart';
import 'package:for_all/screens/posting.dart';
import 'package:for_all/widgets/posts.dart';

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildProfileHeader(),
                 if (username != null) Text(username!), //todo add bio
              if (widget.uid != FirebaseAuth.instance.currentUser!.uid)
              buildFollowButton(),
              if (widget.uid == FirebaseAuth.instance.currentUser!.uid)
                buildNewPostButton(),
             PostsBuilder(uid: widget.uid),
            ],
          ),
        ),
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
          await FirebaseFirestore.instance
              .collection('follows')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('follow')
              .add({
            'follow_id': widget.uid,
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
          isFollowing = false;
        }
        setState(() {});
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
