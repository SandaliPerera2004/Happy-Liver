import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<UserModel?> getCurrentUserProfile() async {
    const testUid = '4VoTBC0IfbTH5DviH2SNC6QJyrH2';

    final document = await _firestore
        .collection('users')
        .doc(testUid)
        .get();

    print('DOCUMENT EXISTS: ${document.exists}');
    print('DATA: ${document.data()}');


    if (!document.exists) {
      return null;
    }

    return UserModel.fromFirestore(document);
  }
}