import 'package:flutter/material.dart';
import 'package:for_all/widgets/chat_messages.dart';
import 'package:for_all/widgets/new_massage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.receiver
  });
  final String receiver;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Scaffold(
      body: Column(children: [
        Expanded(child: ChatMessages(receiver: widget.receiver,)),
        NewMessage(receiver: widget.receiver,),
      ]),
    ));
  }
}
