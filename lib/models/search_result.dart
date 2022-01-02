import 'package:cloud_firestore/cloud_firestore.dart';

enum ResultType {
  posts,
  groups,
  people
}

class SearchResult {
  final DocumentReference resultRef;
  final ResultType resultType;
  final String resultText;
  final String? resultDescription;

  SearchResult({
    required this.resultRef,
    required this.resultType,
    required this.resultText,
    required this.resultDescription,
  });
}
