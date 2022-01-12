import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/screens/search/discoverHeader.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class Discover extends StatefulWidget {
  const Discover({Key? key}) : super(key: key);

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    }

    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: userData.userRef);

    return FutureBuilder(
        future: _groups.getTrendingGroups(
            domain: userData.domain, county: userData.county, state: userData.state, country: userData.country),
        builder: (BuildContext context, AsyncSnapshot<List<Group>> snapshot1) {
          if (snapshot1.hasData) {
            final groups = snapshot1.data;
            if (groups != null) {
              return Container(
                height: double.maxFinite,
                // width: 500,
                child: ListView.builder(
                  itemCount: groups.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index1) {
                    PostsDatabaseService _posts =
                        PostsDatabaseService(groupRefs: [groups[index1].groupRef], currUserRef: userData.userRef);

                    return Column(children: <Widget>[
                      DiscoverHeader(
                          group: groups[index1],
                          currUserRef: userData.userRef,
                          joined: userData.userGroups.map((ug) => ug.groupRef).contains(groups[index1].groupRef)),
                      FutureBuilder(
                          future: _posts.getMultiGroupPosts(),
                          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot2) {
                            if (snapshot2.hasData) {
                              List<Post?> posts = snapshot2.data;
                              return Container(
                                height: 140,
                                width: double.maxFinite,
                                color: HexColor('F4F4F4'),
                                child: ListView.builder(
                                    padding: EdgeInsets.all(4.0),
                                    itemCount: posts.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (BuildContext context, int index2) {
                                      if (posts[index2] == null) {
                                        return Text("error");
                                      } else {
                                        return Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: HexColor('93989B'), width: 1.0)),
                                            child: Container(
                                                width: 140,
                                                child: Overlay(
                                                  initialEntries: <OverlayEntry>[
                                                    OverlayEntry(builder: (BuildContext context) {
                                                      return Column(children: <Widget>[
                                                        SizedBox(height: 12.5),
                                                        Row(
                                                          children: <Widget>[
                                                            SizedBox(width: 12.5),
                                                            Container(
                                                              width: 115,
                                                              child: Text(
                                                                posts[index2]!.title,
                                                                maxLines: 4,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            Spacer()
                                                          ],
                                                        ),
                                                        Spacer()
                                                      ]);
                                                    }),
                                                    OverlayEntry(builder: (BuildContext context) {
                                                      return Column(children: <Widget>[
                                                        Spacer(),
                                                        Row(children: <Widget>[
                                                          Spacer(),
                                                          IconButton(
                                                              padding: EdgeInsets.all(0.0),
                                                              iconSize: 12.0,
                                                              splashRadius: 12.0,
                                                              onPressed: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => PostPage(
                                                                            postRef: posts[index2]!.postRef,
                                                                            currUserRef: userData.userRef)));
                                                              },
                                                              icon: Icon(Icons.subdirectory_arrow_left_rounded))
                                                        ])
                                                      ]);
                                                    }),
                                                  ],
                                                )));
                                        return Text(posts[index2]!.title);
                                      }
                                    }),
                              );
                            } else {
                              return Loading();
                            }
                          }),
                    ]);
                  },
                ),
              );
            }
          }
          return Loading();
        });
  }
}
