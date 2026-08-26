import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final double? bmi;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.bmi,
    this.createdAt,
  });

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    return UserModel(
      uid: document.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      bmi: (data['bmi'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'createdAt': createdAt,
    };
  }
}