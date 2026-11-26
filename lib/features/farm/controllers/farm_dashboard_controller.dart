import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/api/api.dart';
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

  final RxList<Stocking> stockings = <Stocking>[].obs;

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
    unawaited(loadDashboard());
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

  Future<void> loadDashboard({http.Client? client}) async {
    try {
      final farmResponse = await Api.getFarms(client: client);
      if (farmResponse.statusCode < 200 || farmResponse.statusCode >= 300) {
        debugPrint(
          'Farm list API response: '
          '${farmResponse.statusCode} ${farmResponse.body}',
        );
        return;
      }

      final pondResponse = await Api.getPonds(client: client);
      if (pondResponse.statusCode < 200 || pondResponse.statusCode >= 300) {
        debugPrint(
          'Pond list API response: '
          '${pondResponse.statusCode} ${pondResponse.body}',
        );
        return;
      }

      final loadedFarms = _decodeCollection(
        farmResponse.body,
        'farms',
      ).map(_farmFromJson).toList();
      final loadedPonds = _decodeCollection(
        pondResponse.body,
        'ponds',
      ).map(_pondFromJson).toList();
      farms.assignAll(loadedFarms);
      ponds.assignAll(loadedPonds);

      if (farms.isEmpty) {
        selectedFarmId.value = null;
      } else if (!farms.any((farm) => farm.id == selectedFarmId.value)) {
        selectedFarmId.value = farms.first.id;
      }
    } on FormatException catch (error) {
      debugPrint('Dashboard API returned invalid data: $error');
    } on TimeoutException catch (error) {
      debugPrint('Dashboard API request timed out: $error');
    } on http.ClientException catch (error) {
      debugPrint('Dashboard API connection failed: $error');
    } on StateError catch (error) {
      debugPrint('Dashboard API authorization failed: $error');
    }
  }

  Future<Farm?> createFarmApi(Farm farm, {http.Client? client}) async {
    final requestBody = {'name': farm.name, 'location': farm.location};
    debugPrint('POST ${Api.farmsUri}');
    debugPrint('Farm request body: ${jsonEncode(requestBody)}');

    try {
      final response = await Api.createFarm(
        name: farm.name,
        location: farm.location,
        client: client,
      );
      debugPrint('Farm API response: ${response.statusCode} ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final responseBody = jsonDecode(response.body);
      if (responseBody is! Map<String, dynamic> || responseBody['id'] is! int) {
        debugPrint('Farm API response is missing an integer id.');
        return null;
      }

      return Farm(
        id: responseBody['id'].toString(),
        name: farm.name,
        location: farm.location,
      );
    } on FormatException catch (error) {
      debugPrint('Farm API returned invalid JSON: $error');
      return null;
    } on TimeoutException catch (error) {
      debugPrint('Farm API request timed out: $error');
      return null;
    } on http.ClientException catch (error) {
      debugPrint('Farm API connection failed: $error');
      return null;
    } on StateError catch (error) {
      debugPrint('Farm API authorization failed: $error');
      return null;
    }
  }

  Future<Pond?> createPondApi(Pond pond, {http.Client? client}) async {
    final farmId = int.tryParse(pond.farmId);
    if (farmId == null) {
      debugPrint('Pond API request skipped: farm ID must be an integer.');
      return null;
    }
    if (pond.imageName != null &&
        (pond.imagePath == null || pond.imagePath!.isEmpty)) {
      debugPrint(
        'Pond API request skipped: selected image path is unavailable.',
      );
      return null;
    }

    final requestBody = <String, Object>{
      'farm': farmId,
      'name': pond.name,
      if (pond.area.isNotEmpty) 'area': pond.area,
      'area_unit': pond.areaUnit,
      if (pond.imagePath != null) 'image': pond.imageName ?? 'selected image',
    };
    debugPrint('POST ${Api.pondsUri}');
    debugPrint('Pond request body: ${jsonEncode(requestBody)}');

    try {
      final response = await Api.createPond(
        farm: farmId,
        name: pond.name,
        area: pond.area,
        areaUnit: pond.areaUnit,
        imagePath: pond.imagePath,
        client: client,
      );
      debugPrint('Pond API response: ${response.statusCode} ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final createdPond = _pondFromJson(jsonDecode(response.body));
      return await _getPondDetails(createdPond.id, client: client) ??
          createdPond;
    } on FormatException catch (error) {
      debugPrint('Pond API returned invalid data: $error');
      return null;
    } on TimeoutException catch (error) {
      debugPrint('Pond API request timed out: $error');
      return null;
    } on http.ClientException catch (error) {
      debugPrint('Pond API connection failed: $error');
      return null;
    } on StateError catch (error) {
      debugPrint('Pond API authorization failed: $error');
      return null;
    }
  }

  Future<Pond?> _getPondDetails(String id, {http.Client? client}) async {
    try {
      final response = await Api.getPond(id: id, client: client);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Pond detail API response: ${response.statusCode} ${response.body}',
        );
        return null;
      }
      return _pondFromJson(jsonDecode(response.body));
    } on FormatException catch (error) {
      debugPrint('Pond detail API returned invalid data: $error');
      return null;
    } on TimeoutException catch (error) {
      debugPrint('Pond detail API request timed out: $error');
      return null;
    } on http.ClientException catch (error) {
      debugPrint('Pond detail API connection failed: $error');
      return null;
    } on StateError catch (error) {
      debugPrint('Pond detail API authorization failed: $error');
      return null;
    }
  }

  Future<Stocking?> saveStockingApi(
    Stocking stocking, {
    http.Client? client,
  }) async {
    final space = int.tryParse(stocking.spaceId ?? '');
    if (space == null) {
      debugPrint(
        'Stocking API request skipped: pond/space ID must be an integer.',
      );
      return null;
    }

    final clientRequestId = _newClientRequestId();
    final requestBody = {
      'space': space,
      'species': stocking.species,
      'batch_name': stocking.batchName,
      'stocked_count': stocking.count,
      'initial_weight_g': stocking.initialWeight,
      'stocking_date': _apiDate(stocking.date),
      'seed_cost_bdt': '',
      'client_request_id': clientRequestId,
    };
    debugPrint('POST ${Api.stockingsUri}');
    debugPrint('Stocking request body: ${jsonEncode(requestBody)}');

    try {
      final response = await Api.createStocking(
        space: space,
        species: stocking.species,
        batchName: stocking.batchName,
        stockedCount: stocking.count,
        initialWeightG: stocking.initialWeight,
        stockingDate: _apiDate(stocking.date),
        seedCostBdt: '',
        clientRequestId: clientRequestId,
        client: client,
      );
      debugPrint(
        'Stocking API response: ${response.statusCode} ${response.body}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      return _stockingFromJson(jsonDecode(response.body), fallback: stocking);
    } on FormatException catch (error) {
      debugPrint('Stocking API returned invalid data: $error');
      return null;
    } on TimeoutException catch (error) {
      debugPrint('Stocking API request timed out: $error');
      return null;
    } on http.ClientException catch (error) {
      debugPrint('Stocking API connection failed: $error');
      return null;
    } on StateError catch (error) {
      debugPrint('Stocking API authorization failed: $error');
      return null;
    }
  }

  Future<List<Stocking>?> loadStockingHistory(
    List<Stocking> stockings, {
    http.Client? client,
  }) async {
    final history = <Stocking>[];
    for (final stocking in stockings) {
      debugPrint('GET ${Api.stockingUri(stocking.id)}');
      try {
        final response = await Api.getStocking(id: stocking.id, client: client);
        debugPrint(
          'Stocking detail API response: '
          '${response.statusCode} ${response.body}',
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          return null;
        }
        history.add(
          _stockingFromJson(jsonDecode(response.body), fallback: stocking),
        );
      } on FormatException catch (error) {
        debugPrint('Stocking detail API returned invalid data: $error');
        return null;
      } on TimeoutException catch (error) {
        debugPrint('Stocking detail API request timed out: $error');
        return null;
      } on http.ClientException catch (error) {
        debugPrint('Stocking detail API connection failed: $error');
        return null;
      } on StateError catch (error) {
        debugPrint('Stocking detail API authorization failed: $error');
        return null;
      }
    }
    return history;
  }

  Future<bool> saveWeeklyUpdateApi(WeeklyUpdate update) async => true;
  Future<bool> saveFeedInventoryApi(FeedInventory inventory) async => true;
  Future<bool> saveFeedStockApi(FeedStockAddition addition) async => true;
}

