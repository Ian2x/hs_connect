import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/group_view/group_card.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class Discover extends StatefulWidget {

  const Discover(
      {Key? key})
      : super(key: key);

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  Widget build(BuildContext context) {
    GroupsDatabaseService _groups = GroupsDatabaseService();
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    } else {
      return FutureBuilder(
          future: _groups.getTrendingGroups(
              domain: userData.domain, county: userData.county, state: userData.state, country: userData.country),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot1) {
            if (snapshot1.hasData) {
              List<Group> groups = snapshot1.data.docs.map((docSnapshot) {
                return Group(
                  groupRef: docSnapshot.reference,
                  creatorRef: docSnapshot.get("creatorRef"),
                  name: docSnapshot.get("name"),
                  LCname: docSnapshot.get("LCname"),
                  image: docSnapshot.get("image"),
                  description: docSnapshot.get("description"),
                  accessRestrictions: AccessRestriction(
                      restrictionType: docSnapshot.get("accessRestrictions")["restrictionType"],
                      restriction: docSnapshot.get("accessRestrictions")["restriction"]),
                  createdAt: docSnapshot.get('createdAt'),
                  numPosts: docSnapshot.get('numPosts'),
                  moderatorRefs:
                      (docSnapshot.get('moderatorRefs') as List).map((item) => item as DocumentReference).toList(),
                  numMembers: docSnapshot.get('numMembers'),
                );
              }).toList().cast<Group>();

              return Container(
                height: double.maxFinite,
                // width: 500,
                child: ListView.builder(
                  itemCount: groups.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index1) {
                    PostsDatabaseService _posts = PostsDatabaseService(groupRefs: [groups[index1].groupRef]);
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
                                    if (posts[index2]==null) {
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
}
