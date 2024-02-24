import 'package:paws_app/src/models/act_item.dart';
import 'package:paws_app/src/models/box_item.dart';

class ActItemConverter {
  static ActItem convertToActItem(BoxItem boxItem, int number) {
    String description = _getDescription(boxItem);
    String units = "шт."; // Always 'шт.' according to your rules
    String packing = _getPacking(boxItem.supplyType, boxItem.packaging);
    double quantity = boxItem.count; // Default quantity is 1
    double nettoWeight = boxItem.basicWeight * quantity; // Net weight

    return ActItem(
      number: number,
      description: description,
      units: units,
      packing: packing,
      quantity: quantity,
      nettoWeight: nettoWeight,
    );
  }

  static String _getDescription(BoxItem item) {
    switch (item.supplyType) {
      case "Food":
        if (item.foodType == "Wet") return 'м’який корм для тварин';
        if (item.foodType == "Dry") return 'сухий корм для тварин';
        return 'Їжа для тварин'; // Fallback for food without specific type

      case "Snacks":
        return 'Снек';

      case "Medical":
        return 'Медицина';

      case "Clothes":
        return 'Одяг для тварин';

      case "Toys":
        return 'Іграшки';

      case "Leashes":
        return 'Поводок';

      case "Collars":
        return 'Ошейник';

      case "Underlay":
        return 'Підстилка';

      case "Bowl":
        return 'Миска';

      case "Pet home":
        return 'Лежанка';

      case "Care products":
        return 'Засоби піклування для тварин';

      case "Pet carrier":
        return 'Переноска';

      case "Cages":
        return 'Клітка';

      default:
        return 'Різне'; // Fallback for unspecified or new types
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
