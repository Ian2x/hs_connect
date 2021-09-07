import 'package:flutter/material.dart';
import '../Objects/Group.dart';

class GroupTile extends StatefulWidget {

  Group groupInfo;

  GroupTile({Key ? key, required this.groupInfo}) : super(key: key);

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(10.0),
      height: 70,

      child: Card(
        color: Color(0x867D7C7C),
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(4),
        ),
        //width:70,
        //padding: EdgeInsets.all(4),

        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Stack(
              children:[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      CircleAvatar(
                        backgroundImage: AssetImage('Images/lville.jpg'),
                        radius: 50.0,
                      ),
                      SizedBox(width:10),
                      Text(
                          widget.groupInfo.GroupName,
                          style:TextStyle(
                            fontSize:15,
                            color: Colors.white70,
                            fontFamily: 'Segoe UI',
                            fontWeight:FontWeight.bold,
                          )
                      ),
                    ]
                ),
              ]
          ),
        ),
      ),
    );
  }
}

