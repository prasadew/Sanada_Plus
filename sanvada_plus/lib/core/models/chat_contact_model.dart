import 'package:cloud_firestore/cloud_firestore.dart';

class ChatContactModel {
  final String contactId;
  final String name;
  final String profilePic;
  final String lastMessage;
  final DateTime timeSent;
  final int unreadCount;

  const ChatContactModel({
    required this.contactId,
    required this.name,
    required this.profilePic,
    required this.lastMessage,
    required this.timeSent,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'contactId': contactId,
      'name': name,
      'profilePic': profilePic,
      'lastMessage': lastMessage,
      'timeSent': Timestamp.fromDate(timeSent),
      'unreadCount': unreadCount,
    };
  }

  factory ChatContactModel.fromMap(Map<String, dynamic> map) {
    return ChatContactModel(
      contactId: map['contactId'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      timeSent: (map['timeSent'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }
}
