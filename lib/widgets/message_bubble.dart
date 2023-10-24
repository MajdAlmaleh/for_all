import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/reply_messages.dart';

class MessageBubble extends ConsumerStatefulWidget {
  final String message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble> {
  double _moveAmountLeft = 0;
  double _moveAmountRight = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!widget.isMe)
          SizedBox(
            width: -_moveAmountRight,
          ),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _moveAmountLeft += details.delta.dx;
              _moveAmountRight -= details.delta.dx;

              if (_moveAmountLeft < -100) {
                _moveAmountLeft = -100;
              }
              if (_moveAmountLeft > 0) {
                _moveAmountLeft = 0;
              }

              if (_moveAmountRight < -100) {
                _moveAmountRight = -100;
              }
              if (_moveAmountRight > 0) {
                _moveAmountRight = 0;
              }
            });
          },
          onHorizontalDragEnd: (details) {
            if (-_moveAmountRight >= 80 || -_moveAmountLeft >= 80) {
              ref.read(replyMessageProvider.notifier).setReplay(widget.message);
            }

            setState(() {
              _moveAmountLeft = 0;
              _moveAmountRight = 0;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.isMe
                  ? Colors.grey[300]
                  : theme.colorScheme.secondary.withAlpha(200),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: Text(
              widget.message,
              style: TextStyle(
                height: 1.3,
                color: widget.isMe
                    ? Colors.black87
                    : theme.colorScheme.onSecondary,
              ),
              softWrap: true,
            ),
          ),
        ),
        if (widget.isMe)
          SizedBox(
            width: -_moveAmountLeft,
          ),
      ],
    );
  }
}
