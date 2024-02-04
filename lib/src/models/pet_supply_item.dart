class SupplyItem {
  final String id;
  final String supplyItemTypeId; // ID of the supply item type in Firebase
  final String name;
  final double basicWeight; // Basic weight of one item
  final int count; // Count of items

  SupplyItem({
    required this.id,
    required this.supplyItemTypeId,
    required this.name,
    required this.basicWeight,
    required this.count,
  });

  factory SupplyItem.fromMap(Map<String, dynamic> map) {
    return SupplyItem(
      id: map['id'] ?? '',
      supplyItemTypeId: map['supplyItemTypeId'] ?? '',
      name: map['name'] ?? '',
      basicWeight: (map['basicWeight'] ?? 0.0).toDouble(),
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplyItemTypeId': supplyItemTypeId,
      'name': name,
      'basicWeight': basicWeight,
      'count': count,
    };
  }
}
