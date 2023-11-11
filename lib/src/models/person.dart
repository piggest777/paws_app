class Person {
  String id;
  String name;
  String surname;
  String region;
  String city;
  String novaPostBranch;
  String phone;

  Person({
    required this.id,
    required this.name,
    required this.surname,
    required this.region,
    required this.city,
    required this.novaPostBranch,
    required this.phone,
  });

    // Generate keywords for the name and surname
  List<String> _generateKeywords() {
    List<String> keywords = [];

    var temp = '';
    for (var char in name.toLowerCase().split('')) {
      temp += char;
      keywords.add(temp);
    }

    temp = '';
    for (var char in surname.toLowerCase().split('')) {
      temp += char;
      keywords.add(temp);
    }

    return keywords;
  }

  // Factory method to create a Person from a map (e.g., from Firebase)
  factory Person.fromMap(Map<String, dynamic> map, String id) {
    return Person(
      id: id,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      region: map['region'] ?? '',
      city: map['city'] ?? '',
      novaPostBranch: map['novaPostBranch'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  // Method to convert Person to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'region': region,
      'city': city,
      'novaPostBranch': novaPostBranch,
      'phone': phone,
      'keywords': _generateKeywords(),
    };
  }
}
