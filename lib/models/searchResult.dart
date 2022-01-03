import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';

enum SearchResultType { posts, groups, people }

extension SearchResultTypeExtension on SearchResultType {
  String get string {
    switch (this) {
      case SearchResultType.posts:
        return C.posts;
      case SearchResultType.people:
        return C.people;
      case SearchResultType.groups:
        return C.groups;
    }
  }
}

class SearchResult {
  final DocumentReference resultRef;
  final SearchResultType resultType;
  final String resultText;
  final String? resultDescription;

  SearchResult({
    required this.resultRef,
    required this.resultType,
    required this.resultText,
    required this.resultDescription,
  });
}
