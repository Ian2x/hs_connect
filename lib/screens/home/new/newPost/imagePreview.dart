import "package:flutter/material.dart";
import 'dart:io';



class imagePreview extends StatelessWidget {

  File? fileImage;

  imagePreview({Key? key, required this.fileImage, Function? callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height:150,
      child: fileImage != null
          ? Semantics(
              label: 'new_profile_pic_picked_image',
              child: Image.file(File(fileImage!.path)),
            )
          : Container(),

      //child: fileImage,
    );
  }
}


