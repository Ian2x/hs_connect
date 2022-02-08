import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:tuple/tuple.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change home stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Create home for email verification purposes
  Future<dynamic> createEmailUser(String email) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: 'password123');
      User? user = userCredential.user;
      return user;
    } catch (e) {
      return e;
    }
  }

  // register with username & password
  Future<dynamic> registerWithUsernameAndPassword(String username, String password, String domain, String domainEmail) async {
    try {
      await _auth.signOut();
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: '$username@ianeric.com', password: password);
      User? user = userCredential.user;

      if (user == null || user.email == null) return null;
      // create a document for the home with the uid
      final _userDataDatabaseService =
          UserDataDatabaseService(currUserRef: FirebaseFirestore.instance.collection(C.userData).doc(user.uid));
      Tuple3<String, int, String> data = await _userDataDatabaseService.initUserData(domain, username, domainEmail);
      return Tuple4<User?, String, int, String>(user, data.item1, data.item2, data.item3);
    } catch (e) {
      return e;
    }
  }

  // sign in with username & password
  Future<dynamic> signInWithUsernameAndPassword(String username, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: '$username@ianeric.com', password: password);
      User? user = userCredential.user;
      return user;
    } catch (e) {
      return e;
    }
  }

  // sign out
  Future<dynamic> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return e;
    }
  }
}
