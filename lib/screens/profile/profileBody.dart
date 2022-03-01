import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profilePostCard.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileTitle.dart';
import 'package:hs_connect/services/posts_database.dart';

class ProfileBody extends StatefulWidget {
  final UserData currUserData;

  ProfileBody({Key? key, required this.currUserData}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  List<Post>? _userPosts;

  @override
  void initState() {
    getUserPosts();
    super.initState();
  }

  void getUserPosts() async {
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserData.userRef);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
        ProfileTitle(
          showMoreHoriz: false,
          otherUserRef: widget.currUserData.userRef,
          otherUserFundName: widget.currUserData.fundamentalName,
          otherUserScore: widget.currUserData.score,
          otherUserDomainColor: widget.currUserData.domainColor,
          otherUserFullDomain: widget.currUserData.fullDomainName,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: 30),
              Row(
                children: [
                  SizedBox(width: 5),
                  Text("Your Posts",
                      style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 22), textAlign: TextAlign.left),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 5),
                  Text("Visible to only you",
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary),
                      textAlign: TextAlign.left),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Divider(color: colorScheme.background, thickness: 3, height: 0),
        SizedBox(height: 15),
        _userPosts != null && _userPosts!.length != 0
            ? Expanded(
                child: RefreshIndicator(
                  onRefresh: () => Future.sync(
                    () => getUserPosts(),
                  ),
                  child: ListView.builder(
                    itemCount: _userPosts?.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                        child: ProfilePostCard(
                            post: _userPosts![index],
                            currUserRef: widget.currUserData.userRef,
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
                height: 90,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "You have no posts \n Only you can see these",
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                ]))
      ]),
    );
  }
}
