import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/models/chat_contact_model.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/utils.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  String? get _currentUid => _auth.currentUser?.uid;

  // ── Send a text message ──────────────────────────────────────
  Future<void> sendTextMessage({
    required String receiverId,
    required String receiverName,
    required String receiverProfilePic,
    required String text,
  }) async {
    if (_currentUid == null) return;

    final chatId = getChatId(_currentUid!, receiverId);
    final messageId = _uuid.v4();
    final now = DateTime.now();

    final message = MessageModel(
      messageId: messageId,
      senderId: _currentUid!,
      receiverId: receiverId,
      text: text,
      type: MessageType.text,
      timeSent: now,
      isSeen: false,
    );

    // Save message to messages subcollection
    await _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConstants.messagesCollection)
        .doc(messageId)
        .set(message.toMap());

    // Get current user data for the contact entry
    final currentUserDoc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_currentUid!)
        .get();

    final senderName = currentUserDoc.data()?['name'] ?? 'Unknown';
    final senderProfilePic = currentUserDoc.data()?['profilePic'] ?? '';

    // Update sender's chat contacts
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_currentUid!)
        .collection(FirebaseConstants.chatsCollection)
        .doc(receiverId)
        .set(ChatContactModel(
          contactId: receiverId,
          name: receiverName,
          profilePic: receiverProfilePic,
          lastMessage: text,
          timeSent: now,
          unreadCount: 0,
        ).toMap());

    // Update receiver's chat contacts (increment unread count)
    final receiverChatDoc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(receiverId)
        .collection(FirebaseConstants.chatsCollection)
        .doc(_currentUid!)
        .get();

    final currentUnread = receiverChatDoc.exists
        ? (receiverChatDoc.data()?['unreadCount'] ?? 0) + 1
        : 1;

    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(receiverId)
        .collection(FirebaseConstants.chatsCollection)
        .doc(_currentUid!)
        .set(ChatContactModel(
          contactId: _currentUid!,
          name: senderName,
          profilePic: senderProfilePic,
          lastMessage: text,
          timeSent: now,
          unreadCount: currentUnread,
        ).toMap());
  }

  // ── Send an image message ─────────────────────────────────────
  Future<void> sendImageMessage({
    required String receiverId,
    required String receiverName,
    required String receiverProfilePic,
    required File imageFile,
  }) async {
    if (_currentUid == null) return;

    final chatId = getChatId(_currentUid!, receiverId);
    final messageId = _uuid.v4();
    final now = DateTime.now();

    // Upload image to Firebase Storage
    final ref = _storage
        .ref()
        .child(FirebaseConstants.chatImagesFolder)
        .child(chatId)
        .child('$messageId.jpg');
    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final imageUrl = await ref.getDownloadURL();

    final message = MessageModel(
      messageId: messageId,
      senderId: _currentUid!,
      receiverId: receiverId,
      text: imageUrl,
      type: MessageType.image,
      timeSent: now,
      isSeen: false,
    );

    await _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConstants.messagesCollection)
        .doc(messageId)
        .set(message.toMap());

    // Get current user data
    final currentUserDoc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_currentUid!)
        .get();
    final senderName = currentUserDoc.data()?['name'] ?? 'Unknown';
    final senderProfilePic = currentUserDoc.data()?['profilePic'] ?? '';

    // Update sender's chat contacts
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_currentUid!)
        .collection(FirebaseConstants.chatsCollection)
        .doc(receiverId)
        .set(ChatContactModel(
          contactId: receiverId,
          name: receiverName,
          profilePic: receiverProfilePic,
          lastMessage: '\uD83D\uDCF7 Photo',
          timeSent: now,
          unreadCount: 0,
        ).toMap());

    // Update receiver's chat contacts
    final receiverChatDoc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(receiverId)
        .collection(FirebaseConstants.chatsCollection)
        .doc(_currentUid!)
        .get();
    final currentUnread = receiverChatDoc.exists
        ? (receiverChatDoc.data()?['unreadCount'] ?? 0) + 1
        : 1;

    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(receiverId)
        .collection(FirebaseConstants.chatsCollection)
        .doc(_currentUid!)
        .set(ChatContactModel(
          contactId: _currentUid!,
          name: senderName,
          profilePic: senderProfilePic,
          lastMessage: '\uD83D\uDCF7 Photo',
          timeSent: now,
          unreadCount: currentUnread,
        ).toMap());
  }

  // ── Typing status ───────────────────────────────────────────
  Future<void> setTypingStatus(String otherUserId, bool isTyping) async {
    if (_currentUid == null) return;
    final chatId = getChatId(_currentUid!, otherUserId);
    await _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .set({
      'typing_${_currentUid!}': isTyping,
    }, SetOptions(merge: true));
  }

  Stream<bool> streamTypingStatus(String otherUserId) {
    if (_currentUid == null) return Stream.value(false);
    final chatId = getChatId(_currentUid!, otherUserId);
    return _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return false;
      final data = snap.data();
      if (data == null) return false;
      return data['typing_$otherUserId'] == true;
    });
  }

  // ── Stream chat contacts (for chat list) ────────────────────
  Stream<List<ChatContactModel>> getChatContacts() {
    if (_currentUid == null) return Stream.value([]);
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_currentUid!)
        .collection(FirebaseConstants.chatsCollection)
        .orderBy('timeSent', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatContactModel.fromMap(doc.data()))
          .toList();
    });
  }

  // ── Stream messages for a specific chat ─────────────────────
  Stream<List<MessageModel>> getChatMessages(String otherUserId) {
    if (_currentUid == null) return Stream.value([]);
    final chatId = getChatId(_currentUid!, otherUserId);
    return _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConstants.messagesCollection)
        .orderBy('timeSent')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList();
    });
  }

  // ── Mark messages as seen ───────────────────────────────────
  Future<void> markMessagesSeen(String otherUserId) async {
    if (_currentUid == null) return;
    final chatId = getChatId(_currentUid!, otherUserId);

    final unreadMessages = await _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConstants.messagesCollection)
        .where('receiverId', isEqualTo: _currentUid)
        .where('isSeen', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isSeen': true});
    }
    await batch.commit();

    // Reset unread count in chat contact
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_currentUid!)
        .collection(FirebaseConstants.chatsCollection)
        .doc(otherUserId)
        .update({'unreadCount': 0});
  }

  // ── Get user data stream ────────────────────────────────────
  Stream<UserModel> streamUserData(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((snap) => UserModel.fromMap(snap.data()!));
  }
}
