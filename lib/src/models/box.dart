enum BoxSize { small, large }
enum BoxType { cats, dogs, puppy, mix, medical, other }
enum BoxStatus { created, packed, storage, sended, recived, rapported }

class Box {
  String id; // Firebase document ID
  String boxID; // Simplified box ID
  String requestId; // Request document ID this box is connected to
  BoxSize size;
  BoxType type;
  BoxStatus status;
  String comment;

  Box({
    required this.id,
    required this.boxID,
    required this.requestId, 
    required this.size, 
    required this.type, 
    required this.status,
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
      'comment': comment
    };
  }

  // Method to create a box object from a map, useful when retrieving from Firebase
  factory Box.fromMap(Map<String, dynamic> map, String id) {
    return Box(
      id: id,
      boxID: map['boxID'] ?? '',
      requestId: map['requestId'],
      size: BoxSize.values.firstWhere((e) => e.toString() == map['size']),
      type: BoxType.values.firstWhere((e) => e.toString() == map['type']),
      status: BoxStatus.values.firstWhere((e) => e.toString() == map['status']),
      comment: map['comment'] ?? ''
    );
  }
}
