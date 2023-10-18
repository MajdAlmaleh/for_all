import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageNotifier extends StateNotifier<String?> {
  ImageNotifier() : super(null);

  Future<String?> getUserImage() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    state = data['image_url'];
    return state;
  }
}

final userImageProvider =
    StateNotifierProvider<ImageNotifier, String?>((ref) => ImageNotifier());
