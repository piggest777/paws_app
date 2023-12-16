class Request {
  String id;
  String personId;
  String name;
  String surname;
  String region;
  String city;
  bool isUrgent;
  bool isRepeat;
  bool isProxy;
  String? organizationName; // Nullable since it's only needed if isProxy is true
  String comments;

  Request({
    required this.id,
    required this.personId,
    required this.name,
    required this.surname,
    required this.region,
    required this.city,
    required this.isUrgent,
    required this.isRepeat,
    required this.isProxy,
    this.organizationName,
    required this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'personId': personId,
      'name': name,
      'surname': surname,
      'region': region,
      'city': city,
      'isUrgent': isUrgent,
      'isRepeat': isRepeat,
      'isProxy': isProxy,
      'organizationName': isProxy ? organizationName : null, // Include only if isProxy is true
      'comments': comments,
    };
  }

    factory Request.fromMap(Map<String, dynamic> map, String id) {
    return Request(
      id: id,
      personId: map['personId'] ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      region: map['region'] ?? '',
      city: map['city'] ?? '',
      isUrgent: map['isUrgent'] ?? false,
      isRepeat: map['isRepeat'] ?? false,
      isProxy: map['isProxy'] ?? false,
      organizationName: map['organizationName'],
      comments: map['comments'] ?? '',
    );
  }
}
