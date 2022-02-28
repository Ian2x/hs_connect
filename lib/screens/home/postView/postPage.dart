import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/screens/home/comments/commentsFeed.dart';
import 'package:hs_connect/shared/widgets/buildGroupCircle.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:hs_connect/shared/widgets/myDivider.dart';
import 'package:provider/provider.dart';

class PostPage extends StatelessWidget {
  final Post post;
  final Group group;
  final PostLikesManager postLikesManager;

  PostPage({Key? key, required this.post, required this.group, required this.postLikesManager
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildGroupCircle(groupImage: group.image, size: 27, context: context, backgroundColor: colorScheme.surface),
            SizedBox(width: 8),
            Flexible(child: Text(group.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
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
        ),
    );
  }
}
