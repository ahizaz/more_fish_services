import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:more_fish/core/api/api.dart';
import 'package:more_fish/features/farm/controllers/farm_dashboard_controller.dart';
import 'package:more_fish/features/farm/models/farm_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('createFarmApi keeps the server farm ID for pond creation', () async {
    SharedPreferences.setMockInitialValues({
      'Authorization': 'test-auth-token',
    });
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'id': 9,
          'name': 'izaz',
          'location': 'Bangladesh',
          'company': null,
          'users': [25],
          'created_at': '2026-11-26T06:51:33.577521Z',
          'updated_at': '2026-11-26T06:51:33.577521Z',
        }),
        201,
      );
    });

    final farm = await FarmDashboardController().createFarmApi(
      const Farm(id: 'temporary-id', name: 'izaz', location: 'Bangladesh'),
      client: client,
    );

    expect(farm?.id, '9');
    expect(farm?.name, 'izaz');
    expect(farm?.location, 'Bangladesh');
    client.close();
  });

  test('loadDashboard restores server farms and ponds', () async {
    SharedPreferences.setMockInitialValues({
      Api.authorizationKey: 'test-auth-token',
    });
    final client = MockClient((request) async {
      if (request.url == Api.farmsUri) {
        return http.Response(
          jsonEncode({
            'count': 1,
            'results': [
              {'id': 12, 'name': 'Aqua Farm', 'location': 'Bangladesh'},
            ],
          }),
          200,
        );
      }
      if (request.url == Api.pondsUri) {
        return http.Response(
          jsonEncode([
            {
              'id': 10,
              'farm': 12,
              'name': 'North Pond',
              'area': 2.0,
              'area_unit': 'ACRE',
              'image': null,
              'image_url': null,
            },
          ]),
          200,
        );
      }
      fail('Unexpected GET ${request.url}');
    });

    final controller = FarmDashboardController();
    await controller.loadDashboard(client: client);

    expect(controller.farms.single.id, '12');
    expect(controller.ponds.single.id, '10');
    expect(controller.ponds.single.farmId, '12');
    expect(controller.ponds.single.area, '2.0');
    expect(controller.selectedFarmId.value, '12');
    client.close();
  });

  test('createPondApi uploads the image and fetches the saved pond', () async {
    SharedPreferences.setMockInitialValues({
      Api.authorizationKey: 'test-auth-token',
    });
    final tempDirectory = await Directory.systemTemp.createTemp(
      'pond-controller-test-',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final imageFile = File(
      '${tempDirectory.path}${Platform.pathSeparator}pond.jpg',
    );
    await imageFile.writeAsString('image-data');
    var getDetailCalled = false;
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        expect(request.url, Api.pondsUri);
        expect(request.body, contains('name="farm"\r\n\r\n12'));
        expect(request.body, contains('name="area"\r\n\r\n2.00'));
        expect(request.body, contains('name="image"; filename="pond.jpg"'));
        expect(request.body, contains('image-data'));
        return http.Response(
          jsonEncode({
            'id': 10,
            'farm': 12,
            'name': 'North Pond',
            'area': '2.00',
            'area_unit': 'ACRE',
            'image': '/ponds/pond.jpg',
            'image_url': null,
          }),
          201,
        );
      }

      expect(request.method, 'GET');
      expect(request.url, Api.pondUri('10'));
      getDetailCalled = true;
      return http.Response(
        jsonEncode({
          'id': 10,
          'farm': 12,
          'name': 'North Pond',
          'area': '2.00',
          'area_unit': 'ACRE',
          'image': '/ponds/pond.jpg',
          'image_url': 'https://example.test/pond.jpg',
        }),
        200,
      );
    });

    final pond = await FarmDashboardController().createPondApi(
      Pond(
        id: 'temporary-id',
        farmId: '12',
        name: 'North Pond',
        area: '2.00',
        areaUnit: 'ACRE',
        status: 'Active',
        imageName: 'pond.jpg',
        imagePath: imageFile.path,
      ),
      client: client,
    );

    expect(getDetailCalled, isTrue);
    expect(pond?.id, '10');
    expect(pond?.imageUrl, 'https://example.test/pond.jpg');
    client.close();
  });

  test(
    'saveStockingApi posts the payload and uses the server ID for history',
    () async {
      SharedPreferences.setMockInitialValues({
        Api.authorizationKey: 'test-auth-token',
      });
      final client = MockClient((request) async {
        if (request.method == 'POST') {
          expect(request.url, Api.stockingsUri);
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['space'], 10);
          expect(body['species'], 'Tilapia');
          expect(body['batch_name'], 'North batch');
          expect(body['stocked_count'], 1200);
          expect(body['initial_weight_g'], 25.5);
          expect(body['stocking_date'], '2026-11-26');
          expect(body['seed_cost_bdt'], '');
          expect(
            body['client_request_id'],
            matches(
              RegExp(
                r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              ),
            ),
          );
          return http.Response(
            jsonEncode({
              'id': 42,
              'space': 10,
              'space_name': 'North Pond',
              'pond_name': 'North Pond',
              'farm_name': 'Aqua Farm',
              'species': 'Tilapia',
              'batch_name': 'North batch',
              'stocked_count': 1200,
              'initial_weight_g': '25.5',
              'stocking_date': '2026-11-26',
            }),
            201,
          );
        }

        expect(request.method, 'GET');
        expect(request.url, Api.stockingUri('42'));
        return http.Response(
          jsonEncode({
            'id': 42,
            'space': 10,
            'space_name': 'North Pond',
            'pond_name': 'North Pond',
            'farm_name': 'Aqua Farm',
            'species': 'Tilapia',
            'batch_name': 'North batch',
            'stocked_count': '1250',
            'initial_weight_g': '26.75',
            'stocking_date': '2026-11-26',
          }),
          200,
        );
      });

      final controller = FarmDashboardController();
      final created = await controller.saveStockingApi(
        Stocking(
          id: 'temporary-id',
          spaceId: '10',
          farmName: 'Aqua Farm',
          pondName: 'North Pond',
          species: 'Tilapia',
          batchName: 'North batch',
          count: 1200,
          initialWeight: 25.5,
          date: DateTime(2026, 11, 26),
        ),
        client: client,
      );

      expect(created?.id, '42');
      final history = await controller.loadStockingHistory([
        created!,
      ], client: client);
      expect(history?.single.id, '42');
      expect(history?.single.count, 1250);
      expect(history?.single.initialWeight, 26.75);
      client.close();
    },
  );
}
