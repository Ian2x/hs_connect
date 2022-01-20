import 'dart:io';

import 'package:hs_connect/shared/inputDecorations.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hs_connect/shared/constants.dart';


class postBar extends StatefulWidget {

  voidFileParamFunction addImage;
  voidFunction addPoll;

  postBar({Key? key,
  required this.addImage,
  required this.addPoll,
  }) : super(key: key);

  @override
  _postBarState createState() => _postBarState();
}

class _postBarState extends State<postBar> {

  bool photoPressed=false;
  bool pollPressed= false;

  String? newFileURL;
  File? newFile;

  @override
  Widget build(BuildContext context) {


    return Positioned(
        bottom:0,
        left:0,
        child:
        Row(
          children: [
            IconButton(onPressed: () async {
              try {
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  maxHeight: 400,
                  maxWidth: 400,
                  imageQuality: 100,
                );
                if (pickedFile != null) {
                  if (mounted) {
                    setState(() {
                      newFile = File(pickedFile.path);
                    });
                  }
                } else {
                  if (mounted) {
                    setState(() {
                      newFile = null;
                    });
                  }
                }
                if (mounted) {
                  widget.addImage(newFile);    //!! Calls the callback function
                  setState(() {
                    photoPressed=true;
                  });
                }
              } catch (e) {
                print(e);
              }
            },
                icon: Icon(Icons.photo, size:25, color: photoPressed != false ? ThemeColor.secondaryBlue : ThemeColor.mediumGrey)),
            SizedBox(width:30),
            IconButton(onPressed: (){
              widget.addPoll();
              setState(() {
                pollPressed=true;
              });
            },
                icon: Icon(Icons.assessment, size: 25,color: pollPressed!= false ? ThemeColor.secondaryBlue : ThemeColor.mediumGrey))
          ],
        )
    );
  }
}


