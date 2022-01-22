import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';


class ProfilePostCard extends StatefulWidget {

  final Post post;
  final DocumentReference currUserRef;

  ProfilePostCard({Key? key, required this.post, required this.currUserRef}) : super(key: key);

  @override
  _ProfilePostCardState createState() => _ProfilePostCardState();
}

class _ProfilePostCardState extends State<ProfilePostCard> {

  String groupName = '';
  String? groupImageString;
  Image? groupImage;
  String? groupColor;
  Color? groupHex;
  Image? postImage;



  @override
  void initState() {
    // TODO: implement initState
    getGroupData();
    super.initState();
  }
  void getGroupData() async {

    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (mounted) {
      setState(() {
        if (fetchGroup!=null) {
          groupImageString = fetchGroup.image;
          groupName = fetchGroup.name;
          groupColor = fetchGroup.hexColor;
          if (groupImageString != null && groupImageString!="") {
            var tempImage = Image.network(groupImageString!);
            tempImage.image
                .resolve(ImageConfiguration())
                .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
              if (mounted) {
                setState(() => groupImage = tempImage);
              }
            }));
          }
        } else {
          groupName = '<Failed to retrieve group name>';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getGroupData();
    return Container(
      padding: const EdgeInsets.fromLTRB(10,0,5,10),
      decoration: ShapeDecoration(
        color: ThemeColor.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: ThemeColor.backgroundGrey,
              width: 3.0,
            )),
      ),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GroupTag(groupImage: groupImage, groupColor: groupColor !=null ? HexColor(groupColor!): null,
                  groupName: groupName, fontSize: 14),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.more_horiz_rounded, color: ThemeColor.mediumGrey),
                  onPressed:(){}
              )
            ],
          ),
          SizedBox(height:10),
          Text(widget.post.title, style: ThemeText.postViewTitle( fontSize: 18)),
          SizedBox(height:10),
          Row(
            children: [
              Text( (widget.post.numComments + widget.post.numReplies).toString() + " Comments",
                style: ThemeText.regularSmall( fontSize: 14),
              ),
              Spacer(),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: (widget.post.likes.length - widget.post.dislikes.length).toString(),
                        style: ThemeText.groupBold(color: ThemeColor.black, fontSize: 14 )),
                    TextSpan(text: " Likes ",
                        style: ThemeText.regularSmall(color: ThemeColor.darkGrey, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



