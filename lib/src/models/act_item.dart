class ActItem {
  int number;
  final String description;
  final String units;
  final String packing;
  final String type;
  double quantity;
  double nettoWeight;

  ActItem({
    required this.number,
    required this.description,
    required this.units,
    required this.packing,
    required this.type,
    required this.quantity,
    required this.nettoWeight,
  });
}
