import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostsBuilder extends StatelessWidget {
  const PostsBuilder({super.key, required this.uid,required this.isOrderd});
  final String uid;
  final bool isOrderd;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:isOrderd? FirebaseFirestore.instance
          .collection('posts')
          .doc(uid)
          .collection('post')
          .orderBy('createdAt', descending: true)
          .snapshots():FirebaseFirestore.instance
          .collection('posts')
          .doc(uid)
          .collection('post')
      
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No posts yet');
        }

        return Column(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Text(data['post_text']);
          }).toList(),
        );
      },
    );
  }
}
