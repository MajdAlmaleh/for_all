import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/reply_messages.dart';
import 'package:for_all/providers/auth_provider.dart';
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

    chatService.sendMessage(widget.receiver, enteredMessage, userName!,
        userImage!, ref.read(replyMessageProvider.notifier).getReplay());
            ref.read(replyMessageProvider.notifier).cancleReplay();

  }

  @override
  Widget build(BuildContext context) {
    ref.watch(replyMessageProvider);
    return Column(
      children: [
        if (ref.watch(replyMessageProvider.notifier).getReplay() != null)
          Container(
            height: 70,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Color.fromARGB(122, 113, 178, 232),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: Center(
              child: ListTile(
                title:
                    Text(ref.watch(replyMessageProvider.notifier).getReplay()!),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.watch(replyMessageProvider.notifier).cancleReplay();
                  },
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration:
                      const InputDecoration(labelText: 'Send a message...'),
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
        ),
      ],
    );
  }
}
