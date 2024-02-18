import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';

class BoxItem {
  final String id;
  final String name;
  double count;
  final double basicWeight;
  final String boxId;
  // Additional fields from PetCareSupply
  final String? barcode;
  final List<String>? keywords;
  final String? manufacturer;
  final String? forWhom;
  final String? supplyType;
  final String? foodType;
  final String? packaging;

  BoxItem({
    required this.id,
    required this.name,
    required this.count,
    required this.basicWeight,
    required this.boxId,
    this.barcode,
    this.keywords,
    this.manufacturer,
    this.forWhom,
    this.supplyType,
    this.foodType,
    this.packaging,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'count': count,
      'basicWeight': basicWeight,
      'boxId': boxId,
      'barcode': barcode,
      'keywords': keywords,
      'manufacturer': manufacturer,
      'forWhom': forWhom,
      'supplyType': supplyType,
      'foodType': foodType,
      'packaging': packaging,
    };
  }

  factory BoxItem.fromMap(Map<String, dynamic> map, String id) {
    return BoxItem(
      id: id,
      name: map['name'],
      count: map['count'].toDouble(),
      basicWeight: map['basicWeight'].toDouble(),
      boxId: map['boxId'],
      barcode: map['barcode'],
      keywords: List<String>.from(map['keywords'] ?? []),
      manufacturer: map['manufacturer'],
      forWhom: map['forWhom'],
      supplyType: map['supplyType'],
      foodType: map['foodType'],
      packaging: map['packaging'],
    );
  }

    // Factory constructor to create BoxItem from PetCareSupply
  factory BoxItem.fromPetCareSupply(PetCareSupply supply, String boxId, double count) {
    return BoxItem(
      id: FirebaseFirestore.instance.collection('boxItems').doc().id, // Generate a unique ID for the BoxItem
      name: supply.name,
      count: count,
      basicWeight: supply.weight,
      boxId: boxId,
      barcode: supply.barcode,
      keywords: supply.keywords,
      manufacturer: supply.manufacturer,
      forWhom: supply.forWhom,
      supplyType: supply.supplyType,
      foodType: supply.foodType,
      packaging: supply.packaging,
    );
  }
}
