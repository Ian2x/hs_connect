import 'package:flutter/material.dart';

class GroupTag extends StatefulWidget {

  String groupName;

  GroupTag({Key ? key, required this.groupName}) : super(key: key);

  @override
  _GroupTagState createState() => _GroupTagState();
}

class _GroupTagState extends State<GroupTag> {
  @override
  Widget build(BuildContext context) {

    return ConstrainedBox(
      //TODO: NEED TO FIGURE OUT SIZING
      constraints: BoxConstraints(
        maxWidth: 110,
      ),
      child: Card(
        color: Color(0x867D7C7C),
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(18),
        ),
        //width:70,
        //padding: EdgeInsets.all(4),

        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Stack(
            children:[
                Row(
                children:[
                  CircleAvatar(
                    backgroundImage: AssetImage('Images/lville.jpg'),
                    radius: 11.0,
                  ),
                  SizedBox(width:10),
                  Text(
                    widget.groupName,
                    style:TextStyle(
                      fontSize:15,
                      color: Colors.white70,
                      fontFamily: 'Inter-Regular',
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
