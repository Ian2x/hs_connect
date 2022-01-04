import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
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
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot1) {
          if (snapshot1.hasData) {
            List<Group> groups = snapshot1.data.docs
                .map((docSnapshot) {
                  return _groups.groupDataFromSnapshot(snapshot: docSnapshot);
                })
                .toList()
                .cast<Group>();
            return Container(
              height: double.maxFinite,
              // width: 500,
              child: ListView.builder(
                itemCount: groups.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index1) {
                  PostsDatabaseService _posts =
                      PostsDatabaseService(groupRefs: [groups[index1].groupRef], currUserRef: userData.userRef);
                  return Column(children: <Widget>[
                    Text(groups[index1].name),
                    FutureBuilder(
                        future: _posts.getMultiGroupPosts(),
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot2) {
                          if (snapshot2.hasData) {
                            List<Post?> posts = snapshot2.data;
                            return Container(
                              height: 100,
                              width: double.maxFinite,
                              child: ListView.builder(
                                  itemCount: posts.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index2) {
                                    if (posts[index2] == null) {
                                      return Text("error");
                                    } else {
                                      return Card(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                                        child: Text(posts[index2]!.title),
                                      );
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
          } else {
            return Loading();
          }
        });
  }
}
