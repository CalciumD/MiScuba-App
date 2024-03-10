import 'package:firebase_auth/firebase_auth.dart';

/*
  Documentaion for this was from Youtube and Google Firebase
*/
class FirebaseAuthServce {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmaulAndPassword(String email, String password) async {
    try {
      UserCredential credential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("some error");
    }
    return null;
  }

  Future<User?> signInWithEmaulAndPassword(String email, String password) async {
    try {
      UserCredential credential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("some error");
    }
    return null;
  }

  Future<void> resetPasswordWithEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("email not found");
    }
  }
}
