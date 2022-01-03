import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/knownDomain.dart';
import 'package:hs_connect/shared/constants.dart';

class KnownDomainsDatabaseService {
  // collection reference
  final CollectionReference knownDomainsCollection = FirebaseFirestore.instance.collection(C.knownDomains);

  // get group data from groupRef
  Future<KnownDomain?> getKnownDomain({required String domain}) async {
    final DocumentSnapshot documentSnapshot = await knownDomainsCollection.doc(domain).get();
    if (documentSnapshot.exists) {
      return KnownDomain(
          county: documentSnapshot.get(C.county),
          state: documentSnapshot.get(C.state),
          country: documentSnapshot.get(C.county));
    } else {
      return null;
    }
  }
}
