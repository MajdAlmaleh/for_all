// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/user_provider.dart';
import 'package:for_all/screens/chat.dart';

class ContactBubble extends ConsumerStatefulWidget {
  final String uid;
  const ContactBubble({super.key, required this.uid});

  @override
  ConsumerState<ContactBubble> createState() => _ContactBubbleState();
}

class _ContactBubbleState extends ConsumerState<ContactBubble> {
  var userImage;
  var username;
  @override
  void initState() {
    super.initState();
    loadUserData();
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
  Widget build(
    BuildContext context,
  ) {
   

    return ListTile(
      
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: userImage != null ? NetworkImage(userImage) : null,
      ),
      title:    username != null? Text(username!):null,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  ChatScreen(receiver: widget.uid,),
            ));
      },
    );
  }
}
