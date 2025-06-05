import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user document
  Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Save tire data
  Future<DocumentReference> saveTireData(
      String userId, Map<String, dynamic> tireData) async {
    try {
      // Add the timestamp and user ID to the data
      tireData['timestamp'] = FieldValue.serverTimestamp();
      tireData['userId'] = userId;

      // Save to the tires collection
      return await _firestore.collection('tires').add(tireData);
    } catch (e) {
      throw Exception('Failed to save tire data: $e');
    }
  }

  // Get tire data for a specific user
  Stream<QuerySnapshot> getTireData(String userId) {
    try {
      return _firestore
          .collection('tires')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to get tire data: $e');
    }
  }

  // Save a vehicle profile
  Future<DocumentReference> saveVehicle(
      String userId, Map<String, dynamic> vehicleData) async {
    try {
      // Add the user ID to the data
      vehicleData['userId'] = userId;
      vehicleData['createdAt'] = FieldValue.serverTimestamp();

      // Save to the vehicles collection
      return await _firestore.collection('vehicles').add(vehicleData);
    } catch (e) {
      throw Exception('Failed to save vehicle: $e');
    }
  }

  // Get all vehicles for a user
  Stream<QuerySnapshot> getUserVehicles(String userId) {
    try {
      return _firestore
          .collection('vehicles')
          .where('userId', isEqualTo: userId)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to get user vehicles: $e');
    }
  }

  // Save an alert
  Future<DocumentReference> saveAlert(Map<String, dynamic> alertData) async {
    try {
      // Add timestamp
      alertData['createdAt'] = FieldValue.serverTimestamp();

      // Save to alerts collection
      return await _firestore.collection('alerts').add(alertData);
    } catch (e) {
      throw Exception('Failed to save alert: $e');
    }
  }

  // Get alerts for a user
  Stream<QuerySnapshot> getUserAlerts(String userId) {
    try {
      return _firestore
          .collection('alerts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to get user alerts: $e');
    }
  }

  // Delete a document from a collection
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}
