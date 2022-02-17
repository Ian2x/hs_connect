import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profilePostCard.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileTitle.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class ProfileBody extends StatefulWidget {
  final UserData profileUserData;

  ProfileBody({Key? key, required this.profileUserData}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool isReply = false;
  DocumentReference? commentRef;

  bool test = false;

  List<Post>? _userPosts;

  @override
  void initState() {
    getUserPosts();
    super.initState();
  }

  void getUserPosts() async {
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.profileUserData.userRef);
    List<Post?> tempPosts = await _posts.getUserPosts();
    tempPosts.removeWhere((value) => value == null);
    List<Post> tempTempPosts = tempPosts.map((item) => item!).toList();
    tempTempPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) {
      setState(() => _userPosts = tempTempPosts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
        ProfileTitle(
          otherUserFundName: widget.profileUserData.fundamentalName,
          otherUserScore: widget.profileUserData.score,
          otherUserDomainColor: widget.profileUserData.domainColor,
          otherUserFullDomain: widget.profileUserData.fullDomainName,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15 * wp),
          child: Column(
            children: [
              SizedBox(height: 30 * hp),
              Row(
                children: [
                  SizedBox(width: 5 * wp),
                  Text("Your Posts",
                      style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 22), textAlign: TextAlign.left),
                ],
              ),
              SizedBox(height: 10 * hp),
              Row(
                children: [
                  SizedBox(width: 5 * wp),
                  Text("Visible to only you",
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary),
                      textAlign: TextAlign.left),
                ],
              ),
              SizedBox(height: 15 * hp),
              Divider(color: colorScheme.background, thickness: 3 * hp, height: 0),
              SizedBox(height: 15 * hp),
            ],
          ),
        ),
        _userPosts != null && _userPosts!.length != 0
            ? Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      Future.sync(
                            () => getUserPosts(),
                      ),
                  child: ListView.builder(
                    itemCount: _userPosts?.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(15 * wp, 0, 15 * wp, 10 * hp),
                        child: ProfilePostCard(
                            post: _userPosts![index],
                            currUserData: widget.profileUserData,
                            onDelete: () {
                              if (mounted) {
                                setState(() {
                                  List<Post> copy = new List<Post>.from(_userPosts!);
                                  copy.removeAt(index);
                                  _userPosts = copy;
                                });
                              }
                            }),
                      );
                    },
                  ),
                ),
              )
            : Container(
                height: 90 * hp,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "You have no posts",
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                ]))
      ]),
    );
  }
}
