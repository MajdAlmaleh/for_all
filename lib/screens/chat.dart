import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/user_provider.dart';
import 'package:for_all/service/chat_serveice.dart';
import 'package:for_all/widgets/chat_messages.dart';
import 'package:for_all/widgets/new_massage.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.receiver});
  final String receiver;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  ChatService chatService = ChatService();

  String? receiverUsername;
  String? receiverUserImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getReceiverUsername();
  }

  void getReceiverUsername() async {
    receiverUsername = await ref
        .watch(authProvider.notifier)
        .getUserName(uid: widget.receiver);
        if (mounted) {
      receiverUserImage = await ref
        .watch(authProvider.notifier)
        .getUserImage(uid: widget.receiver);
    }
   
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider.notifier);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
       
        title: receiverUsername == null ? null : Row(
       
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Padding(
               padding: const EdgeInsets.all(4.0),
               child: CircleAvatar(backgroundImage: NetworkImage(receiverUserImage!),),
             ),
            Text(receiverUsername!),
          ],
        )),
      body: Column(children: [
        Expanded(
            child: ChatMessages(
          receiver: widget.receiver,
        )),
        NewMessage(
          receiver: widget.receiver,
        ),
      ]),
    ));
  }
}
