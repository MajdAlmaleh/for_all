import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/widgets/contact_bubble.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chat')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child:  Text('No Contacts yet'));
        }

        List<String> chatUserId = snapshot.data!.docs
            .map((doc) => doc['chat_id'].toString())
            .toList();
        return ListView(
          children: chatUserId
              .map((uid) => ContactBubble(
                    uid: uid,
                  ))
              .toList(),
        );
      },
    );
  }
}
