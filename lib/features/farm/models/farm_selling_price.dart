class FarmSellingPrice {
  const FarmSellingPrice({
    required this.id,
    required this.farmId,
    required this.stockingBatch,
    required this.pricePerKg,
    required this.date,
  });

  final String id;
  final String farmId;
  final String stockingBatch;
  final double pricePerKg;
  final DateTime date;

  FarmSellingPrice copyWith({
    String? id,
    String? farmId,
    String? stockingBatch,
    double? pricePerKg,
    DateTime? date,
  }) {
    return FarmSellingPrice(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      stockingBatch: stockingBatch ?? this.stockingBatch,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      date: date ?? this.date,
    );
  }
}
