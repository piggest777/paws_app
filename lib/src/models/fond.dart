class Fond {
  String name;
  String fondNumber;

  Fond({required this.name, required this.fondNumber});

  // Convert a Fond into a Map. The keys must correspond to the names of the
  // fields in your Firebase database.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fondNumber': fondNumber,
    };
  }

  // A method to create a Fond from a map
  factory Fond.fromMap(Map<String, dynamic> map) {
    return Fond(
      name: map['name'],
      fondNumber: map['fondNumber'],
    );
  }
}
