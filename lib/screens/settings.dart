import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/user_provider.dart';
import 'package:for_all/screens/profile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // ignore: prefer_typing_uninitialized_variables
  var userImage;

  @override
  void initState() {
    super.initState();
  }

  void getUserImage() async {
    userImage = await ref.read(authProvider.notifier).getUserImage(uid: FirebaseAuth.instance.currentUser!.uid);
    if (mounted){   setState(() {});}
 
  }

  @override
  Widget build(BuildContext context) {
    getUserImage();
   

    return Column(
      children: [
        ListTile(
          leading: Hero(
            tag: 0,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: userImage != null ? NetworkImage(userImage) : null,
            ),
          ),
          title: const Text('Profile'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  ProfileScreen( uid: FirebaseAuth.instance.currentUser!.uid,),
                ));
          },
        ),
const Spacer(),

        TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Sign out')),
      ],
    );
  }
}
