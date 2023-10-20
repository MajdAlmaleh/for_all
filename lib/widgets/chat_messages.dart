import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:for_all/widgets/message_bubble.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({Key? key, required this.receiver});
  final String receiver;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .doc(userId)
          .collection('massege')
          .where('receiverId', isEqualTo: widget.receiver)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }
        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentChatMessageUserId = chatMessage['userId'];
            final nextChatMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame =
                currentChatMessageUserId == nextChatMessageUserId;

            if (!nextUserIsSame) {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['userName'],
                message: chatMessage['text'],
                isMe: userId == currentChatMessageUserId,
              );
            } else {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: userId == currentChatMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
