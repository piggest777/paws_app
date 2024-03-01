import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/act_item.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/services/act_item_converter.dart';

class DeliveryItemAggregator {
  final FirebaseFirestore firestore;

  DeliveryItemAggregator({required this.firestore});

  Future<AggregationResult> aggregateItems(String batchDeliveryId) async {
    Map<String, ActItemSummary> summary = {};
    double totalWeight = 0.0; // Initialize total weight

    // Fetch all boxes for the given batchDeliveryId
    var boxesSnapshot = await firestore
        .collection('boxes')
        .where('batchId', isEqualTo: batchDeliveryId)
        .get();

    // Iterate through boxes to fetch items
    for (var boxDoc in boxesSnapshot.docs) {
      var boxId = boxDoc.id;
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
            quantity: actItem.quantity,
            totalWeight: actItem.nettoWeight,
          );
        } else {
          summary[actItem.description]!.quantity += actItem.quantity;
          summary[actItem.description]!.totalWeight += actItem.nettoWeight;
        }

        totalWeight += actItem.nettoWeight; // Accumulate total weight
      }
    }

    print("Total Weight: $totalWeight kg"); // Print or return this value as needed

    return AggregationResult(summary: summary, totalWeight: totalWeight);
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
  double quantity;
  double totalWeight;

  ActItemSummary({
    required this.description,
    required this.units,
    required this.quantity,
    required this.totalWeight,
  });
}
