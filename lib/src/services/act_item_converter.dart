import 'package:paws_app/src/models/act_item.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/services/box_item_service.dart';

class ActItemConverter {
  static ActItem convertToActItem(BoxItem boxItem, int number) {

    String description = prepareDescription(boxItem);

    String units = "шт."; // Always 'шт.' according to your rules
    String packing = _getPacking(boxItem.supplyType, boxItem.packaging);
    String type = boxItem.supplyType ?? '';
    double quantity = boxItem.count; // Default quantity is 1
    double nettoWeight = boxItem.basicWeight * quantity; // Net weight

    return ActItem(
      number: number,
      description: description,
      units: units,
      packing: packing,
      type: type,
      quantity: quantity,
      nettoWeight: nettoWeight,
    );
  }

static String prepareDescription(BoxItem item) {
  final type = item.supplyType;
  switch (type) {
    case "Medical":
      return BoxItemService.getDescription(item);
    case "Care products":
      if (type == "Harness" || type == "Nail clippers" || type == "Brushes" || type == "Shampoo") {
        return BoxItemService.getItemTypeTranslation(type, null);
      } else {
        return BoxItemService.getDescription(item);
      }
    default: 
      return BoxItemService.getItemTypeTranslation(type, item.foodType);
  }
}

  static String _getPacking(String? supplyType, String? packaging) {
    // Define the types for which the packaging is always "Виріб"
    const typesWithFixedPacking = [
      "Medical",
      "Clothes",
      "Toys",
      "Leashes",
      "Collars",
      "Underlay",
      "Bowl",
      "Pet home",
      "Care products",
      "Pet carrier",
      "Cages",
    ];

    if (typesWithFixedPacking.contains(supplyType)) {
      return 'Виріб'; // Override the packaging type for specified item types
    } else {
      // For other types, determine packaging based on the item's packaging field
      switch (packaging) {
        case "Bags":
          return 'Пакунок';
        case "Jars":
          return 'Банка';
        default:
          return 'Виріб'; // Default packaging type if not specified
      }
    }
  }
}
