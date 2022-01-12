import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/shared/constants.dart';

class CommentNotificationCard extends StatelessWidget {
  final Comment comment;
  final Post? originPost;
  final Widget groupCircle;
  const CommentNotificationCard({Key? key, required this.comment, required this.originPost, required this.groupCircle}) : super(key: key);

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
                child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          groupCircle,
                          Flexible(child: Text(comment.text, style: ThemeText.regularSmall(), overflow: TextOverflow.ellipsis))
                        ],
                      )
                    ]
                )
            )
        )
    );
  }
}
