import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  // ================================================================
  // GET CURRENTLY LOGGED-IN USER'S PROFILE
  // ================================================================

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

  // ================================================================
  // UPDATE CURRENTLY LOGGED-IN USER'S PROFILE
  // ================================================================

  Future<void> updateUserProfile({
    required String username,
    required int  age,
    required String gender,
    required double height,
    required double weight,
    required double bmi,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    // Update Firebase Authentication display name
    await user.updateDisplayName(username);

    // Update Firestore user document
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

  // ================================================================
  // UPLOAD PROFILE PICTURE
  // ================================================================

  Future<String> uploadProfilePicture(
      File imageFile,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    final userId = user.uid;

    // Storage location:
    // profile_images / USER_ID / profile.jpg
    final storageRef = _storage
        .ref()
        .child('profile_images')
        .child(userId)
        .child('profile.jpg');

    // Upload image
    await storageRef.putFile(
      imageFile,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    // Get downloadable URL
    final downloadUrl =
    await storageRef.getDownloadURL();

    // Save URL in Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .update({
      'profileImageUrl': downloadUrl,
    });

    return downloadUrl;
  }

  // ================================================================
  // GET PROFILE PICTURE URL
  // ================================================================

  Future<String?> getProfilePictureUrl() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    final imageUrl =
    data?['profileImageUrl'];

    if (imageUrl is String &&
        imageUrl.trim().isNotEmpty) {
      return imageUrl;
    }

    return null;
  }

  // ================================================================
  // DELETE PROFILE PICTURE
  // ================================================================

  Future<void> deleteProfilePicture() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    final userId = user.uid;

    final storageRef = _storage
        .ref()
        .child('profile_images')
        .child(userId)
        .child('profile.jpg');

    try {
      await storageRef.delete();
    } catch (_) {
      // Ignore if the image does not exist.
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .update({
      'profileImageUrl':
      FieldValue.delete(),
    });
  }

  // ================================================================
// MARK ASSESSMENT AS COMPLETED
// ================================================================

  Future<void> markAssessmentCompleted() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'assessmentCompleted': true,
    });
  }
}