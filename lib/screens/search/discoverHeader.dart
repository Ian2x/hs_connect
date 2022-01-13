import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myCircle.dart';

class DiscoverHeader extends StatefulWidget {
  final Group group;
  final bool joined;
  final DocumentReference currUserRef;

  const DiscoverHeader({Key? key, required this.group, required this.joined, required this.currUserRef})
      : super(key: key);

  @override
  _DiscoverHeaderState createState() => _DiscoverHeaderState();
}

class _DiscoverHeaderState extends State<DiscoverHeader> {
  Widget localContent = Loading(size: 20.0);

  @override
  void initState() {
    if (widget.group.image == null) {
      String s = widget.group.name;
      int sLen = s.length;
      String initial = "?";
      for (int j = 0; j < sLen; j++) {
        if (RegExp(r'[a-z]').hasMatch(widget.group.name[j].toLowerCase())) {
          initial = widget.group.name[j].toUpperCase();
          break;
        }
      }
      if (mounted) {
        setState(() {
          localContent = Text(initial, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
        });
      }
    } else {
      var tempImage = Image.network(widget.group.image!);
      tempImage.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
        if (mounted) {
          setState(() => localContent = tempImage);
        }
      }));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserDataDatabaseService _userData = new UserDataDatabaseService(currUserRef: widget.currUserRef);

    return Container(
        padding: EdgeInsets.all(10.0),
        child: Row(children: <Widget>[
          Circle(child: localContent, textBackgroundColor: translucentColorFromString(widget.group.name), size: 40.0),
          SizedBox(width: 10.0),
          Text(
            widget.group.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          ),
          Spacer(),
          widget.joined
              ? Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  color: ThemeColor.secondaryBlue,
                  child: Container(
                      padding: EdgeInsets.all(5.0), child: Text("Joined", style: TextStyle(color: Colors.white))))
              : GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      color: ThemeColor.secondaryBlue,
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.add, color: Colors.white, size: 12.0),
                            Text("Join", style: TextStyle(color: Colors.white))
                          ],
                        ),
                      )),
                  onTap: () => _userData.joinGroup(groupRef: widget.group.groupRef, public: true))
        ]));
  }
}
