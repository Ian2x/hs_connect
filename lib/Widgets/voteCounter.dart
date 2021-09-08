
import 'package:flutter/material.dart';
import 'package:hs_connect/Tools/HexColor.dart';


class voteCounter extends StatefulWidget {


  bool liked=false;
  bool disliked=false;
  List<String> likes;
  List<String> dislikes;
  final String currUserId;
  final String postId;


  voteCounter(
      {Key? key,
        required this.postId,
        required this.liked,
        required this.disliked,
        required this.likes,
        required this.dislikes,
        required this.currUserId})
      : super(key: key);

  @override
  _voteCounterState createState() => _voteCounterState();
}

Color iconColor= Colors.white;




class _voteCounterState extends State<voteCounter> {

  int voteCount=0;


  @override
  Widget build(BuildContext context) {

    return Container(
        child:Row(
        children: <Widget> [
          IconButton(
            color: Colors.white,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: const Icon(Icons.arrow_upward_rounded, size: 13.0),
            tooltip: 'Like',
            onPressed: () {
              setState(() {
                voteCount +=1;
              });
            },
          ),
          Text('$voteCount',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
            )
          ),
          IconButton(
            color: Colors.white,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: const Icon(Icons.arrow_downward_rounded, size: 13.0),
            tooltip: 'Dislike',
            onPressed: () {
              setState(() {
                voteCount -=1;
              });
            },
          ),
        ]
      )
    );
  }
}
