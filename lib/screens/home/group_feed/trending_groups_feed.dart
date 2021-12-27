import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/group_view/group_card.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
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

              final groups = snapshot.data.docs.map((docSnapshot) {
                return Group(
                    groupRef: docSnapshot.reference,
                    creatorRef: docSnapshot.get("userRef"),
                    name: docSnapshot.get("name"),
                    image: docSnapshot.get("image"),
                    description: docSnapshot.get("description"),
                    accessRestrictions: AccessRestriction(
                        restrictionType: docSnapshot.get("accessRestrictions")["restrictionType"],
                        restriction: docSnapshot.get("accessRestrictions")["restriction"]
                    ),
                    createdAt: docSnapshot.get('createdAt'),
                    numPosts: docSnapshot.get('numPosts'),
                    moderatorRefs: docSnapshot.get('moderatorRefs'),
                    numMembers: docSnapshot.get('numMembers'),
                );
              }).toList();

              // final posts = (snapshot.data as List<Group?>).map((group) => group!).toList();

              return ListView.builder(
                itemCount: groups.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  // when scroll up/down, fires once
                  return Center(
                      child: GroupCard(
                    groupRef: groups[index].groupRef,
                    userRef: groups[index].creatorRef,
                    name: groups[index].name,
                    image: groups[index].image,
                    description: groups[index].description,
                    accessRestrictions: groups[index].accessRestrictions,
                    currUserRef: userData.userRef,
                    numMembers: groups[index].numMembers,
                    moderatorRefs: groups[index].moderatorRefs,

                  ));
                },
              );
            } else {
              return Loading();
            }
          });
    }
  }
}
