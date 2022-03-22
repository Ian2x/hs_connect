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
          otherUserFullDomain: widget.currUserData.fullDomainName ?? widget.currUserData.domain,
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Messages",
                  style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 7),
              Text("Visible to only you",
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.primary)),
            ],
          ),
        ),
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
                      if (index + 1 == _userPosts?.length) {
                        return Column(
                          children: [
                            ProfilePostCard(
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
                            Container(padding: EdgeInsets.only(left: 18, right: 18), child: Divider(height: 1, thickness: 1)),
                            SizedBox(height: 5)
                          ],
                        );
                      }
                      return ProfilePostCard(
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
                          });
                    },
                  ),
                ),
              )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width: MediaQuery.of(context).size.width, child: Divider(height: 1, thickness: 1)),
                SizedBox(height: 30),
                Text(
                  "You have no messages",
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              ],
            )
      ]),
    );
  }
}
