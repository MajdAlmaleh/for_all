// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/user_provider.dart';
import 'package:for_all/screens/chat.dart';
import 'package:for_all/service/chat_serveice.dart';

class ContactBubble extends ConsumerStatefulWidget {
  final String uid;
  const ContactBubble({super.key, required this.uid});

  @override
  ConsumerState<ContactBubble> createState() => _ContactBubbleState();
}

class _ContactBubbleState extends ConsumerState<ContactBubble> {
  var userImage;
  var username;
  ChatService chatService = ChatService();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<bool> hasNewMessagesStream(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final lastMessage = querySnapshot.docs.first;
        // final messageStatus = lastMessage['messageStatus'];
        final seen = lastMessage['seen'];
        if (FirebaseAuth.instance.currentUser!.uid == lastMessage['senderId']) {
          return false;
        }
        return !seen; //messageStatus == 'sent' &&
      }
      return false; // No messages found
    });
  }

  String getLastMessage = '';

  Stream lastNewMessagesStream(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final lastMessage = querySnapshot.docs.first;
        // final messageStatus = lastMessage['messageStatus'];
        return lastMessage['messageText'].toString();
        /*  if (FirebaseAuth.instance.currentUser!.uid == lastMessage['senderId']) {
          return false;
        } */
        // return !seen; //messageStatus == 'sent' &&
      }
      return null;
      //return false; // No messages found
    });
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
    return StreamBuilder<bool>(
      stream: hasNewMessagesStream(
          FirebaseAuth.instance.currentUser!.uid, widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); //TODO change this because its ugly
        }

        final bool hasNewMessages = snapshot.data ?? false;

        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: userImage != null ? NetworkImage(userImage) : null,
          ),
          title: username != null ? Text(username!) : null,
          subtitle: StreamBuilder(
            stream: lastNewMessagesStream(
                FirebaseAuth.instance.currentUser!.uid, widget.uid),
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            
          ); //TODO change this because its ugly
        }


              return Text(snapshot.data);
            },
          ),
          trailing: hasNewMessages
              ? const CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.blue, // Set your desired color
                )
              : null,
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiver: widget.uid,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
