import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/map_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Listen to user's countries updates
  Stream<Map<String, UserCountryData>> getUserCountriesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('countries')
        .snapshots()
        .map((snapshot) {
      final map = <String, UserCountryData>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['code'] = doc.id; // ensure code is in JSON
        map[doc.id] = UserCountryData.fromJson(data);
      }
      return map;
    });
  }

  // Update or set country data
  Future<void> saveUserCountry(String uid, UserCountryData countryData) async {
    final data = countryData.toJson();
    data.remove('code'); // Code is the doc id
    
    await _db
        .collection('users')
        .doc(uid)
        .collection('countries')
        .doc(countryData.code)
        .set(data, SetOptions(merge: true));
  }

  // Remove country data
  Future<void> removeUserCountry(String uid, String countryId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('countries')
        .doc(countryId)
        .delete();
  }

  // Upload photo to Firebase Storage
  Future<String> uploadPhoto(String uid, String countryId, Uint8List fileBytes, String fileName) async {
    final storageRef = FirebaseStorage.instance.ref();
    final photoRef = storageRef.child('users/$uid/$countryId/$fileName');
    
    final uploadTask = photoRef.putData(fileBytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Delete photo from Firebase Storage
  Future<void> deletePhoto(String photoUrl) async {
    try {
      final photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
      await photoRef.delete();
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }
}
