import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreCollectionNotifier extends StateNotifier<AsyncValue<List<DocumentSnapshot>>> {
  final CollectionReference collection;

  FirestoreCollectionNotifier(this.collection) : super(const AsyncValue.loading()) {
    _fetchCollection();
  }

  StreamSubscription? _subscription;

  void _fetchCollection() {
    _subscription?.cancel();
    _subscription = collection.snapshots().listen(
      (snapshot) {
        state = AsyncValue.data(snapshot.docs);
      },
      onError: (error, stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final firestoreCollectionProvider = StateNotifierProvider<FirestoreCollectionNotifier, AsyncValue<List<DocumentSnapshot>>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('posts').doc(FirebaseAuth.instance.currentUser!.uid).collection('post');
  return FirestoreCollectionNotifier(collection);
});
