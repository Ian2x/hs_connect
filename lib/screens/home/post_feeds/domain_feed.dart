import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_view/post_card.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/posts_list_view.dart';
import 'package:provider/provider.dart';

class DomainFeed extends StatefulWidget {
  const DomainFeed({Key? key}) : super(key: key);

  @override
  _DomainFeedState createState() => _DomainFeedState();
}

class _DomainFeedState extends State<DomainFeed> {
  String groupId = '';

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    PostsDatabaseService _posts = PostsDatabaseService(groupRefs: [userData.userGroups[0].groupRef]);

    return StreamBuilder(
      stream: _posts.posts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {
          final List<Post> posts = (snapshot.data as List<Post?>).map((post) => post!).toList();

          return PostsListView(posts: posts, currUserRef: userData.userRef);
        }
      },
    );
  }
}
