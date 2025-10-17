import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visitor.dart';
import 'user_profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new visitor
  Future<void> addVisitor(Visitor visitor) async {
    await _firestore
        .collection('visitors')
        .doc(visitor.id)
        .set(visitor.toMap());
  }

  // Get all visitors
  Stream<List<Visitor>> getVisitors() {
    return _firestore
        .collection('visitors')
        .orderBy('entryTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Visitor.fromMap(doc.data()))
              .toList();
        });
  }

  // Update visitor's exit time
  Future<void> updateVisitorExit(String visitorId) async {
    await _firestore.collection('visitors').doc(visitorId).update({
      'exitTime': DateTime.now().toIso8601String(),
      'status': 'left',
    });
  }

  // Get active visitors (who haven't left yet)
  Stream<List<Visitor>> getActiveVisitors() {
    return _firestore
        .collection('visitors')
        .where('status', isEqualTo: 'inside')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Visitor.fromMap(doc.data()))
              .toList();
        });
  }

  // Get visitors for current user or all if admin
  Stream<List<Visitor>> getVisitorsForCurrentUser() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) yield [];
    final userProfileService = UserProfileService();
    final profile = await userProfileService.getCurrentUserProfile();
    final role = profile != null ? profile['role'] as String? : null;
    final uid = user!.uid;
    if (role == null) yield [];
    if (role == 'admin') {
      yield* getVisitors();
    } else {
      yield* _firestore
          .collection('visitors')
          .where('createdBy', isEqualTo: uid)
          .orderBy('entryTime', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Visitor.fromMap(doc.data()))
                .toList();
          });
    }
  }

  // Get active visitors for current user or all if admin
  Stream<List<Visitor>> getActiveVisitorsForCurrentUser() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) yield [];
    final userProfileService = UserProfileService();
    final profile = await userProfileService.getCurrentUserProfile();
    final role = profile != null ? profile['role'] as String? : null;
    final uid = user!.uid;
    if (role == null) yield [];
    if (role == 'admin') {
      yield* getActiveVisitors();
    } else {
      yield* _firestore
          .collection('visitors')
          .where('status', isEqualTo: 'inside')
          .where('createdBy', isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Visitor.fromMap(doc.data()))
                .toList();
          });
    }
  }
}
