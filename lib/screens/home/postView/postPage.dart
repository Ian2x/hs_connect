import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/comments/commentsFeed.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:hs_connect/shared/widgets/myDivider.dart';
import 'package:provider/provider.dart';

class PostPage extends StatelessWidget {
  final Post post;
  final Group group;
  final UserData creatorData;
  final PostLikesManager postLikesManager;

  PostPage({Key? key, required this.post, required this.group, required this.creatorData, required this.postLikesManager
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(group.name),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: myBackButtonIcon(context),
        bottom: MyDivider()
      ),
      body:
          Container(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Provider<PostLikesManager>.value(
              value: postLikesManager,
              child: CommentsFeed(post: post, group: group),
            )
          )
    );
  }
}
