class Farm {
  const Farm({required this.id, required this.name, required this.location});

  final String id;
  final String name;
  final String location;
}

class Pond {
  const Pond({
    required this.id,
    required this.farmId,
    required this.name,
    required this.area,
    required this.areaUnit,
    required this.status,
    this.imageName,
    this.imagePath,
    this.imageUrl,
  });

  final String id;
  final String farmId;
  final String name;
  final String area;
  final String areaUnit;
  final String status;
  final String? imageName;
  final String? imagePath;
  final String? imageUrl;
}

class Stocking {
  const Stocking({
    required this.id,
    required this.farmName,
    required this.pondName,
    required this.species,
    required this.batchName,
    required this.count,
    required this.initialWeight,
    required this.date,
  });

  final String id;
  final String farmName;
  final String pondName;
  final String species;
  final String batchName;
  final int count;
  final double initialWeight;
  final DateTime date;
}

class WeeklyUpdate {
  const WeeklyUpdate({
    required this.id,
    required this.batchName,
    required this.averageWeight,
    required this.mortality,
    required this.date,
  });

  final String id;
  final String batchName;
  final double averageWeight;
  final int mortality;
  final DateTime date;
}

class FeedInventory {
  const FeedInventory({
    required this.id,
    required this.farmId,
    required this.farmName,
    required this.feedType,
    required this.brand,
    required this.marketPrice,
    required this.purchasePrice,
    required this.quantity,
    required this.purchaseDate,
  });

  final String id;
  final String farmId;
  final String farmName;
  final String feedType;
  final String brand;
  final double marketPrice;
  final double purchasePrice;
  final double quantity;
  final DateTime purchaseDate;
}

class FeedStockAddition {
  const FeedStockAddition({
    required this.inventoryId,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
  });

  final String inventoryId;
  final double quantity;
  final double purchasePrice;
  final DateTime purchaseDate;
}
