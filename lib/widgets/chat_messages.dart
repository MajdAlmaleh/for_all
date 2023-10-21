import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/user_provider.dart';
import 'package:for_all/service/chat_serveice.dart';
import 'package:for_all/widgets/message_bubble.dart';

class ChatMessages extends ConsumerStatefulWidget {
  const ChatMessages({super.key, required this.receiver});
  final String receiver;

  @override
  ConsumerState<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends ConsumerState<ChatMessages> {
  ChatService chatService = ChatService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider.notifier);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: chatService.getMessages(userId, widget.receiver),
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

        final ScrollController scrollController = ScrollController();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: false,
          controller: scrollController,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                loadedMessages[index].data() as Map<String, dynamic>;

            return MessageBubble(
              message: data['messageText'],
              isMe: data['senderId'] == FirebaseAuth.instance.currentUser!.uid,
            );
          },
        );
      },
    );
  }
}
