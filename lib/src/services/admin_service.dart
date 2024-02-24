import 'package:cloud_firestore/cloud_firestore.dart';

class PetSupplyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateSuppliesForWhom() async {
    const Map<String, String> typeMappings = {
      'food' : 'Food',

      // Add more mappings as needed
    };

    QuerySnapshot snapshot = await _db
        .collection('petSupplyType')
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String name = data['name'].toString().toLowerCase();
      
      for (var entry in typeMappings.entries) {
        if (name.contains(entry.key)) {
          // Update the document if name contains one of the keywords
          doc.reference.update({'supplyType': 'Food'});
          print('${doc.id} with $name updated');
          break; // Stop checking other entries if a match is found
        }
      }
    }
  }
}
