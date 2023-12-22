enum BoxSize { small, large }
enum BoxType { cats, dogs, puppy, mix, medical, other }
enum BoxStatus { created, packing, packed, storage, sended, recived, rapported }
enum BoxLocation {office, elevator, basement }

class Box {
  String id; // Firebase document ID
  String boxID; // Simplified box ID
  String requestId; // Request document ID this box is connected to
  BoxSize size;
  BoxType type;
  BoxStatus status;
  BoxLocation location; 
  String comment;

  Box({
    required this.id,
    required this.boxID,
    required this.requestId, 
    required this.size, 
    required this.type, 
    required this.status,
    required this.location,
    required this.comment});

  // Method to convert box object to a map, useful for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boxID': boxID, 
      'requestId': requestId,
      'size': size.toString(),
      'type': type.toString(),
      'status': status.toString(),
      'location': location.toString(),
      'comment': comment
    };
  }

  // Method to create a box object from a map, useful when retrieving from Firebase
  factory Box.fromMap(Map<String, dynamic> map, String id) {
  return Box(
    id: id,
    boxID: map['boxID'] ?? '',
    requestId: map['requestId'],
    size: BoxSize.values.firstWhere(
      (e) => e.toString() == 'BoxSize.' + (map['size'] ?? 'small'), // Default to small if size is not found
      orElse: () => BoxSize.small,
    ),
    type: BoxType.values.firstWhere(
      (e) => e.toString() == 'BoxType.' + (map['type'] ?? 'other'), // Default to other if type is not found
      orElse: () => BoxType.other,
    ),
    status: BoxStatus.values.firstWhere(
      (e) => e.toString() == 'BoxStatus.' + (map['status'] ?? 'created'), // Default to created if status is not found
      orElse: () => BoxStatus.created,
    ),
    location: BoxLocation.values.firstWhere(
      (e) => e.toString() == 'BoxLocation.' + (map['location'] ?? 'office'), // Default to office if location is not found
      orElse: () => BoxLocation.office,
    ),
    comment: map['comment'] ?? ''
  );
  }
}
