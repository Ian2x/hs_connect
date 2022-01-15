import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/domainData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

class DomainsDataDatabaseService {
  // collection reference
  final CollectionReference domainsDataDatabaseCollection = FirebaseFirestore.instance.collection(C.domainsData);

  // get group data from groupRef
  Future<DomainData?> getDomainData({required String domain}) async {
    final DocumentSnapshot documentSnapshot = await domainsDataDatabaseCollection.doc(domain).get();
    if (documentSnapshot.exists) {
      return DomainData(
          county: documentSnapshot.get(C.overrideCounty),
          state: documentSnapshot.get(C.overrideState),
          country: documentSnapshot.get(C.overrideCounty),
          fullName: documentSnapshot.get(C.fullName),
          color: HexColor(documentSnapshot.get(C.color))
      );
    } else {
      return null;
    }
  }
}
