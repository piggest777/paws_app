class Request {
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
}
