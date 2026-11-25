import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:more_fish/core/localization/app_translations.dart';

class LiveMonitoringPage extends StatefulWidget {
  const LiveMonitoringPage({super.key});

  @override
  State<LiveMonitoringPage> createState() => _LiveMonitoringPageState();
}

class _LiveMonitoringPageState extends State<LiveMonitoringPage> {
  static const _pondNames = ['WorldFish_Diapara_Bagerhat'];
  String _selectedPond = _pondNames.first;

  static const _sensors = [
    _SensorReading(
      name: 'DO',
      value: '3.30',
      unit: 'ppm',
      icon: Icons.water,
      color: Color(0xFFFF453A),
    ),
    _SensorReading(
      name: 'Temperature',
      value: '23.20',
      unit: '°C',
      icon: Icons.thermostat,
      color: Color(0xFFFF453A),
    ),
    _SensorReading(
      name: 'pH',
      value: '8.54',
      unit: 'H+',
      icon: Icons.water_drop_outlined,
      color: Color(0xFFFF453A),
    ),
    _SensorReading(
      name: 'TDS',
      value: '475.00',
      unit: 'mg/L',
      icon: Icons.opacity,
      color: Color(0xFF00C853),
    ),
    _SensorReading(
      name: 'Salinity',
      value: '0.06',
      unit: 'ppt',
      icon: Icons.water_drop,
      color: Color(0xFFFF453A),
    ),
    _SensorReading(
      name: 'NH3',
      value: '0.03',
      unit: 'mg/L',
      icon: Icons.bubble_chart_outlined,
      color: Color(0xFF00C853),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F5),
      appBar: AppBar(
        title: Text('Live data Monitoring'.tr),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
        children: [
          _pondSelector(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 15,
                      color: Color(0xFF00C853),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        appText('Mohammad_S...'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF0875C1),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        appText('25 Nov 2026 10:29 AM'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF0875C1),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                const Divider(
                  height: 1,
                  thickness: 1.5,
                  color: Color(0xFF0875C1),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sensors.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.32,
                  ),
                  itemBuilder: (context, index) =>
                      _SensorCard(sensor: _sensors[index]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 72),
          const _AeratorSwitch(),
          const SizedBox(height: 18),
          const _CleanerStatus(),
          const SizedBox(height: 22),
          const _WaterWarning(),
        ],
      ),
    );
  }

  Widget _pondSelector() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPond,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 28),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          items: _pondNames
              .map(
                (pond) => DropdownMenuItem<String>(
                  value: pond,
                  child: Text(
                    appText(pond),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (pond) {
            if (pond != null) {
              setState(() => _selectedPond = pond);
            }
          },
        ),
      ),
    );
  }
}

class _AeratorSwitch extends StatefulWidget {
  const _AeratorSwitch();

  @override
  State<_AeratorSwitch> createState() => _AeratorSwitchState();
}

class _AeratorSwitchState extends State<_AeratorSwitch> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = _isOn
        ? const Color(0xFF00C853)
        : const Color(0xFFE74C3C);

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEFCFC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFCAD6D9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 17, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aerator Switch'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          Switch(
            value: _isOn,
            activeThumbColor: const Color(0xFF00C853),
            activeTrackColor: const Color(0xFFB9F6CA),
            inactiveThumbColor: const Color(0xFFE74C3C),
            inactiveTrackColor: const Color(0xFFFFDADA),
            onChanged: (value) => setState(() => _isOn = value),
          ),
        ],
      ),
    );
  }
}

class _SensorReading {
  const _SensorReading({
    required this.name,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String name;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.sensor});

  final _SensorReading sensor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEFCFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCAD6D9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(sensor.icon, size: 31, color: const Color(0xFF159BD0)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: sensor.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(text: appText(sensor.value)),
                  TextSpan(
                    text: ' ${appText(sensor.unit)}',
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sensor.name.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanerStatus extends StatelessWidget {
  const _CleanerStatus();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEFCFC),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFCAD6D9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.circle, size: 17, color: Color(0xFF9E9E9E)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Auto-Cleaner'.tr,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Off'.tr,
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Run: 25 Nov 2026 10:00 AM'.tr,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Every day at 2:00 PM Bangladesh time, the cleaner turns ON.'
                    .tr,
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaterWarning extends StatelessWidget {
  const _WaterWarning();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('⚠️ ', style: TextStyle(fontSize: 14)),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Warning: '.tr,
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'Add TSP, gypsum, vinegar, or deep tube-well water.'.tr,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}
