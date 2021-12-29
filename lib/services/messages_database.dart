import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:async/async.dart' show StreamGroup;



class MessagesDatabaseService {
  final DocumentReference currUserRef;
  DocumentReference? otherPersonRef;

  MessagesDatabaseService({required this.currUserRef});

  // collection reference
  final CollectionReference messagesCollection = FirebaseFirestore.instance.collection('messages');

  ImageStorage _images = ImageStorage();

  Future<DocumentReference> newMessage({
    required DocumentReference senderRef,
    required DocumentReference receiverRef,
    required String text,
    required bool isMedia,
    required Timestamp createdAt,
  }) async {

    final messageRef = await messagesCollection
      .add({
      'sender': senderRef,
      'receiver': receiverRef,
      'text': text,
      'isMedia': isMedia,
      'createdAt': createdAt,
    });

    senderRef.update({'messages': FieldValue.arrayUnion([messageRef]) });
    receiverRef.update({'messages': FieldValue.arrayUnion([messageRef])});

    return messageRef;
  }

  Future deleteMessage({required DocumentReference messageRef, required DocumentReference currUserRef}) async {
    final message = await messageRef.get();
    final DocumentReference senderRef = message.get('senderRef');
    final DocumentReference receiverRef = message.get('receiverRef');
    if (currUserRef!=senderRef && currUserRef!=receiverRef) {
      print("Not allowed to delete arbitrary message");
      return null;
    }
    final delSender = senderRef.update({'messages': FieldValue.arrayRemove([messageRef])});
    final delReceiver = receiverRef.update({'messages': FieldValue.arrayRemove([messageRef])});
    final delMessage = messageRef.delete();


    await delSender;
    await delReceiver;
    await delMessage;

    if (message.get('isMedia')) {
      return await _images.deleteImage(imageURL: message.get('text'));
    }
  }

  // home data from snapshot
  Message? _messageFromDocument(QueryDocumentSnapshot document) {
    if (document.exists) {
      return Message(
        messageRef: document.reference,
        senderRef: document['senderRef'],
        receiverRef: document['receiverRef'],
        text: document['text'],
        isMedia: document['isMedia'],
        createdAt: document['createdAt'],
        reportedStatus: document['reportedStatus'],
      );
    } else {
      return null;
    }
  }

  Stream<List<Message?>> get messagesWithOtherPerson {
    Stream<List<Message?>> a = messagesCollection.where('senderRef', isEqualTo: currUserRef).where('receiverRef', isEqualTo: otherPersonRef!).snapshots().map((snapshot) => snapshot.docs.map(_messageFromDocument).toList());
    Stream<List<Message?>> b = messagesCollection.where('receiverRef', isEqualTo: currUserRef).where('senderRef', isEqualTo: otherPersonRef!).snapshots().map((snapshot) => snapshot.docs.map(_messageFromDocument).toList());
    return StreamGroup.merge([a,b]);
  }

}