Stocking _stockingFromJson(dynamic value, {required Stocking fallback}) {
  if (value is Map<String, dynamic> && value['data'] is Map<String, dynamic>) {
    value = value['data'];
  }
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Invalid stocking item.');
  }

  final count = _numberValue(value['stocked_count'])?.toInt();
  final weight = _numberValue(value['initial_weight_g']);
  final dateValue = value['stocking_date'];
  final date = dateValue is String ? DateTime.tryParse(dateValue) : null;
  final spaceValue = value['space'];
  return Stocking(
    id: _idString(value['id'], 'stocking'),
    farmName: value['farm_name'] is String
        ? value['farm_name'] as String
        : fallback.farmName,
    pondName: value['pond_name'] is String
        ? value['pond_name'] as String
        : fallback.pondName,
    species: value['species'] is String
        ? value['species'] as String
        : fallback.species,
    batchName: value['batch_name'] is String
        ? value['batch_name'] as String
        : fallback.batchName,
    count: count ?? fallback.count,
    initialWeight: weight?.toDouble() ?? fallback.initialWeight,
    date: date ?? fallback.date,
    spaceId: spaceValue == null
        ? fallback.spaceId
        : _idString(spaceValue, 'stocking space'),
  );
}

num? _numberValue(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

String _apiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _newClientRequestId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
  final value = hex.join();
  return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
      '${value.substring(12, 16)}-${value.substring(16, 20)}-'
      '${value.substring(20)}';
}

