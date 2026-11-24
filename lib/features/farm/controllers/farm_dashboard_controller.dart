import 'package:get/get.dart';

import '../models/farm_models.dart';

class FarmDashboardController extends GetxController {
  final RxList<Farm> farms = <Farm>[
    const Farm(
      id: 'farm-1',
      name: 'AquaNova Fish Farm',
      location: 'Bangladesh',
    ),
  ].obs;

  final RxList<Pond> ponds = <Pond>[
    const Pond(
      id: 'pond-1',
      farmId: 'farm-1',
      name: 'Blue Pearl Pond',
      area: '2.00',
      areaUnit: 'DECIMAL',
      status: 'Active',
    ),
    const Pond(
      id: 'pond-2',
      farmId: 'farm-1',
      name: 'Green Valley Pond',
      area: '1.50',
      areaUnit: 'DECIMAL',
      status: 'Active',
    ),
  ].obs;

  final RxList<Stocking> stockings = <Stocking>[
    Stocking(
      id: 'stocking-1',
      farmName: 'AquaNova Fish Farm',
      pondName: 'Blue Pearl Pond',
      species: 'Tilapia',
      batchName: 'AquaNova Tilapia Batch 01',
      count: 1500,
      initialWeight: 150,
      date: DateTime(2026, 8, 1),
    ),
  ].obs;

  final RxList<WeeklyUpdate> weeklyUpdates = List.generate(
    10,
    (index) => WeeklyUpdate(
      id: 'update-$index',
      batchName: 'Batch #10',
      averageWeight: 341 - (index * 13),
      mortality: index % 4 == 2 ? 2 : 3,
      date: DateTime(2026, 11, 14).subtract(Duration(days: index * 7)),
    ),
  ).obs;

  final RxList<FeedInventory> feedInventories = <FeedInventory>[].obs;

  final RxnString selectedFarmId = RxnString();

  @override
  void onInit() {
    super.onInit();
    selectedFarmId.value = farms.first.id;
  }

  Farm get selectedFarm =>
      farms.firstWhere((farm) => farm.id == selectedFarmId.value);

  List<Pond> get selectedPonds =>
      ponds.where((pond) => pond.farmId == selectedFarmId.value).toList();

  int get activePondCount =>
      selectedPonds.where((pond) => pond.status == 'Active').length;

  void selectFarm(String? farmId) {
    if (farmId != null) selectedFarmId.value = farmId;
  }

  void addFarm(Farm farm) {
    farms.add(farm);
    selectedFarmId.value = farm.id;
  }

  void addPond(Pond pond) {
    ponds.add(pond);
    selectedFarmId.value = pond.farmId;
  }

  void upsertStocking(Stocking stocking) {
    final index = stockings.indexWhere((item) => item.id == stocking.id);
    if (index >= 0) {
      stockings[index] = stocking;
    } else {
      stockings.insert(0, stocking);
    }
  }

  void upsertWeeklyUpdate(WeeklyUpdate update) {
    final index = weeklyUpdates.indexWhere((item) => item.id == update.id);
    if (index >= 0) {
      weeklyUpdates[index] = update;
    } else {
      weeklyUpdates.insert(0, update);
    }
  }

  void addFeedInventory(FeedInventory inventory) {
    feedInventories.insert(0, inventory);
  }

  void addFeedStock(FeedStockAddition addition) {
    final index = feedInventories.indexWhere(
      (item) => item.id == addition.inventoryId,
    );
    if (index < 0) return;
    final inventory = feedInventories[index];
    feedInventories[index] = FeedInventory(
      id: inventory.id,
      farmId: inventory.farmId,
      farmName: inventory.farmName,
      feedType: inventory.feedType,
      brand: inventory.brand,
      marketPrice: inventory.marketPrice,
      purchasePrice: addition.purchasePrice,
      quantity: inventory.quantity + addition.quantity,
      purchaseDate: addition.purchaseDate,
    );
  }

  double get feedInStock =>
      feedInventories.fold(0, (sum, inventory) => sum + inventory.quantity);

  Future<void> loadDashboard() async {
    // API integration point: load farms, ponds, stockings, and weekly updates.
  }

  Future<bool> createFarmApi(Farm farm) async => true;
  Future<bool> createPondApi(Pond pond) async => true;
  Future<bool> saveStockingApi(Stocking stocking) async => true;
  Future<bool> saveWeeklyUpdateApi(WeeklyUpdate update) async => true;
  Future<bool> saveFeedInventoryApi(FeedInventory inventory) async => true;
  Future<bool> saveFeedStockApi(FeedStockAddition addition) async => true;
}
