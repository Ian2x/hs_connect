import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:uuid/uuid.dart';


/*
Future<String> cacheImage(String imagePath) async {
    final Reference ref = _storage.ref().child(imagePath);

    // Get your image url
    final imageUrl = await ref.getDownloadURL();

    // Check if the image file is not in the cache
    if ((await defaultCacheManager.getFileFromCache(imageUrl))?.file == null) {
      // Download your image data
      final imageBytes = await ref.getData(10000000);

      // Put the image file in the cache
      await defaultCacheManager.putFile(
        imageUrl,
        imageBytes,
        fileExtension: "jpg",
      );
    }

    // Return image download url
    return imageUrl;
  }
 */
class ImageStorage {
  // initializer
  ImageStorage();

  final Reference imagesRef = FirebaseStorage.instance.ref().child(C.images);
  final Reference profilePicsRef = FirebaseStorage.instance.ref().child(C.profilePics);

  final defaultCacheManager = DefaultCacheManager();

  Future<void> listExample() async {
    ListResult result = await imagesRef.listAll();

    result.items.forEach((Reference ref) {
      print('Found file: $ref');
    });

    result.prefixes.forEach((Reference ref) {
      print('Found directory: $ref');
    });
  }

  CachedNetworkImage getCachedImage(String imageURL, {double? width, double? height, BoxFit? fit}) {
    return CachedNetworkImage(
      imageUrl: imageURL,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      width: width,
      height: height,
      fit: fit
    );
  }

  ImageProvider profileImageProvider(String? imageURL) {
    if (imageURL != null) {
      return CachedNetworkImageProvider(imageURL);
    } else {
      return defaultProfilePic;
    }
  }

  ImageProvider groupImageProvider(String? imageURL) {
    if (imageURL != null) {
      return CachedNetworkImageProvider(imageURL);
    } else {
      return defaultProfilePic;
    }
  }

  CachedNetworkImageProvider getCachedImageProvider(String imageURL) {
    return CachedNetworkImageProvider(imageURL);
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
    final downloadURL = await snapshot.ref.getDownloadURL();
    // store into cache
    defaultCacheManager.putFile(downloadURL, await file.readAsBytes(), fileExtension: 'jpeg');
    return downloadURL;
  }

  Future deleteImage({required String imageURL}) async {
    defaultCacheManager.removeFile(imageURL); // remove from cache
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
      defaultCacheManager.removeFile(oldImageURL); // remove from cache
      final index = oldImageURL.indexOf("profilePics%2F") + "profilePics%2F".length;
      final oldImagePath = oldImageURL.substring(index, index + 36);
      await profilePicsRef.child(oldImagePath).delete();
    }
    final downloadURL = await snapshot.ref.getDownloadURL();
    // store into cache
    defaultCacheManager.putFile(downloadURL, await file.readAsBytes(), fileExtension: 'jpeg');
    return downloadURL;
  }
}
