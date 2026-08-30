import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<WorkoutModel>> getWorkoutsByLevel(
      String level,
      ) async {
    final snapshot = await _firestore
        .collection('workoutPlans')
        .doc(level.toLowerCase())
        .collection('exercises')
        .get();

    return snapshot.docs.map((doc) {
      return WorkoutModel.fromFirestore(
        doc.id,
        doc.data(),
      );
    }).toList();
  }

  Future<WorkoutModel?> getWorkoutById(
      String level,
      String workoutId,
      ) async {
    final doc = await _firestore
        .collection('workoutPlans')
        .doc(level.toLowerCase())
        .collection('exercises')
        .doc(workoutId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return WorkoutModel.fromFirestore(
      doc.id,
      doc.data()!,
    );
  }
}