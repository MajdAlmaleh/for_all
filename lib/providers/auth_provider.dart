// ignore_for_file: use_rethrow_when_possible

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(FirebaseAuth.instance.currentUser);
  Future<void> signUp(
      {required String email,
      required String password,
      required String username,
      File? userImage,
      String? bio}) async {
    try {
      // Check if the username already exists
      final usernameSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameSnapshot.docs.isNotEmpty) {
        throw Exception('Username already taken');
      }

      // Create the user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      state = userCredential.user;
      // Upload the image to Firebase Storage and get the download URL
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$username.jpg');
      await storageRef.putFile(userImage!);
      final imageUrl = await storageRef.getDownloadURL();

      // Create the user document in Firestore
      if (state != null) {
        await updateUserProfile(
            username: username, bio: bio, userImageUrl: imageUrl);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      state = userCredential.user;
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = FirebaseAuth.instance.currentUser;
  }

  Future<void> updateUserProfile(
      {required username, String? bio, String? userImageUrl}) async {
    if (state != null) {
      await FirebaseFirestore.instance.collection('users').doc(state!.uid).set({
        'uid': state!.uid,
        'username': username,
        if (bio != null) 'bio': bio,
        if (userImageUrl != null) 'image_url': userImageUrl,
      }, SetOptions(merge: true));
    }
  }

  Future<String?> getUserName({required String uid}) async {
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

    return data['username'];
  }

  Future<String?> getUserImage({required String uid}) async {
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    return data['image_url'];
  } //todo for bio
}

final authProvider =
    StateNotifierProvider<UserNotifier, User?>((ref) => UserNotifier());
