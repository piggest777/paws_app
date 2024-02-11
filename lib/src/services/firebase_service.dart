import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSupplyItemTypeToFirebase(PetCareSupply supplyItem) async {
    try {
      await _firestore.collection('petSupplyType').add(supplyItem.toMap());
    } catch (error) {
      print('Error adding supply item to Firebase: $error');
      throw error;
    }
  }

    Future<void> updateSupplyItemTypeInFirebase(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('petSupplyType').doc(id).update(data);
      print("Supply item updated successfully.");
    } catch (e) {
      print("Error updating supply item: $e");
      throw e; 
    }
  }

}

