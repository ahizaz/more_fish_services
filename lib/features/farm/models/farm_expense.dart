class FarmExpense {
  const FarmExpense({
    required this.id,
    required this.farmId,
    required this.stockingBatch,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  final String id;
  final String farmId;
  final String stockingBatch;
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  FarmExpense copyWith({
    String? id,
    String? farmId,
    String? stockingBatch,
    String? category,
    double? amount,
    DateTime? date,
    String? description,
  }) {
    return FarmExpense(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      stockingBatch: stockingBatch ?? this.stockingBatch,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
