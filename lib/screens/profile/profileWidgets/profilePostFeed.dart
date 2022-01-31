import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profilePostCard.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class ProfilePostFeed extends StatefulWidget {
  final DocumentReference profUserRef;

  ProfilePostFeed({Key? key, required this.profUserRef}) : super(key: key);

  @override
  _ProfilePostFeedState createState() => _ProfilePostFeedState();
}

class _ProfilePostFeedState extends State<ProfilePostFeed> {
  bool isReply = false;
  DocumentReference? commentRef;

  List<Post?>? _userPosts;

  @override
  void initState() {
    getUserPosts();
    super.initState();
  }

  void getUserPosts() async {
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.profUserRef);
    _userPosts = await _posts.getUserPosts();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: MediaQuery.of(context).size.width * .9,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(
          children: [
            SizedBox(width: 10 * wp),
            Text("Your Posts", style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.left),
          ],
        ),
        SizedBox(height: 10 * hp),
        Row(
          children: [
            SizedBox(width: 10 * wp),
            Text("Visible to only you", style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary), textAlign: TextAlign.left),
          ],
        ),
        SizedBox(height: 20 * hp),
        _userPosts!=null && _userPosts!.length!=0 ? Container(
          child: ListView.builder(
            itemCount: _userPosts?.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ProfilePostCard(
                    post: _userPosts![index]!,
                    currUserRef: widget.profUserRef,
                  ),
                  SizedBox(height: 10 * hp),
                ],
              );
            },
                ),
              )
            : Container(
                height: 70*hp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(
                    "You have no posts",
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                ]))
      ]),
    );
  }
}
