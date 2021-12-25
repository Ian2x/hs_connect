import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/known_domain.dart';

class KnownDomainsDatabaseService {
  // collection reference
  final CollectionReference knownDomainsCollection = FirebaseFirestore.instance.collection('knownDomains');

  // get group data from groupRef
  Future<KnownDomain?> getKnownDomain({required String domain}) async {
    final DocumentSnapshot documentSnapshot = await knownDomainsCollection.doc(domain).get();
    if (documentSnapshot.exists) {
      return KnownDomain(county: documentSnapshot.get('county'), state: documentSnapshot.get('state'), country: documentSnapshot.get('country'));
    } else {
      return null;
    }
  }
}