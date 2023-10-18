import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:for_all/screens/profile.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  var textController = TextEditingController();
  String uid = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: textController,
          onChanged: (value) {
            textController.text = value;
            print(textController.text);
          },
        ),
        TextButton(
          onPressed: () async {
            final querySnapshot = await FirebaseFirestore.instance
                .collection('users')
                .where('username', isEqualTo: textController.text)
                .get();
            bool doesUsernameExist = querySnapshot.docs.length > 0;

            if (doesUsernameExist) {
              uid = querySnapshot.docs.first.id;
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(uid: uid),
              ));
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('user not found')));
            }
          },
          child: const Text('find'),
        )
      ],
    );
  }
}
