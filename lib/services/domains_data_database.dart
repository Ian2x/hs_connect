import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/domainData.dart';
import 'package:hs_connect/shared/constants.dart';

class DomainsDataDatabaseService {
  // collection reference
  final CollectionReference domainsDataDatabaseCollection = FirebaseFirestore.instance.collection(C.domainsData);

  // get group data from groupRef
  Future<DomainData?> getDomainData({required String domain}) async {
    final DocumentSnapshot documentSnapshot = await domainsDataDatabaseCollection.doc(domain).get();
    if (documentSnapshot.exists) {
      return DomainData(
          county: documentSnapshot.get(C.county),
          state: documentSnapshot.get(C.state),
          country: documentSnapshot.get(C.county),
          fullName: documentSnapshot.get(C.fullName),
          color: documentSnapshot.get(C.color),
          image: documentSnapshot.get(C.image)
      );
    } else {
      return null;
    }
  }
}
