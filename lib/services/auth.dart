import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change home stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // register with username & password
  Future<dynamic> registerEmailUser(String email, String password, String domain) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user == null || user.email == null) return null;
      // create a document for the home with the uid
      final _userDataDatabaseService =
          UserDataDatabaseService(currUserRef: FirebaseFirestore.instance.collection(C.userData).doc(user.uid));
      await _userDataDatabaseService.initUserData(domain);
      return user;
    } catch (e) {
      return e;
    }
  }

  // register with username & password
  Future<dynamic> registerPhoneUserData(User user, String domain) async {
    try {
      // create a document for the home with the uid
      final _userDataDatabaseService =
      UserDataDatabaseService(currUserRef: FirebaseFirestore.instance.collection(C.userData).doc(user.uid));
      await _userDataDatabaseService.initUserData(domain);
      return user;
    } catch (e) {
      return e;
    }
  }

  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      // Fetch sign-in methods for the email address
      final list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);
      // In case list is not empty
      if (list.isNotEmpty) {
        // Return true because there is an existing
        // user using the email address
        return true;
      } else {
        // Return false because email address is not in use
        return false;
      }
    } catch (error) {
      // Handle error
      // ...
      return true;
    }
  }

  Future<bool> checkIfNumberInUse(String phoneNumber) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('checkIfPhoneExists');
      dynamic resp = await callable.call({'phone': phoneNumber});
      if (resp.data) {
        // user exists
        return true;
      } else {
        // Return false because email address is not in use
        return false;
      }
    } catch (error) {
      print(error);
      // Handle error
      // ...
      return true;
    }
  }

  // sign in with username & password
  Future<dynamic> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
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

  Future<dynamic> resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      return e;
    }
  }

}
