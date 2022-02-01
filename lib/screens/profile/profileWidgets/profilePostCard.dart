import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/buildCircle.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class ProfilePostCard extends StatefulWidget {
  final Post post;
  final DocumentReference currUserRef;

  ProfilePostCard({Key? key, required this.post, required this.currUserRef}) : super(key: key);

  @override
  _ProfilePostCardState createState() => _ProfilePostCardState();
}

class _ProfilePostCardState extends State<ProfilePostCard> {
  String? groupName;
  String? groupImageString;
  String? groupColor;
  Color? groupHex;
  Image? postImage;

  @override
  void initState() {
    getGroupData();
    super.initState();
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (fetchGroup != null && mounted) {
      setState(() {
        groupImageString = fetchGroup.image;
        groupName = fetchGroup.name;
        groupColor = fetchGroup.hexColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (groupName == null) {
      return Container(
          height: 124 * hp,
          padding: EdgeInsets.fromLTRB(10 * wp, 0, 5 * wp, 10 * hp),
          decoration: ShapeDecoration(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * hp),
                side: BorderSide(
                  color: colorScheme.background,
                  width: 3 * hp,
                )),
          ),
          child: Loading(
            backgroundColor: Colors.transparent,
          ));
    }

    return Container(
        padding: EdgeInsets.fromLTRB(10 * wp, 0, 5 * wp, 10 * hp),
        decoration: ShapeDecoration(
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16 * hp),
              side: BorderSide(
                color: colorScheme.background,
                width: 3 * hp,
              )),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(2*hp, 10*hp, 0, 0),
              child: Row(
                children: [
                  SizedBox(
                    height: 30*hp,
                    width: 30*hp,
                    child: buildGroupCircle(
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(image: ImageStorage().groupImageProvider(groupImageString))),
                        ),
                        all: 1.5,
                        backgroundColor: colorScheme.background),
                  ),
                  SizedBox(width: 5*wp),
                  groupName!=null ? Text(groupName!, style: Theme.of(context).textTheme.subtitle2) : Container()
                ],
              ),
            ),
            SizedBox(height: 10 * hp),
            Text(widget.post.title, style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10 * hp),
            Row(
              children: [
                Text((widget.post.numComments + widget.post.numReplies).toString() + " Comments",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: colorScheme.error)),
                Spacer(),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                          text: (widget.post.likes.length - widget.post.dislikes.length).toString(),
                          style: Theme.of(context).textTheme.subtitle2),
                      TextSpan(text: " Likes ", style: Theme.of(context).textTheme.bodyText2?.copyWith(color: colorScheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
