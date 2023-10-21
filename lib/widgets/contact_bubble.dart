// ignore_for_file: prefer_typing_uninitialized_variables

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
                  List<String> ids = [FirebaseAuth.instance.currentUser!.uid, widget.uid];
       ids.sort();
       String chatRoomId = ids.join('_');
     chatService.updateAllMessages(chatRoomId);


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
      title: username != null ? Text(username!) : null,
      trailing: StreamBuilder(
        stream: chatService.getSeen(
            FirebaseAuth.instance.currentUser!.uid, widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('');
          }

          List loadedMessages = snapshot.data!.docs;

          final lastMessage = loadedMessages.last;
          Map<String, dynamic> data =
              lastMessage.data() as Map<String, dynamic>;

          if (data['seen'] == false) {
            return const CircleAvatar(
              radius: 5,
              backgroundColor: Colors.amber,
            );
          } else
            return Text('');
        },
      ),
      onTap: ()async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiver: widget.uid,
              ),
            ));
     //   List<String> ids = [FirebaseAuth.instance.currentUser!.uid, widget.uid];
     //   ids.sort();
     //   String chatRoomId = ids.join('_');
    //  await  chatService.updateSeenStatus(chatRoomId);
      },
    );
  }
}
