import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

 const MessageBubble({
  super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
     var theme = Theme.of(context);
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe
                        ? Colors.grey[300]
                        : theme.colorScheme.secondary.withAlpha(200),  borderRadius:const BorderRadius.only(
              topLeft:   Radius.circular(12),
              topRight:  Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          constraints:const BoxConstraints(maxWidth: 200),
          padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin:const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Text(
            message,
            style: TextStyle(
              height: 1.3,
              color: isMe ? Colors.black87 : theme.colorScheme.onSecondary,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