List<dynamic> _decodeCollection(String body, String endpoint) {
  final decoded = jsonDecode(body);
  dynamic records = decoded;
  if (decoded is Map<String, dynamic>) {
    records = decoded['results'] ?? decoded['data'];
  }
  if (records is! List<dynamic>) {
    throw FormatException('The $endpoint response is not a list.');
  }
  return records;
}

Farm _farmFromJson(dynamic value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Invalid farm item.');
  }
  final name = value['name'];
  final location = value['location'];
  if (name is! String || location is! String) {
    throw const FormatException('Farm item is missing name or location.');
  }
  return Farm(
    id: _idString(value['id'], 'farm'),
    name: name,
    location: location,
  );
}

Pond _pondFromJson(dynamic value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Invalid pond item.');
  }
  final name = value['name'];
  final areaUnit = value['area_unit'];
  final area = value['area'];
  final image = value['image'];
  final imageUrl = value['image_url'];
  if (name is! String ||
      areaUnit is! String ||
      (area != null && area is! num && area is! String)) {
    throw const FormatException('Pond item is missing valid required fields.');
  }
  return Pond(
    id: _idString(value['id'], 'pond'),
    farmId: _idString(value['farm'], 'pond farm'),
    name: name,
    area: area?.toString() ?? '',
    areaUnit: areaUnit,
    status: value['status'] is String ? value['status'] as String : 'Active',
    imageUrl: imageUrl is String
        ? imageUrl
        : image is String
        ? image
        : null,
  );
}

String _idString(dynamic value, String entity) {
  if (value is int) return value.toString();
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('The $entity response is missing an id.');
}
