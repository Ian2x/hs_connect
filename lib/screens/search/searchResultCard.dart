import 'package:flutter/material.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/screens/home/postFeed/specificGroupFeed.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/screens/profile/profile.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult searchResult;
  final SearchResultType searchResultType;

  const SearchResultCard({Key? key, required this.searchResult, required this.searchResultType}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        print("surprised");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) {
                switch (searchResultType) {
                  case SearchResultType.people:
                    return Profile(profilePersonRef: searchResult.resultRef);
                  case SearchResultType.posts:
                    return PostPage(postRef: searchResult.resultRef);
                  default: // for SearchResultType.groups
                    return SpecificGroupFeed(groupRef: searchResult.resultRef);
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
