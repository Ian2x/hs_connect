import 'package:flutter/rendering.dart';

import '../Objects/Group.dart';
import 'package:flutter/material.dart';


class GroupTile extends StatefulWidget {

  Group groupInfo;

  GroupTile({Key ? key, required this.groupInfo}) : super(key: key);

  @override
  _GroupTileState createState() => _GroupTileState();
}
//----------------------------------------------------------
class _GroupTileState extends State<GroupTile> {
  @override

  bool isPublic=true;

  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.black12,


      child:Stack(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:[Colors.indigo,Colors.black ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                )
            ),
            child: Column(
                children:[

                ]

            ),
          ),

        ],
      )
    );
  }
}
