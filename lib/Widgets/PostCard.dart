import '../Objects/UserPost.dart';
import 'voteCounter.dart';
import 'package:flutter/material.dart';



class PostCard extends StatefulWidget {

  UserPost userPost;

  PostCard({Key ? key, required this.userPost}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  int voteCount=0;
  int commentCount=0;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                                      widget.userPost.community,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.black,
                                        fontFamily: 'Poppins-Regular',
                                      ),
                                    ),
                                    Text(
                                      widget.userPost.user,
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
                                        widget.userPost.header,
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
                                        widget.userPost.text,
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
                                voteCounter(),
                              ]
                          ),
                        ]
                    )
                )
        )
      );
    }

}
