import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/search_result.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/home2.dart';
import 'package:hs_connect/screens/home/home2.dart';

import 'package:hs_connect/screens/new_post/new_post.dart';
import 'package:hs_connect/screens/profile/profile.dart';
import 'package:hs_connect/screens/search/group_search.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';
import 'package:hs_connect/shared/widgets/search.dart';
import 'package:provider/provider.dart';

import '../no_animation_material_page_route.dart';

import 'loading.dart';

class navbar extends StatefulWidget {
  const navbar({Key? key}) : super(key: key);

  @override
  _navbarState createState() => _navbarState();
}

class _navbarState extends State<navbar> {

  GroupsDatabaseService _groups = GroupsDatabaseService();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    if (loading || userData==null) return Loading();

    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: HexColor("#FFFFFF"),
                spreadRadius: 1.0
            )
          ]
      ),
      child: BottomNavigationBar(
        backgroundColor: HexColor("#FFFFFF"),
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              color: Colors.black,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.school, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => Home2()),
                );
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              color: Colors.black,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.search_rounded, size: 18.0),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                List<Group?> groupData = await _groups.getAllowableGroups(userData: userData);
                groupData.removeWhere((value) => value == null);
                List<SearchResult> searchResults = groupData
                    .map((item) {final group = item as Group; return SearchResult(
                        resultRef: group.groupRef,
                        resultType: 'Group',
                        resultText: group.name,
                        resultDescription: group.description)
                ;})
                    .toList();
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => Search(searchResults: searchResults)),
                );
              },
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              color: Colors.black,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.add, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => NewPost()),
                );
              },
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              color: Colors.black,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.search_rounded, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => Profile(profileId: user!.uid)),
                );
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}