import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/comments/commentCard.dart';
import 'package:hs_connect/screens/home/comments/commentReplyForm.dart';
import 'package:hs_connect/screens/home/postView/postTitleCard.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReplyToNotifier extends ChangeNotifier {
  int? commentIndex;

  void setIndex(int? newIndex) {
    commentIndex = newIndex;
    notifyListeners();
  }
}

class CommentsFeed extends StatefulWidget {
  final Post post;
  final Group group;

  CommentsFeed({Key? key, required this.post, required this.group}) : super(key: key);

  @override
  _CommentsFeedState createState() => _CommentsFeedState();
}

class _CommentsFeedState extends State<CommentsFeed> {
  bool isReply = false;
  Comment? comment;

  late FocusNode myFocusNode;
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;

    switchFormBool(Comment? passedComment) {
      if (mounted) {
        setState(() {
          isReply = !isReply;
          comment = passedComment;
        });
      }
    }

    if (userData == null) return Loading();
    CommentsDatabaseService _comments =
        CommentsDatabaseService(currUserRef: userData.userRef, postRef: widget.post.postRef);

    Color? groupColor = widget.group.hexColor != null ? HexColor(widget.group.hexColor!) : null;
    final windowInsets = WidgetsBinding.instance?.window.viewInsets.bottom;
    final devicePixelRatio = WidgetsBinding.instance?.window.devicePixelRatio;
    double keyboardHeight = 0;
    if (windowInsets != null && devicePixelRatio != null) {
      keyboardHeight = windowInsets / devicePixelRatio;
    }

    return ChangeNotifierProvider(
      create: (context) => ReplyToNotifier(),
      child: Consumer<ReplyToNotifier>(
        builder: (context, replyToNotifier, _) => Stack(
          children: [
            StreamBuilder(
              stream: _comments.postComments,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Loading();
                } else {
                  List<Comment?> commentss = (snapshot.data as List<Comment?>);
                  commentss.removeWhere((value) => value == null);
                  List<Comment> comments = commentss.map((item) => item!).toList();
                  // sort by most recent
                  comments.sort((a, b) {
                    return a.createdAt.compareTo(b.createdAt);
                  });
                  return GestureDetector(
                      onVerticalDragDown: (DragDownDetails ddd) {
                        dismissKeyboard(context);
                        replyToNotifier.setIndex(null);
                        setState(() {
                          isReply = false;
                          comment = null;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx > 15) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        alignment: Alignment.topCenter,
                        child: ScrollablePositionedList.builder(
                          itemCount: comments.length + 3,
                          itemScrollController: itemScrollController,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return PostTitleCard(
                                post: widget.post,
                                group: widget.group,
                                currUserData: userData,
                              );
                            } else if (index == 1) {
                              return Divider(thickness: 1, height: 1);
                            } else if (index == comments.length + 2) {
                              return Container(height: 85 + keyboardHeight + MediaQuery.of(context).padding.bottom);
                            } else {
                              if (userData.blockedUserRefs.contains(comments[index - 2].creatorRef)) {
                                return Container();
                              }
                              return CommentCard(
                                focusKeyboard: () async {
                                  replyToNotifier.setIndex(index);
                                  myFocusNode.requestFocus();
                                  await Future.delayed(const Duration(milliseconds: 125), () {});
                                  itemScrollController.scrollTo(index: index, duration: Duration(milliseconds: 250));
                                },
                                switchFormBool: switchFormBool,
                                comment: comments[index - 2],
                                currUserData: userData,
                                postCreatorRef: widget.post.creatorRef,
                                groupColor: groupColor,
                                index: index
                              );
                            }
                          },
                        ),
                      ),
                    );

                }
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.background,
                        offset: Offset(0.0, -1.0), //(x,y)
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(
                      10, 10, 10, MediaQuery.of(context).padding.bottom > 10 ? MediaQuery.of(context).padding.bottom : 10),
                  child: CommentReplyForm(
                      focusNode: myFocusNode,
                      currUserRef: userData.userRef,
                      switchFormBool: switchFormBool,
                      comment: comment,
                      isReply: isReply,
                      post: widget.post,
                      onSubmit: () {                      replyToNotifier.setIndex(null);
                      })),
            ),
          ],
        ),
      ),
    );
  }
}
