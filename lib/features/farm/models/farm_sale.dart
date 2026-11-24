class FarmSale {
  const FarmSale({
    required this.id,
    required this.farmId,
    required this.stockingBatch,
    required this.date,
    required this.weightSold,
    required this.fishCount,
    required this.pricePerKg,
    required this.buyerName,
  });

  final String id;
  final String farmId;
  final String stockingBatch;
  final DateTime date;
  final double weightSold;
  final int? fishCount;
  final double pricePerKg;
  final String buyerName;

  double get revenue => weightSold * pricePerKg;
}
