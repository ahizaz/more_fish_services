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
}
