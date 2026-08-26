import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // Get currently logged-in user's profile
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      print('No user is currently logged in.');
      return null;
    }

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    print('DOCUMENT EXISTS: ${document.exists}');
    print('DATA: ${document.data()}');

    if (!document.exists) {
      return null;
    }

    return UserModel.fromFirestore(document);
  }

  // Update currently logged-in user's profile
  Future<void> updateUserProfile({
    required String username,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required double bmi,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'username': username,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bmi': bmi,
    });
  }
}