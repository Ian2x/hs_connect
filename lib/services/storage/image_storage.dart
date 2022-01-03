import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageStorage {
  // initializer
  ImageStorage();

  final Reference imagesRef = FirebaseStorage.instance.ref().child('images');

  final Reference profilePicsRef = FirebaseStorage.instance.ref().child('profilePics');

  Future<void> listExample() async {
    ListResult result = await imagesRef.listAll();

    result.items.forEach((Reference ref) {
      print('Found file: $ref');
    });

    result.prefixes.forEach((Reference ref) {
      print('Found directory: $ref');
    });
  }

  Future getImage(String imageURL) async {
    // TODO:
  }

  Future uploadImage({required File file}) async {
    SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String>{
        'uploadedOn': DateTime.now().toString(),
      },
    );

    final snapshot = await imagesRef.child(Uuid().v4()).putFile(file, metadata).onError((error, stackTrace) {
      return Future.error(error!);
    });
    return await snapshot.ref.getDownloadURL();
  }

  Future deleteImage({required String imageURL}) async {
    final index = imageURL.indexOf("images%2F") + "images%2F".length;
    final imagePath = imageURL.substring(index, index + 36);
    await imagesRef.child(imagePath).delete();
  }

  Future uploadProfilePic({required File file, required String? oldImageURL}) async {
    SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String>{
        'uploadedOn': DateTime.now().toString(),
      },
    );

    // upload new profile Pic
    final snapshot = await profilePicsRef.child(Uuid().v4()).putFile(file, metadata).onError((error, stackTrace) {
      return Future.error(error!);
    });
    // delete old profilePic
    if (oldImageURL != null) {
      final index = oldImageURL.indexOf("profilePics%2F") + "profilePics%2F".length;
      final oldImagePath = oldImageURL.substring(index, index + 36);
      await profilePicsRef.child(oldImagePath).delete();
    }

    return await snapshot.ref.getDownloadURL();
  }
}
