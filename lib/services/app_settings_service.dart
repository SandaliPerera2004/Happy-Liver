import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_settings_model.dart';

class AppSettingsService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AppSettingsModel> getAppSettings() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (data == null || data['appSettings'] == null) {
      return AppSettingsModel(
        darkMode: false,
      );
    }

    return AppSettingsModel.fromMap(
      Map<String, dynamic>.from(
        data['appSettings'],
      ),
    );
  }

  Future<void> updateAppSettings(
      AppSettingsModel settings,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'appSettings': settings.toMap(),
      },
      SetOptions(merge: true),
    );
  }
}