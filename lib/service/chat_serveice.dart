import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:for_all/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String messageText,
      String currentUserUsername, String userImageUrl) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUsername = currentUserUsername;
    final String currentUserImage = userImageUrl;
    final Timestamp timestamp = Timestamp.now();
    const bool seen = false;

    Message newMessage = Message(
        senderId: currentUserId,
        receiverId: receiverId,
        senderUsername: currentUsername,
        senderImage: currentUserImage,
        messageText: messageText,
        timestamp: timestamp,
        seen: seen);

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
// DocumentReference docRef =
    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Stream getSeen(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('seen', isEqualTo: false)
        .snapshots();
  }

 Future<void> updateAllMessages(String chatRoomId) async {

  try{
  final messagesSnapshot = await FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .get();

  for (var message in messagesSnapshot.docs) {
    await message.reference.update({'seen': true});
  }}
  catch(e){
    print(e);
  }
}
}
