import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageStorage {

  ImageStorage();

  final Reference ref = FirebaseStorage.instance
      .ref()
      .child('images');

  Future<void> listExample() async {
    ListResult result = await ref.listAll();

    result.items.forEach((Reference ref) {
      print('Found file: $ref');
    });

    result.prefixes.forEach((Reference ref) {
      print('Found directory: $ref');
    });
  }
}