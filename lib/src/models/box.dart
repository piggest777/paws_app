import 'package:cloud_firestore/cloud_firestore.dart';

enum BoxSize { small, large }
enum BoxType { cats, dogs, puppy, mix, medical, other }
enum BoxStatus { created, packing, packed, storage, readyForShipment, sended, recived, rapported }
enum BoxLocation {office, elevator, basement }

class Box {
  String id; // Firebase document ID
  int boxID; // Simplified box ID
  String requestId; // Request document ID this box is connected to
  bool isDirectToPerson;
  String? organizationName;
  DateTime? creationDate; // Field for creation date
  DateTime? packingDate; // Field for packing date
  DateTime? sendingDate; // Field for sending date
  String requesterName; // Field for requester's name
  BoxSize size;
  BoxType type;
  BoxStatus status;
  BoxLocation location; 
  String comment;
  double weight;
  double boxWeight;// Field for weight
  bool archived;

  Box({
    required this.id,
    required this.boxID,
    required this.requestId,
    this.isDirectToPerson = false,
    this.organizationName, 
    required this.size, 
    required this.type, 
    required this.status,
    required this.location,
    required this.comment,
    this.creationDate,
    required this.requesterName,
    this.weight = 0.0, // Default value for weight
    this.packingDate,
    this.sendingDate,
    this.boxWeight = 0.0,
    this.archived = false
    });

  // Method to convert box object to a map, useful for Firebase
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'boxID': boxID,
    'requestId': requestId,
    'isDirectToPerson': isDirectToPerson,
    'organizationName': organizationName,
    'size': size.toString().split('.').last, 
    'type': type.toString().split('.').last, 
    'status': status.toString().split('.').last,
    'location': location.toString().split('.').last,
    'comment': comment,
    'creationDate': creationDate ?? FieldValue.serverTimestamp(), // Use server timestamp if no date is provided
    'requesterName': requesterName,
    'weight': weight,
    'boxWeight': boxWeight,
    'archived' : false
  };
}

  // Method to create a box object from a map, useful when retrieving from Firebase
  factory Box.fromMap(Map<String, dynamic> map, String id) {
  return Box(
    id: id,
    boxID: map['boxID'] ?? '',
    requestId: map['requestId'],
    isDirectToPerson: map['isDirectToPerson'] ?? false,
    organizationName: map['organizationName'],
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
    comment: map['comment'] ?? '',
    creationDate: map['creationDate'] is Timestamp ? (map['creationDate'] as Timestamp).toDate() : null,
    requesterName: map['requesterName'] ?? '',
    weight: map['weight']?.toDouble() ?? 0.0, // Ensure you get a double
    packingDate: map['packingDate'] is Timestamp ? (map['packingDate'] as Timestamp).toDate() : null,
    sendingDate: map['sendingDate'] is Timestamp ? (map['sendingDate'] as Timestamp).toDate() : null,
    boxWeight: map['boxWeight']?.toDouble() ?? 0.0,
    archived: map['archived'] ?? false
  );
  }
}
