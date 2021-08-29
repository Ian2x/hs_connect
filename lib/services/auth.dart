import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/services/userInfo_database.dart';

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
      print(e.toString());
      return null;
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
      print('creating...');
      await UserInfoDatabaseService(userId: user.uid)
          .initUserData(domain, username);

      return user;
    } catch (e) {
      print(e.toString());
      return null;
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
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
