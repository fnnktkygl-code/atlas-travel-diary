import 'package:cloud_firestore/cloud_firestore.dart';
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

  // --- Journal Entries ---

  Stream<List<JournalEntry>> getUserEntriesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return JournalEntry.fromJson(data);
      }).toList();
    });
  }

  Future<void> saveUserEntry(String uid, JournalEntry entry) async {
    final data = entry.toJson();
    data.remove('id'); // doc id is managed by firestore
    
    await _db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .doc(entry.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> removeUserEntry(String uid, String entryId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .doc(entryId)
        .delete();
  }

  Future<void> deleteSpecificData(String uid, List<String> countryIds, List<String> entryIds) async {
    final allIds = [
      ...countryIds.map((id) => _db.collection('users').doc(uid).collection('countries').doc(id)),
      ...entryIds.map((id) => _db.collection('users').doc(uid).collection('entries').doc(id)),
    ];

    for (var i = 0; i < allIds.length; i += 400) {
      final batch = _db.batch();
      final chunk = allIds.sublist(i, i + 400 > allIds.length ? allIds.length : i + 400);
      for (var ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  Future<void> resetUserData(String uid) async {
    final countries = await _db.collection('users').doc(uid).collection('countries').get(const GetOptions(source: Source.server));
    final entries = await _db.collection('users').doc(uid).collection('entries').get(const GetOptions(source: Source.server));
    
    final allRefs = [
      ...countries.docs.map((d) => d.reference),
      ...entries.docs.map((d) => d.reference),
    ];
    
    for (var i = 0; i < allRefs.length; i += 400) {
      final batch = _db.batch();
      final chunk = allRefs.sublist(i, i + 400 > allRefs.length ? allRefs.length : i + 400);
      for (var ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }
}
