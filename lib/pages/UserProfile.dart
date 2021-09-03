

import 'package:flutter/cupertino.dart';
import '../Widgets/GroupTag.dart';
import '../Objects/Group.dart';
import '../Widgets/GroupTile.dart';
import 'package:flutter/material.dart';
import '../Widgets/OGnavbar.dart';


class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  List<Group> groupList=[

    Group('image', 'Lville','Lawrenceville,NJ'),
    Group('image', 'Lville','Lawrenceville,NJ'),


  ];

  Color colorTheme= Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: colorTheme,
        child: Column(
          //Top BAR
          children: [
            Container(
            width: double.infinity,
            height: 350,
            padding: EdgeInsets.fromLTRB(10.0, 80.0,10.0, 5.0),

            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:[Colors.black54,Colors.lightBlueAccent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              ),
            ),


              child: Column(
                children: [
                  CircleAvatar(
                        backgroundImage: AssetImage('Images/me.png'),
                        //TODO: Need to Set Default Image
                        radius: 55.0,
                  ),

                  SizedBox(height:15.0),
                  Text(
                      'eric.w.zhu',
                      style: TextStyle(
                        fontSize:23,
                        color: Colors.white,
                        fontFamily: 'Inter-Regular',
                        fontWeight: FontWeight.bold,
                        )
                  ),
                  SizedBox(height:15.0),
                  //GROUPTAG ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GroupTag(groupName:'Lville'), //Probably will only have one main group
                    ],
                  ),
                  /*
                  SizedBox(height:15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Text(
                          'Likes: 1',
                          style: TextStyle(
                            fontSize:14,
                            color: Colors.white60,
                            fontFamily: 'Inter-Regular',
                          )
                        ),
                      ],
                    ),
                   */
                ],
              ),

          ),

           //BOTTOM HALF----------------------------------------------------------
             Container(
               //Takes COLOR OF PARENT CONTAINER

               padding: EdgeInsets.all(15.0),
               child: Column(
                 crossAxisAlignment:CrossAxisAlignment.start,
                 children: [
                   Text('Groups',
                     style:TextStyle(
                     fontSize:20,
                       color: Colors.white,
                       fontFamily: 'Inter-Medium',
                       fontWeight:FontWeight.bold,
                     )
                   ),
                   GridView.count(
                     crossAxisCount: 2,
                     physics: ScrollPhysics(),
                     shrinkWrap:true,
                     scrollDirection: Axis.vertical,
                     children: groupList.map((input) => GroupTile(groupInfo: input)).toList(),
                   ),
                 ],
               ),
             )
          ], //Column Children
        ),
      ),

    bottomNavigationBar:OGnavbar(),

    );
  }
}

