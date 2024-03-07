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

    static String getDescription(BoxItem item) {

  if (item.ukTranslation != null && item.ukTranslation!.isNotEmpty) {
    return item.ukTranslation!;
  }

    switch (item.supplyType) {
      case "Food":
        if (item.foodType == "Wet") return 'м’який корм для тварин';
        if (item.foodType == "Dry") return 'сухий корм для тварин';
        return 'Їжа для тварин'; // Fallback for food without specific type

      case "Snacks":
        return 'Снек';

      case "Medical":
        return 'Медицина';

      case "Clothes":
        return 'Одяг для тварин';

      case "Toys":
        return 'Іграшки';

      case "Leashes":
        return 'Поводок';

      case "Collars":
        return 'Ошейник';

      case "Underlay":
        return 'Підстилка';

      case "Bowls":
        return 'Миска';

      case "Pet home":
        return 'Лежанка';

      case "Care products":
        return 'Засоби піклування для тварин';

      case "Shampoo":
        return "Шампунь";
        
      case "Brushes":
        return "Розчіска";

      case "Nail clippers":
        return "Розчіска";

      case "Pet carrier":
        return 'Переноска';

      case "Cages":
        return 'Клітка';
      case "Boxes":
      return 'Вантаж';
      default:
        return 'Різне'; // Fallback for unspecified or new types
    }
  }

  // Stream for real-time updates
  Stream<List<BoxItem>> fetchBoxItemsAsStream(String boxId) {
    return _db
        .collection('boxItems')
        .where('boxId', isEqualTo: boxId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BoxItem.fromMap(doc.data(), doc.id)).toList());
  }

  // Delete a box item with the given ID
  Future<void> deleteBoxItem(String id) async {
    try {
      await _db.collection(_collectionPath).doc(id).delete();
    } catch (e) {
      // Handle or throw the error as needed
      throw Exception('Error deleting box item: $e');
    }
  }

Future<void> recalculateAndUpdateBoxWeight(String boxId) async {
  try {
    final items = await fetchBoxItems(boxId); // Fetch all items for the box
    final totalWeight = items.fold(0.0, (sumWeight, item) => sumWeight + item.basicWeight * item.count); // Calculate total weight

    // Update the box's total weight in Firestore
    await FirebaseFirestore.instance.collection('boxes').doc(boxId).update({
      'weight': totalWeight
    });
  } catch (e) {
    throw Exception('Error recalculating box weight: $e');
  }
}

  Future<List<ActItem>> getActItems(String boxId) async {
    Map<String, ActItem> groupedActItems = {};
    int counter = 1;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('boxItems')
          .where('boxId', isEqualTo: boxId)
          .get();

      for (var doc in querySnapshot.docs) {
        BoxItem item = BoxItem.fromMap(doc.data(), doc.id);
        ActItem actItem = ActItemConverter.convertToActItem(item, counter++);
        
        // If the description already exists, update quantity and nettoWeight
        if (groupedActItems.containsKey(actItem.description)) {
          ActItem existingItem = groupedActItems[actItem.description]!;
          existingItem.quantity += actItem.quantity;
          existingItem.nettoWeight += actItem.nettoWeight;
        } else {
          groupedActItems[actItem.description] = actItem;
        }
      }
    } catch (e) {
      print("Error fetching items: $e");
    }

    // Convert the map back to a list of ActItems
    List<ActItem> actItems = groupedActItems.values.toList();

    // Optionally, you might want to reset the numbering
    int number = 1;
    for (var item in actItems) {
      item.number = number++;
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

    Future<void> updateBoxWeight(String boxId, double newWeight) async {
    try {
      await _db.collection('boxes').doc(boxId).update({'boxWeight': newWeight});
    } catch (e) {
      print(e); // Consider handling errors more gracefully
    }
  }

Future<double> fetchBoxWeight(String boxId) async {
  try {
    DocumentSnapshot boxDoc = await _db.collection('boxes').doc(boxId).get();
    var data = boxDoc.data();
    if (data is Map<String, dynamic>) { // Cast the data to a Map
      return data['boxWeight']?.toDouble() ?? 0.0; // Ensure you safely cast to double
    } else {
      return 0.0; // Return a default value if casting fails or data is not as expected
    }
  } catch (e) {
    print(e); // Consider handling errors more gracefully
    return 0.0;
  }
}

}
