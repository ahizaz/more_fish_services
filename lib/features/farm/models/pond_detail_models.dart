import 'package:flutter/material.dart';

class PondSensorData {
  const PondSensorData({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
}

class PondMetricData {
  const PondMetricData({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;
}

class PondDetailData {
  const PondDetailData({
    required this.pondName,
    required this.farmName,
    required this.aeratorName,
    required this.deviceNumber,
    required this.liveDo,
    required this.isOnline,
    required this.sensors,
    required this.batchName,
    required this.cultureZone,
    required this.metrics,
    required this.biomassValues,
  });

  final String pondName;
  final String farmName;
  final String aeratorName;
  final String deviceNumber;
  final double liveDo;
  final bool isOnline;
  final List<PondSensorData> sensors;
  final String batchName;
  final String cultureZone;
  final List<PondMetricData> metrics;
  final List<double> biomassValues;

  factory PondDetailData.demo({
    required String pondName,
    required String farmName,
  }) {
    return PondDetailData(
      pondName: pondName,
      farmName: farmName,
      aeratorName: 'final_aerator_name',
      deviceNumber: '3',
      liveDo: 4.42,
      isOnline: false,
      sensors: const [
        PondSensorData(
          label: 'PH',
          value: '8.57 ph',
          color: Color(0xFF315BDA),
          icon: Icons.science_outlined,
        ),
        PondSensorData(
          label: 'TEMPERATURE',
          value: '26.0 °C',
          color: Color(0xFFE06C5C),
          icon: Icons.thermostat,
        ),
        PondSensorData(
          label: 'DO',
          value: '4.42 mg/L',
          color: Color(0xFF1887E8),
          icon: Icons.water_drop_outlined,
        ),
        PondSensorData(
          label: 'TDS',
          value: '481.0 ppm',
          color: Color(0xFFB56A16),
          icon: Icons.layers_outlined,
        ),
        PondSensorData(
          label: 'SALINITY',
          value: '0.062 ppt',
          color: Color(0xFF00A67E),
          icon: Icons.blur_circular,
        ),
        PondSensorData(
          label: 'NH3',
          value: '0.3909 mg/L',
          color: Color(0xFF9B5DE5),
          icon: Icons.warning_amber_rounded,
        ),
      ],
      batchName: 'AquaNova Tilapia Batch 01',
      cultureZone: 'Blue Pearl Culture Zone',
      metrics: const [
        PondMetricData(label: 'STANDING STOCK', value: '1,158', unit: 'Fish'),
        PondMetricData(label: 'BIOMASS', value: '394.88', unit: 'kg'),
        PondMetricData(label: 'MEAN WEIGHT', value: '341', unit: 'g / fish'),
        PondMetricData(label: 'GROWTH', value: '1.86', unit: 'g / day'),
        PondMetricData(label: 'FCR', value: '1.29', unit: 'Feed Conversion'),
      ],
      biomassValues: const [394.9, 459.4, 523.9, 588.4],
    );
  }
}
