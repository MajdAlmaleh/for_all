import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String senderUsername;
  final String messageText;
  final String senderImage;
  final Timestamp timestamp;

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.senderUsername,
      required this.senderImage,
      required this.messageText,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderUsername': senderUsername,
      'senderImage': senderImage,
      'messageText': messageText,
      'createdAt': timestamp,
    };
  }
}
