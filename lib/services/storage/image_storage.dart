import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:uuid/uuid.dart';

class ImageStorage {
  // initializer
  ImageStorage();

  static final Reference imagesRef = FirebaseStorage.instance.ref().child(C.images);
  static final Reference profilePicsRef = FirebaseStorage.instance.ref().child(C.profilePics);

  static final defaultCacheManager = DefaultCacheManager();

  /*Future<void> listExample() async {
    ListResult result = await imagesRef.listAll();

    result.items.forEach((Reference ref) {
      print('Found file: $ref');
    });

    result.prefixes.forEach((Reference ref) {
      print('Found directory: $ref');
    });
  }*/

  /*CachedNetworkImage getCachedImage(String imageURL, {double? width, double? height, BoxFit? fit}) {
    return CachedNetworkImage(
        imageUrl: imageURL,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
        width: width,
        height: height,
        fit: fit);
  }*/

  ImageProvider groupImageProvider(String? imageURL) {
    if (imageURL != null) {
      return CachedNetworkImageProvider(imageURL);
    } else {
      return defaultGroupPic;
    }
  }

  /*CachedNetworkImageProvider getCachedImageProvider(String imageURL) {
    return CachedNetworkImageProvider(imageURL);
  }*/

  Future uploadImage({required File file}) async {
    SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String>{
        'uploadedOn': DateTime.now().toString(),
      },
    );

    final snapshot = await imagesRef.child(Uuid().v4()).putFile(file, metadata).onError((error, stackTrace) {
      return Future.error(error!);
    });
    final downloadURL = await snapshot.ref.getDownloadURL();
    // store into cache
    defaultCacheManager.putFile(downloadURL, await file.readAsBytes(), fileExtension: 'jpeg');
    return downloadURL;
  }

  Future deleteImage({required String imageURL}) async {
    return Future.wait(
        [defaultCacheManager.removeFile(imageURL), FirebaseStorage.instance.refFromURL(imageURL).delete()]);
  }

  /*Future uploadProfilePic({required File file, required String? oldImageURL}) async {
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
      deleteImage(imageURL: oldImageURL);
    }
    final downloadURL = await snapshot.ref.getDownloadURL();
    // store into cache
    defaultCacheManager.putFile(downloadURL, await file.readAsBytes(), fileExtension: 'jpeg');
    return downloadURL;
  }*/
}
