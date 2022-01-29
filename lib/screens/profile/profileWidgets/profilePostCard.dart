import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
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

    if (groupName==null) {
      return Container(
          height: 124*hp,
          padding: EdgeInsets.fromLTRB(10*wp,0,5*wp,10*hp),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16*hp),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3*hp,
                )),
          ),
          child: Loading(backgroundColor: Colors.transparent,)
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(10*wp,0,5*wp,10*hp),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16*hp),
            side: BorderSide(
              color: Theme.of(context).colorScheme.background,
              width: 3*hp,
            )),
      ),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              /*GroupTag(groupImageURL: groupImageString, groupColor: groupColor !=null ? HexColor(groupColor!): null,
                  groupName: groupName!, fontSize: 14*hp),*/
              Spacer(),
              IconButton(
                  icon: Icon(Icons.more_horiz_rounded, color: Theme.of(context).unselectedWidgetColor),
                  onPressed:(){}
              )
            ],
          ),
          SizedBox(height:10*hp),
          Text(widget.post.title, style: Theme.of(context).textTheme.headline6),
          SizedBox(height:10*hp),
          Row(
            children: [
              Text( (widget.post.numComments + widget.post.numReplies).toString() + " Comments",
                style: Theme.of(context).textTheme.bodyText2),
              Spacer(),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: (widget.post.likes.length - widget.post.dislikes.length).toString(),
                        style: Theme.of(context).textTheme.subtitle2),
                    TextSpan(text: " Likes ",
                        style: Theme.of(context).textTheme.bodyText2),
                  ],
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}



