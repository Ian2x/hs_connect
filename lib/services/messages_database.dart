import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:async/async.dart' show StreamGroup;
import 'package:hs_connect/shared/constants.dart';

class MessagesDatabaseService {
  final DocumentReference currUserRef;
  DocumentReference? otherPersonRef;

  MessagesDatabaseService({required this.currUserRef});

  // collection reference
  final CollectionReference messagesCollection = FirebaseFirestore.instance.collection(C.messages);

  ImageStorage _images = ImageStorage();

  Future<DocumentReference> newMessage({
    required DocumentReference senderRef,
    required DocumentReference receiverRef,
    required String text,
    required bool isMedia,
    required Timestamp createdAt,
  }) async {
    final messageRef = await messagesCollection.add({
      C.senderRef: senderRef,
      C.receiverRef: receiverRef,
      C.text: text,
      C.isMedia: isMedia,
      C.createdAt: createdAt,
    });

    senderRef.update({
      C.messagesRefs: FieldValue.arrayUnion([messageRef])
    });
    receiverRef.update({
      C.messagesRefs: FieldValue.arrayUnion([messageRef])
    });

    return messageRef;
  }

  Future deleteMessage({required DocumentReference messageRef, required DocumentReference currUserRef}) async {
    final message = await messageRef.get();
    final DocumentReference senderRef = message.get(C.senderRef);
    final DocumentReference receiverRef = message.get(C.receiverRef);
    if (currUserRef != senderRef && currUserRef != receiverRef) {
      print("Not allowed to delete arbitrary message");
      return null;
    }
    final delSender = senderRef.update({
      C.messagesRefs: FieldValue.arrayRemove([messageRef])
    });
    final delReceiver = receiverRef.update({
      C.messagesRefs: FieldValue.arrayRemove([messageRef])
    });
    final delMessage = messageRef.delete();

    await delSender;
    await delReceiver;
    await delMessage;

    if (message.get(C.isMedia)) {
      return await _images.deleteImage(imageURL: message.get(C.text));
    }
  }

  // home data from snapshot
  Message? _messageFromDocument(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return Message.fromQuerySnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Stream<List<Message?>> get messagesWithOtherPerson {
    Stream<List<Message?>> a = messagesCollection
        .where(C.senderRef, isEqualTo: currUserRef)
        .where(C.receiverRef, isEqualTo: otherPersonRef!)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_messageFromDocument).toList());
    Stream<List<Message?>> b = messagesCollection
        .where(C.receiverRef, isEqualTo: currUserRef)
        .where(C.senderRef, isEqualTo: otherPersonRef!)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_messageFromDocument).toList());
    return StreamGroup.merge([a, b]);
  }
}
