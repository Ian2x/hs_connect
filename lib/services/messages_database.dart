import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:async/async.dart' show StreamGroup;
import 'package:hs_connect/shared/constants.dart';
import 'package:rxdart/rxdart.dart';

class MessagesDatabaseService {
  final DocumentReference currUserRef;
  DocumentReference? otherUserRef;

  MessagesDatabaseService({required this.currUserRef, this.otherUserRef});

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
      C.numReports: 0
    });

    senderRef.update({
      C.userMessages: FieldValue.arrayUnion([{C.messageRef: messageRef, C.otherUserRef: receiverRef}])
    });
    receiverRef.update({
      C.userMessages: FieldValue.arrayUnion([{C.messageRef: messageRef, C.otherUserRef: senderRef}])
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
      C.userMessages: FieldValue.arrayRemove([{C.messageRef: messageRef, C.otherUserRef: receiverRef}])
    });
    final delReceiver = receiverRef.update({
      C.userMessages: FieldValue.arrayRemove([{C.messageRef: messageRef, C.otherUserRef: senderRef}])
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
    return Rx.combineLatest2(a,b, (x,y) => (x as List<Message?>) + (y as List<Message?>));
    return StreamGroup.merge([a, b]);
  }
}
