// ignore_for_file: use_rethrow_when_possible

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(FirebaseAuth.instance.currentUser);

  Future<void> signUp(
      //todo photo
      {required String email,
      required String password,
      required String username,
      String? bio}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    
      state = userCredential.user;

      if (state != null) {
        await updateUserProfile(username: username, bio: bio);
      }
    }  catch (e) {
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

  Future<void> updateUserProfile({required username, String? bio}) async {
    if (state != null) {
      await FirebaseFirestore.instance.collection('users').doc(state!.uid).set({
        'username': username,
        if (bio != null) 'bio': bio,
      }, SetOptions(merge: true));
    }
  }
}

final authProvider =
    StateNotifierProvider<UserNotifier, User?>((ref) => UserNotifier());
