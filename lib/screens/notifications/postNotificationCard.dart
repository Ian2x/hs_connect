import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/shared/constants.dart';

class PostNotificationCard extends StatelessWidget {
  final Post post;
  final Widget groupCircle;

  const PostNotificationCard({Key? key, required this.post, required this.groupCircle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10.0)),
        margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
        elevation: 0.0,
        color: ThemeColor.white,
        child: Container(

        )
      )
    );
  }
}
