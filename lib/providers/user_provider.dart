// ignore_for_file: use_rethrow_when_possible

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(FirebaseAuth.instance.currentUser);

  Future<void> signUp(
      //todo photo
      {required String email,
      required String password,
      required String username,
      File? userImage,
      String? bio}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredential.user!.uid}.jpg');
      await storageRef.putFile(userImage!);
      final imageUrl = await storageRef.getDownloadURL();
      state = userCredential.user;

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
        'username': username,
        if (bio != null) 'bio': bio,
        if (userImageUrl != null) 'image_url': userImageUrl,
      }, SetOptions(merge: true));
    }
  }

  Future<String> getUsername() async {
    final username = await FirebaseFirestore.instance
        .collection('users')
        .doc(state!.uid)
        .collection('username')
        .get();
    return username.toString();
  }
}

final authProvider =
    StateNotifierProvider<UserNotifier, User?>((ref) => UserNotifier());
