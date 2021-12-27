import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/services/user_data_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change home stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Create home for email verification purposes
  Future createEmailUser(String email) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: email, password: 'password123');
      User? user = userCredential.user;
      return user;
    } catch (e) {
      return e;
    }
  }

  // register with username & password
  Future registerWithUsernameAndPassword(
      String username, String password, String domain) async {
    try {
      await _auth.signOut();
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: '$username@ianeric.com', password: password);
      User? user = userCredential.user;

      if (user == null || user.email == null) return null;
      // create a document for the home with the uid
      final _userDataDatabaseService = UserDataDatabaseService(userRef: FirebaseFirestore.instance.collection('userData').doc(user.uid));
      await _userDataDatabaseService.initUserData(domain, username);
      return user;
    } catch (e) {
      return e;
    }
  }

  // sign in with username & password
  Future signInWithUsernameAndPassword(String username, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: '$username@ianeric.com', password: password);
      User? user = userCredential.user;
      return user;
    } catch (e) {
      return e;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return e;
    }
  }
}
