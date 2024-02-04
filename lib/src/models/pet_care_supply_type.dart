class PetCareSupply {
  final String id;
  final String name;
  final String? barcode;
  final double weight;
  final List<String> keywords;
  final String? manufacturer;
  int count; // Added item counter

  PetCareSupply({
    required this.id,
    required this.name,
    this.barcode,
    required this.weight,
    required this.keywords,
    this.manufacturer,
    this.count = 0, // Default count to 0
  });

  // Create a PetCareSupply object from a map
  factory PetCareSupply.fromMap(Map<String, dynamic> map, String id) {
    return PetCareSupply(
      id: id,
      name: map['name'] ?? '',
      barcode: map['barcode'],
      weight: (map['weight'] ?? 0.0).toDouble(),
      keywords: List<String>.from(map['keywords'] ?? []),
      manufacturer: map['manufacturer'],
      count: map['count'] ?? 0, // Initialize count from the map
    );
  }

  // Convert a PetCareSupply object to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'barcode': barcode,
      'weight': weight,
      'keywords': keywords,
      'manufacturer': manufacturer,
      'count': count, // Include count in the map
    };
  }
}
