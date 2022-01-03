import 'package:flutter/material.dart';
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
              final groups = snapshot.data.docs.map((docSnapshot) {
                return _groups.groupDataFromSnapshot(snapshot: docSnapshot);
              }).toList();

              return ListView.builder(
                itemCount: groups.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  // when scroll up/down, fires once
                  return Center(
                      child: GroupCard(group: groups[index])
                  );
                },
              );
            } else {
              return Loading();
            }
          });
    }
  }
}
