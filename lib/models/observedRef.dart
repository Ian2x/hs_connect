import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';

enum ObservedRefType { post, comment }

extension ObservedRefTypeExtension on ObservedRefType {
  String get string {
    switch (this) {
      case ObservedRefType.post:
        return C.post;
      case ObservedRefType.comment:
        return C.comment;
    }
  }
}

observedRefTypeFrom(String observedRefType) {
  switch (observedRefType) {
    case C.post:
      return ObservedRefType.post;
    case C.comment:
      return ObservedRefType.comment;
  }
}

class ObservedRef {
  final DocumentReference ref;
  final ObservedRefType refType;
  final Timestamp lastObserved;

  ObservedRef({
    required this.ref,
    required this.refType,
    required this.lastObserved,
  });

  Map<String, dynamic> asMap() {
    return {
      C.ref: ref,
      C.refType: refType.string,
      C.lastObserved: lastObserved
    };
  }
}

ObservedRef observedRefFromMap({required Map map}) {
  return ObservedRef(
      ref: map[C.ref], refType: observedRefTypeFrom(map[C.refType]), lastObserved: map[C.lastObserved]);
}
