import 'package:cloud_firestore/cloud_firestore.dart';

class SearchResult {
  final DocumentReference resultRef;
  final String resultType;
  final String resultText;
  final String? resultDescription;

  SearchResult({
    required this.resultRef,
    required this.resultType,
    required this.resultText,
    required this.resultDescription,
  });
}
