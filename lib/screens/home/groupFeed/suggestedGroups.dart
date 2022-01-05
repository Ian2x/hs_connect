import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/groupView/groupCard.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class SuggestedGroups extends StatefulWidget {
  final String domain;
  final String? county;
  final String? state;
  final String? country;

  const SuggestedGroups(
      {Key? key, required this.domain, required this.county, required this.state, required this.country})
      : super(key: key);

  @override
  _SuggestedGroupsState createState() => _SuggestedGroupsState();
}

class _SuggestedGroupsState extends State<SuggestedGroups> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    }
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: userData.userRef);

    return FutureBuilder(
        future: _groups.getTrendingGroups(
            domain: widget.domain, county: widget.county, state: widget.state, country: widget.country),
        builder: (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
          if (snapshot.hasData) {
            final groups = snapshot.data;
            // final groups = snapshot.data.docs.map((snapshot) => groupFromSnapshot(snapshot)).toList();
            if (groups != null) {
              return ListView.builder(
                itemCount: groups.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  // when scroll up/down, fires once
                  return Center(child: GroupCard(group: groups[index], currUserRef: userData.userRef));
                },
              );
            }
          }
          return Loading();
        });
  }
}
