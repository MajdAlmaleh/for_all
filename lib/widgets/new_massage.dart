import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/user_provider.dart';
import 'package:for_all/service/chat_serveice.dart';

class NewMessage extends ConsumerStatefulWidget {
  const NewMessage({super.key, required this.receiver});
  final String receiver;

  @override
  ConsumerState<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends ConsumerState<NewMessage> {
  final _messageController = TextEditingController();
  ChatService chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    final enteredMessage = _messageController.text.trim();

    if (enteredMessage.isEmpty) {
      return;
    }
    _messageController.clear();
    final userName = await ref
        .read(authProvider.notifier)
        .getUserName(uid: _firebaseAuth.currentUser!.uid);
    final userImage = await ref
        .read(authProvider.notifier)
        .getUserImage(uid: _firebaseAuth.currentUser!.uid);

    
    //  FocusScope.of(context).unfocus();

    chatService.sendMessage(
        widget.receiver, enteredMessage, userName!, userImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(
              Icons.send,
            ),
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}
