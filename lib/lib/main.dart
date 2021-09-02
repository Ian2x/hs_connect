
import 'package:flutter/material.dart';
import 'package:topic_chatt/Objects/Group.dart';
import 'package:topic_chatt/pages/Loading.dart';
import 'package:topic_chatt/pages/UserProfile.dart';
import 'Objects/UserPost.dart';
import 'Widgets/PostCard.dart';
import 'Widgets/OGnavbar.dart';
import 'Objects/SchoolPostList.dart';
import '../Widgets/GroupTile.dart';
//import 'package:provider/provider.dart';


void main() => runApp(MaterialApp(
    initialRoute: '/home',
    routes:{
      '/': (context) => Loading(),  //need loading widget
      '/home': (context)=> MainScreen(),
      '/userProfile': (context)=> UserProfile(),
    }

));


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {



  List<Group> groupList=[

    Group('image', 'Lville','Lawrenceville,NJ'),
    Group('image', 'Lville','Lawrenceville,NJ'),

  ];


  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex:1,
      length:3,
      child: Scaffold(
        backgroundColor: Colors.grey[200],

        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blue,
          elevation:0.0,
          title: const Text('AppBar'),
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.favorite, size: 18.0),
              onPressed: (){},
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.account_circle, size: 18.0),
              onPressed: (){
                Navigator.push(context, new MaterialPageRoute(
                    builder: (context) => new UserProfile())
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor:Colors.grey,

            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.cloud_outlined),
                text: 'School',
              ),
              Tab(
                text:'Home',
              ),
              Tab(
                text:'Popular'
              ),
            ]
          )
        ),

        body: TabBarView(
          children: <Widget>[
            Center(
              child: CustomScrollView(
                slivers: [
                  SchoolPostList(),
                ]
              ),
            ),
            Center(
              child: Text("It's rainy here"),
            ),
            Center(
              child: Text("It's sunny here"),
              ),
          ],
        ),
      ),
    );
  }
}//MAINSCREEN



