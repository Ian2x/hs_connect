import 'package:cloud_firestore/cloud_firestore.dart';

int refRankingCompare(a, b) {
  return b.count - a.count;
}

class refRanking {
  final DocumentReference ref;
  final int count;

  refRanking({
    required this.ref,
    required this.count,
  });
}
