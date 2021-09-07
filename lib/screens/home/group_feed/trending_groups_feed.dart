import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/group_view/group_card.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:provider/provider.dart';

class TrendingGroupsFeed extends StatefulWidget {
  final String domain;
  final String? county;
  final String? state;
  final String? country;

  const TrendingGroupsFeed(
      {Key? key, required this.domain, required this.county, required this.state, required this.country})
      : super(key: key);

  @override
  _TrendingGroupsFeedState createState() => _TrendingGroupsFeedState();
}

class _TrendingGroupsFeedState extends State<TrendingGroupsFeed> {
  @override
  Widget build(BuildContext context) {
    GroupsDatabaseService _groups = GroupsDatabaseService();
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    } else {
      return FutureBuilder(
          future: _groups.getTrendingGroups(
              domain: widget.domain, county: widget.county, state: widget.state, country: widget.country),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data.docs);

              /*
              List<Group> posts = [];


              snapshot.data.docs.forEach((docSnapshot) {
                print(docSnapshot.get('name'));
                print(docSnapshot.get("userId"));
                print(docSnapshot.id);
                print(docSnapshot.get("image"));
                print(docSnapshot.get("accessRestrictions"));
                posts.add(Group(
                    groupId: docSnapshot.id,
                    userId: docSnapshot.get("userId"),
                    name: docSnapshot.get("name"),
                    image: docSnapshot.get("image"),
                    accessRestrictions: AccessRestriction(
                        restrictionType: docSnapshot.get("accessRestrictions")["restrictionType"],
                        restriction: docSnapshot.get("accessRestrictions")["restriction"]
                    )
                ));
              });
              */

              final posts = snapshot.data.docs.map((docSnapshot) {
                return Group(
                    groupId: docSnapshot.id,
                    userId: docSnapshot.get("userId"),
                    name: docSnapshot.get("name"),
                    image: docSnapshot.get("image"),
                    accessRestrictions: AccessRestriction(
                        restrictionType: docSnapshot.get("accessRestrictions")["restrictionType"],
                        restriction: docSnapshot.get("accessRestrictions")["restriction"]
                    )
                );
              }).toList();

              // final posts = (snapshot.data as List<Group?>).map((group) => group!).toList();

              return ListView.builder(
                itemCount: posts.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  // when scroll up/down, fires once
                  return Center(
                      child: GroupCard(
                    groupId: posts[index].groupId,
                    userId: posts[index].userId,
                    name: posts[index].name,
                    image: posts[index].image,
                    accessRestrictions: posts[index].accessRestrictions,
                    currUserId: userData.userId,
                  ));
                },
              );
              return Container();
            } else {
              return Loading();
            }
          });
    }
  }
}
