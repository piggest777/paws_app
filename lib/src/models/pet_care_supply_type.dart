class PetCareSupply {
  final String id;
  final String name;
  final String? barcode;
  final double weight;
  final List<String> keywords;
  final String? manufacturer;
  double count; // Support for partial quantities
  final String? forWhom; // Targeted consumer (e.g., dogs, cats)
  final String? supplyType; // Type of supply (e.g., food, medical)
  final String? foodType; // Specific for food items (wet, dry)
  final String? packaging; // Packaging form
  final bool isGeneric;

  PetCareSupply({
    required this.id,
    required this.name,
    this.barcode,
    required this.weight,
    required this.keywords,
    this.manufacturer,
    this.count = 0.0,
    this.forWhom,
    this.supplyType,
    this.foodType,
    this.packaging,
    this.isGeneric = false,
  });

  factory PetCareSupply.fromMap(Map<String, dynamic> map, String id) {
    return PetCareSupply(
      id: id,
      name: map['name'] ?? '',
      barcode: map['barcode'],
      weight: (map['weight'] ?? 0.0).toDouble(),
      keywords: List<String>.from(map['keywords'] ?? []),
      manufacturer: map['manufacturer'],
      count: map['count'] != null ? (map['count'] is int ? (map['count'] as int).toDouble() : map['count'] as double) : 0.0,
      forWhom: map['forWhom'],
      supplyType: map['supplyType'], 
      foodType: map['foodType'], // This can be null for non-food items
      packaging: map['packaging'], 
      isGeneric: map['isGeneric'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'barcode': barcode,
      'weight': weight,
      'keywords': keywords,
      'manufacturer': manufacturer,
      'count': count,
      'forWhom': forWhom,
      'supplyType': supplyType,
      'foodType': foodType, 
      'packaging': packaging,
      'isGeneric': isGeneric,
    };
  }
}