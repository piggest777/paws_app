import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/act_item.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/services/act_item_converter.dart';

class DeliveryItemAggregator {
  final FirebaseFirestore firestore;

  DeliveryItemAggregator({required this.firestore});

Future<AggregationResult> aggregateItems(String batchDeliveryId) async {
  Map<String, ActItemSummary> summary = {};
  double totalItemsWeight = 0.0; // Initialize total items weight (netto)
  double totalPackageWeight = 0.0; // Initialize total package weight

  // Fetch all boxes for the given batchDeliveryId
  var boxesSnapshot = await firestore
      .collection('boxes')
      .where('batchId', isEqualTo: batchDeliveryId)
      .where('archived', isEqualTo: false)
      .get();

  // Iterate through boxes to fetch items and accumulate package weights
  for (var boxDoc in boxesSnapshot.docs) {
    var boxId = boxDoc.id;
    double boxWeight = (boxDoc.data()['boxWeight'] ?? 0).toDouble(); // Assume 'weight' field exists
    totalPackageWeight += boxWeight; // Accumulate total package weight

    var boxItemsSnapshot = await firestore
        .collection('boxItems')
        .where('boxId', isEqualTo: boxId)
        .get();

    // Convert each boxItem to actItem and aggregate
    for (var itemDoc in boxItemsSnapshot.docs) {
      BoxItem boxItem = BoxItem.fromMap(itemDoc.data(), itemDoc.id);
      ActItem actItem = ActItemConverter.convertToActItem(boxItem, 0); // Number not used in aggregation

      if (!summary.containsKey(actItem.description)) {
        summary[actItem.description] = ActItemSummary(
          description: actItem.description,
          units: actItem.units,
          type: actItem.type,
          quantity: actItem.quantity,
          totalWeight: actItem.nettoWeight,
        );
      } else {
        summary[actItem.description]!.quantity += actItem.quantity;
        summary[actItem.description]!.totalWeight += actItem.nettoWeight;
      }

      totalItemsWeight += actItem.nettoWeight; // Accumulate total items weight (netto)
    }
  }

  // Now adjust each item's weight to include a share of the package weight
  double totalWeightBrutto = totalItemsWeight + totalPackageWeight;
  Map<String, ActItemSummary> adjustedSummary = _adjustItemsWithPackageWeight(summary, totalPackageWeight, totalItemsWeight);

  print("Total Netto Weight: $totalItemsWeight kg, Total Package Weight: $totalPackageWeight kg, Total Brutto Weight: $totalWeightBrutto kg"); // For debugging

  return AggregationResult(summary: adjustedSummary, totalWeight: totalWeightBrutto);
}

Map<String, ActItemSummary> _adjustItemsWithPackageWeight(Map<String, ActItemSummary> summary, double totalPackageWeight, double totalItemsWeight) {
  Map<String, ActItemSummary> adjustedSummary = {};

  summary.forEach((description, actItemSummary) {
    // Calculate this item's proportion of the total items weight
    double proportion = actItemSummary.totalWeight / totalItemsWeight;

    // Calculate the additional weight from the package to distribute to this item
    double additionalWeight = totalPackageWeight * proportion;

    // Create a new summary entry with the adjusted weight
    adjustedSummary[description] = ActItemSummary(
      description: actItemSummary.description,
      units: actItemSummary.units,
      type: actItemSummary.type,
      quantity: actItemSummary.quantity,
      totalWeight: actItemSummary.totalWeight + additionalWeight, // Adjust the weight
    );
  });

  return adjustedSummary;
}

}

class AggregationResult {
  final Map<String, ActItemSummary> summary;
  final double totalWeight;

  AggregationResult({required this.summary, required this.totalWeight});
}


class ActItemSummary {
  String description;
  String units;
  String type;
  double quantity;
  double totalWeight;

  ActItemSummary({
    required this.description,
    required this.units,
    required this.type,
    required this.quantity,
    required this.totalWeight,
  });
}
