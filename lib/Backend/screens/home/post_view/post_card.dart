import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/models/post.dart';
import 'package:hs_connect/Backend/models/user_data.dart';
import 'package:hs_connect/Backend/models/group.dart';
import 'package:hs_connect/Backend/screens/home/post_view/delete_post.dart';
import 'package:hs_connect/Backend/screens/home/post_view/post_page.dart';
import 'package:hs_connect/Backend/services/posts_database.dart';
import 'package:hs_connect/Backend/services/userInfo_database.dart';
import 'package:hs_connect/Backend/services/groups_database.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String userId;
  final String groupId;
  final String title;
  final String text;
  final String? image;
  final String createdAt;
  List<String> likes;
  List<String> dislikes;
  final String currUserId;

  PostCard(
      {Key? key,
      required this.postId,
      required this.userId,
      required this.groupId,
      required this.title,
      required this.text,
      required this.image,
      required this.createdAt,
      required this.likes,
      required this.dislikes,
      required this.currUserId})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  UserInfoDatabaseService _userInfoDatabaseService = UserInfoDatabaseService();
  GroupsDatabaseService _GroupsDatabaseService = GroupsDatabaseService();

  PostsDatabaseService _posts = PostsDatabaseService();

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';
  String groupName = '<Loading user name...>';


  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserId)) {
      setState(() {
        liked = true;
      });
    } else if (widget.dislikes.contains(widget.currUserId)) {
      setState(() {
        disliked = true;
      });
    }
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUsername();
    super.initState();
  }

  void getUsername() async {
    final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userId: widget.userId);
    setState(() {
      username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
    });
  }

  void getGroupName() async {
    final Group? fetchGroupName = await _GroupsDatabaseService.group(groupId: widget.groupId);
    setState(() {
      groupName = fetchGroupName != null ? fetchGroupName.name : '<Failed to retrieve user name>';
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostPage(
                  postInfo: Post(
                    postId: widget.postId,
                    userId: widget.userId,
                    groupId: widget.groupId,
                    title: widget.title,
                    text: widget.text,
                    image: widget.image,
                    createdAt: widget.createdAt,
                    likes: widget.likes,
                    dislikes: widget.dislikes,
                  ))),
        );
      },

      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          margin: EdgeInsets.fromLTRB(0.0,0.0,0.0, 5.0),
          color: Colors.white,
          elevation: 0.3,
          child: Container(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 3.0),
                  child: Column(
                      children: <Widget>[
                        //COMMUNITY ROW
                        Row(
                            children: <Widget>[
                              Icon(Icons.account_circle),
                              SizedBox(width:10),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget> [
                                    Text(
                                      groupName,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.black,
                                        fontFamily: 'Poppins-Regular',
                                      ),
                                    ),
                                    Text(
                                      username,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.grey,
                                        fontFamily: 'Poppins-Regular',
                                      ),
                                    ),
                                  ]
                              )
                            ]
                        ),

                        SizedBox(height: 5.0),

                        //TEXT ROW
                        Row(
                            children: <Widget>[
                              Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black,
                                  )
                              )
                            ]
                        ),

                        //SizedBox(height: 3.0),

                        //TEXT ROW
                        Row(
                            children: <Widget>[
                              Expanded (
                                  child: Text(
                                      widget.text,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.grey,
                                      )
                                  )
                              )

                            ]
                        ),

                        SizedBox(height: 2.0),

                        //ICON ROW
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: const Icon(Icons.share, size: 13.0),
                                tooltip: 'Share post',
                                onPressed: () {
                                  setState(() {
                                    //TODO: Go to new Screen
                                  });
                                },
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: const Icon(Icons.comment, size: 13.0),
                                tooltip: 'Share post',
                                onPressed: () {
                                  setState(() {
                                    //TODO: Go to new Screen
                                  });
                                },
                              ),
                              //voteCounter(),
                            ]
                        ),
                      ]
                  )
              )
          )
      ),
    );
  }
}


//Original Card Code
/*
return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Dismissible(
        key: ValueKey(widget.postId),
        child: ListTile(
          title: Text(widget.title),
          subtitle: Text(username),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPage(
                          postInfo: Post(
                        postId: widget.postId,
                        userId: widget.userId,
                        groupId: widget.groupId,
                        title: widget.title,
                        text: widget.text,
                        image: widget.image,
                        createdAt: widget.createdAt,
                        likes: widget.likes,
                        dislikes: widget.dislikes,
                      ))),
            );
          },
          trailing: DeletePost(postUserId: widget.userId, postId: widget.postId, currUserId: widget.currUserId),
        ),
        // CAN DELETE POST EITHER VIA DELETE POST BUTTON OR DISMISSAL, PROBABLY CHOOSE ONE OR THE OTHER EVENTUALLY
        onDismissed: (DismissDirection direction) async {
          /*
          setState(() async {
            await _posts.deletePost(postId: widget.postId, userId: widget.currUserId);
          });
           */
          await _posts.deletePost(postId: widget.postId, userId: widget.currUserId);
        },
      )
    ]));
 */