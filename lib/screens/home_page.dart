import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:for_all/screens/profile.dart';
import 'package:for_all/widgets/posts.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('user not found')));
            }
          },
          child: const Text('find'),
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('follows')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('follow')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No posts yet');
            }

            return Expanded(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: snapshot.data!.docs.map<Widget>(
                  (DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return PostsBuilder(
                      uid: data['follow_id'],
                      isOrderd: false,
                    );
                  },
                ).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
