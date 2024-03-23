import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/models/fond.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSupplyItemTypeToFirebase(PetCareSupply supplyItem) async {
    try {
      await _firestore.collection('petSupplyType').add(supplyItem.toMap());
    } catch (error) {
      print('Error adding supply item to Firebase: $error');
      rethrow;
    }
  }

    Future<void> updateSupplyItemTypeInFirebase(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('petSupplyType').doc(id).update(data);
      print("Supply item updated successfully.");
    } catch (e) {
      print("Error updating supply item: $e");
      rethrow; 
    }
  }

  Future<List<PetCareSupply>> fetchSuppliesByKeyword(String keyword) async {
  try {
    var querySnapshot = await _firestore
        .collection('petSupplyType')
        .where('keywords', arrayContains: keyword.toLowerCase())
        .orderBy('manufacturer')
        .get();
    return querySnapshot.docs
        .map((doc) => PetCareSupply.fromMap(doc.data(), doc.id))
        .toList();
  } catch (error) {
    print('Error fetching supplies by keyword: $error');
    rethrow;
  }
}

  Future<List<PetCareSupply>> fetchGenericSupplies() async {
  try {
    var querySnapshot = await _firestore
        .collection('petSupplyType')
        .where('isGeneric', isEqualTo: true)
        .orderBy('name')
        .get();
    return querySnapshot.docs
        .map((doc) => PetCareSupply.fromMap(doc.data(), doc.id))
        .toList();
  } catch (error) {
    print('Error fetching generic supplies: $error');
    rethrow;
  }
}

  Future<int> getCurrentCounter() async {
  try {
    var counterDoc = await FirebaseFirestore.instance.collection('counters').doc('boxId').get();
    if (counterDoc.exists) {
      return counterDoc.data()?['current'] ?? 1; // Assuming 'current' is the field name
    } else {
      print('Counter document does not exist');
      return 1; // Default starting value
    }
  } catch (e) {
    print('Error fetching counter: $e');
    return 1; // Handle error scenario
  }
}

  Future<void> incrementCounter(int newCounter) async {
    await FirebaseFirestore.instance.collection('counters').doc('boxId').update({'current': newCounter});
  }

  Future<void> addItemToBox(BoxItem boxItem) async {
    try {
      await _firestore.collection('boxItems').doc(boxItem.id).set(boxItem.toMap());
      print("Item added to box successfully.");
    } catch (e) {
      print("Error adding item to box: $e");
      rethrow;
    }
  }

    Future<void> addItemToBoxAndDecrementCount(BoxItem boxItem, String supplyId, double quantityToAdd) async {
    await addItemToBox(boxItem).then((_) async {
      await decrementSupplyItemCount(supplyId, quantityToAdd);
    });
  }


 Future<void> decrementSupplyItemCount(String supplyId, double decrementBy) async {
    DocumentReference supplyRef = _firestore.collection('petSupplyType').doc(supplyId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(supplyRef);

      if (!snapshot.exists) {
        throw Exception("Supply item does not exist!");
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      double currentCount = (data['count'] as num?)?.toDouble() ?? 0.0;
      double newCount = currentCount - decrementBy;

      if (newCount < 0) {
        newCount = 0;
        print("Cannot decrement count below zero.");
      }

      transaction.update(supplyRef, {'count': newCount});
    }).catchError((error) {
      print("Error decrementing supply item count: $error");
      throw error; // Rethrow or handle as needed
    });
  }

//fonds
    Future<void> saveFond(Fond fond) async {
    await _firestore.collection('fonds').add(fond.toMap());
  }

  Future<List<Fond>> getFonds() async {
    try {
      var collection = _firestore.collection('fonds');
      var querySnapshot = await collection.get();
      var fonds = querySnapshot.docs.map((doc) {
        // Use Fond.fromMap to create a new Fond instance
        return Fond.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      return fonds;
    } catch (e) {
      // Handle any errors appropriately
      print(e.toString());
      return [];
    }
  }

}

