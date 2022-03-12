import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:rxdart/rxdart.dart';

class MessagesDatabaseService {
  final DocumentReference currUserRef;
  DocumentReference? otherUserRef;

  MessagesDatabaseService({required this.currUserRef, this.otherUserRef});

  // collection reference
  static final CollectionReference messagesCollection = FirebaseFirestore.instance.collection(C.messages);

  static final ImageStorage _images = ImageStorage();

  Future _updateUserMessages(
      {required DocumentReference userRef,
      required DocumentReference otherUserRef,
      Timestamp? lastMessage,
      Timestamp? lastViewed}) async {
    final userData = await userRef.get();
    final userMessages = (userData.get(C.userMessages) as List).map((item) => userMessageFromMap(map: item)).toList();
    // if initiating a message, wait
    if (userMessages.length == 0 && lastMessage == null) return;
    Timestamp? newLastMessage = lastMessage;
    Timestamp? newLastViewed = lastViewed;
    // find and delete old version
    userMessages.forEach((UM) {
      if (UM.otherUserRef == otherUserRef) {
        if (newLastMessage == null)
          newLastMessage = UM.lastMessage;
        else if (newLastMessage!.compareTo(UM.lastMessage) < 0) newLastMessage = UM.lastMessage;
        if (UM.lastViewed != null) {
          if (newLastViewed == null)
            newLastViewed = UM.lastViewed;
          else if (newLastViewed!.compareTo(UM.lastViewed!) < 0) newLastViewed = UM.lastViewed;
        }
        userRef.update({
          C.userMessages: FieldValue.arrayRemove([UM.asMap()])
        });
        return;
      }
    });
    if (newLastMessage != null) {
      userRef.update({
        C.userMessages: FieldValue.arrayUnion([
          {C.otherUserRef: otherUserRef, C.lastMessage: newLastMessage, C.lastViewed: newLastViewed}
        ])
      });
    }
  }

  Future<DocumentReference> newMessage({
    required DocumentReference senderRef,
    required DocumentReference receiverRef,
    required String text,
    required bool isMedia,
  }) async {
    final messageRef = await messagesCollection.add({
      C.senderRef: senderRef,
      C.receiverRef: receiverRef,
      C.text: text.trim(),
      C.isMedia: isMedia,
      C.createdAt: Timestamp.now(),
      C.numReports: 0
    });

    _updateUserMessages(userRef: senderRef, otherUserRef: receiverRef, lastMessage: Timestamp.now());
    _updateUserMessages(userRef: receiverRef, otherUserRef: senderRef, lastMessage: Timestamp.now());
    return messageRef;
  }

  Future updateLastViewed(DocumentReference userRef, DocumentReference otherUserRef) async {
    await _updateUserMessages(userRef: userRef, otherUserRef: otherUserRef, lastViewed: Timestamp.now());
  }

  Future deleteMessage({required DocumentReference messageRef, required DocumentReference currUserRef}) async {
    final message = await messageRef.get();
    final DocumentReference senderRef = message.get(C.senderRef);
    final DocumentReference receiverRef = message.get(C.receiverRef);
    if (currUserRef != senderRef && currUserRef != receiverRef) {
      return null;
    }
    await messageRef.delete();

    if (message.get(C.isMedia)) {
      return await _images.deleteImage(imageURL: message.get(C.text));
    }
  }

  // home data from snapshot
  Message? _messageFromDocument(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return messageFromQuerySnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Stream<List<Message?>> get messagesWithOtherPerson {
    Stream<List<Message?>> a = messagesCollection
        .where(C.senderRef, isEqualTo: currUserRef)
        .where(C.receiverRef, isEqualTo: otherUserRef!)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_messageFromDocument).toList());
    Stream<List<Message?>> b = messagesCollection
        .where(C.senderRef, isEqualTo: otherUserRef!)
        .where(C.receiverRef, isEqualTo: currUserRef)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_messageFromDocument).toList());
    return Rx.combineLatest2(a, b, (x, y) => (x as List<Message?>) + (y as List<Message?>));
    // return StreamGroup.merge([a, b]);
  }
}
