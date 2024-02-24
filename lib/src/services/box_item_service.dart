import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/act_item.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/services/act_item_converter.dart'; // Ensure this path matches your project structure

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
                          .map((doc) => BoxItem.fromMap(doc.data(), doc.id))
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
        .map((doc) => BoxItem.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<List<ActItem>> getActItems(String boxId) async {
  List<ActItem> actItems = [];
  int counter = 1;

  try {
    // Assuming you're using Firestore and have a collection named 'boxItems'
    final querySnapshot = await FirebaseFirestore.instance
        .collection('boxItems')
        .where('boxId', isEqualTo: boxId)
        .get();

    for (var doc in querySnapshot.docs) {
      BoxItem item = BoxItem.fromMap(doc.data(), doc.id);
      actItems.add(ActItemConverter.convertToActItem(item, counter++));
    }
  } catch (e) {
    print("Error fetching items: $e");
  }

  return actItems;
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
