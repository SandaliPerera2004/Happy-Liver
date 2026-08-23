import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword(
      String currentPassword,
      String newPassword,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    if (user.email == null) {
      throw Exception('User email is not available.');
    }

    // Re-authenticate the user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    // Change password
    await user.updatePassword(newPassword);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}