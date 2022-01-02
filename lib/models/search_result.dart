import 'package:cloud_firestore/cloud_firestore.dart';

enum SearchResultType {
  posts,
  groups,
  people
}

extension SearchResultTypeExtension on SearchResultType {
  String get string {
    switch (this) {
      case SearchResultType.posts:
        return 'posts';
      case SearchResultType.people:
        return 'people';
      default:
        return 'groups';
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
