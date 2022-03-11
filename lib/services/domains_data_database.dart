import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hs_connect/models/domainData.dart';
import 'package:hs_connect/shared/constants.dart';

class DomainsDataDatabaseService {
  // collection reference
  static final CollectionReference domainsDataDatabaseCollection = FirebaseFirestore.instance.collection(C.domainsData);

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
          image: documentSnapshot.get(C.image),
          launchDate: documentSnapshot.get(C.launchDate));
    } else {
      return null;
    }
  }

  Future<List<String>> getAllDomains() async {

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('queryForDomains');
      dynamic resp = await callable.call();

      if (resp.data is List) {
        return (resp.data as List).map((item) => item as String).toList();
      } else {
        return [];
      }
    } catch (error) {
      print(error);
      return [];
    }
    // return (await domainsDataDatabaseCollection.get()).docs.map((qds) => qds.id).toList();
  }
}
