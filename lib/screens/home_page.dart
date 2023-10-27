import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:for_all/screens/profile.dart';
import 'package:for_all/widgets/post.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final textController = TextEditingController();
  String uid = '';
  List<String> followedUserIds = [];

  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(context);

  void onTextChanged(String value) {
    textController.text = value;
  }

  Future<void> onFindPressed() async {
    final followDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('follows')
        .get();
    followedUserIds = followDocs.docs.map((doc) => doc.id).toList();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: textController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      uid = querySnapshot.docs.first.id;
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfileScreen(uid: uid),
      ));
    } else {
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:const EdgeInsets.only(left: 40),
          margin:const EdgeInsets.all(8),
          height: 55,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.grey[400]),
          child: Row(
        
            children: [
              Expanded(
                child: TextField(
                  style:const TextStyle(fontSize: 20),
                  controller: textController,
                  onChanged: onTextChanged,
                  decoration:const InputDecoration(border: InputBorder.none,),
                ),
              ),
              IconButton(onPressed: onFindPressed, icon:const Icon(Icons.search,size: 50,))
            ],
          ),
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
              return const Text('No followers yet');
            }

            List<String> followedUserIds = snapshot.data!.docs
                .map((doc) => doc['follow_id'].toString())
                .toList();
            //todo keep   followedUserIds = followDocs.docs.map((doc) => doc.id).toList();

            return StreamBuilder(
  stream: FirebaseFirestore.instance
      .collectionGroup('post')
      .where('userId', whereIn: followedUserIds)
      .orderBy('createdAt', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    final posts = snapshot.data!.docs;
    if (!snapshot.hasData || posts.isEmpty) {
      return const Text('No posts yet');
    }

    posts.sort((a, b) {
      int timestampA = a['createdAt'];
      int timestampB = b['createdAt'];
      return timestampB.compareTo(timestampA);
    });

    return Expanded(
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> data =
              posts[index].data();
          return Center(
            child: Post(
              postText: data['post_text'], 
              username: data['username'], 
              userImage: data['userImage'],
              postMedia: data['post_data'],
               mediaType: data['mediaType'],
            )
          ); 
        },
      ),
    );
  },
);
          },
        )
      ],
    );
  }
}
