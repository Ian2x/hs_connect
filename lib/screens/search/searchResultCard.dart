import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/screens/home/postFeed/specificGroupFeed.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/screens/profile/profile.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult searchResult;
  final SearchResultType searchResultType;
  final DocumentReference currUserRef;

  const SearchResultCard({Key? key, required this.searchResult, required this.searchResultType, required this.currUserRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) {
                switch (searchResultType) {
                  case SearchResultType.people:
                    return Profile(profilePersonRef: searchResult.resultRef, currUserRef: currUserRef,);
                  case SearchResultType.posts:
                    return PostPage(postRef: searchResult.resultRef, currUserRef: currUserRef,);
                  default: // for SearchResultType.groups
                    return SpecificGroupFeed(groupRef: searchResult.resultRef, currUserRef: currUserRef,);
                }

          }
        )
        );
      },
      child: Card(
        child: Column(
          children: <Widget>[
            Text(searchResult.resultText),
            searchResult.resultDescription != null ? Text(searchResult.resultDescription!) : Text("No description"),
          ]
        )
      ),
    );
  }
}

