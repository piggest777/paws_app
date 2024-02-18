import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/box_item.dart'; // Ensure this path matches your project structure

class BoxItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'boxItems';

  // Fetch box items for a specific box
  Future<List<BoxItem>> fetchBoxItems(String boxId) async {
    try {
      var querySnapshot = await _db.collection(_collectionPath)
                                    .where('boxId', isEqualTo: boxId)
                                    .get();
      return querySnapshot.docs
                          .map((doc) => BoxItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                          .toList();
    } catch (e) {
      // Handle or throw the error as needed
      throw Exception('Error fetching box items: $e');
    }
  }

  // Stream for real-time updates
  Stream<List<BoxItem>> fetchBoxItemsAsStream(String boxId) {
    return _db.collection(_collectionPath)
      .where('boxId', isEqualTo: boxId)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => BoxItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // Add a new box item
  Future<void> addBoxItem(BoxItem boxItem) async {
    try {
      await _db.collection(_collectionPath).doc(boxItem.id).set(boxItem.toMap());
    } catch (e) {
      // Handle or throw the error as needed
      throw Exception('Error adding box item: $e');
    }
  }

  // Update an existing box item
  Future<void> updateBoxItem(BoxItem boxItem) async {
    try {
      await _db.collection(_collectionPath).doc(boxItem.id).update(boxItem.toMap());
    } catch (e) {
      // Handle or throw the error as needed
      throw Exception('Error updating box item: $e');
    }
  }

  // Delete a box item
  Future<void> deleteBoxItem(String id) async {
    try {
      await _db.collection(_collectionPath).doc(id).delete();
    } catch (e) {
      // Handle or throw the error as needed
      throw Exception('Error deleting box item: $e');
    }
  }
}
