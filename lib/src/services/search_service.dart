import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchPerson(String query) async {
    final queryLower = query.toLowerCase();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> results = [];

    try {
      final querySnapshot = await _firestore
          .collection('persons')
          .where('keywords', arrayContains: queryLower)
          .get();

      for (var doc in querySnapshot.docs) {
        results.add(doc);
      }

      return results;
    } catch (e) {
      print("Error searching for persons: $e");
      return [];
    }
  }
}
