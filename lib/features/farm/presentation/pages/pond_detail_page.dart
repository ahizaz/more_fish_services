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

class PondDetailPage extends StatefulWidget {
  const PondDetailPage({
    super.key,
    required this.pondName,
    required this.farmName,
    this.data,
  });

  final String pondName;
  final String farmName;
  final PondDetailData? data;

  @override
  State<PondDetailPage> createState() => _PondDetailPageState();
}

class _PondDetailPageState extends State<PondDetailPage> {
  bool _automationEnabled = false;
  bool _manualOn = false;
  final TextEditingController _minimumDo = TextEditingController(text: '3');
  final TextEditingController _maximumDo = TextEditingController(text: '6');

  @override
  void dispose() {
    _minimumDo.dispose();
    _maximumDo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;
    final data =
        widget.data ??
        PondDetailData.demo(
          pondName: widget.pondName,
          farmName: widget.farmName,
        );

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F5),
      body: SafeArea(
        child: Column(
          children: [
            _PondHeader(
              pondName: data.pondName,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 32,
                  16,
                  isMobile ? 12 : 32,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AeratorCard(
                          data: data,
                          manualOn: _manualOn,
                          automationEnabled: _automationEnabled,
                          minimumDo: _minimumDo,
                          maximumDo: _maximumDo,
                          onManualChanged: (value) {
                            if (_automationEnabled) return;
                            setState(() => _manualOn = value);
                          },
                          onAutomationChanged: (value) {
                            setState(() {
                              _automationEnabled = value;
                              if (value) _manualOn = false;
                            });
                          },
                          onSave: () {
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Aerator settings saved'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _SensorSection(sensors: data.sensors),
                        const SizedBox(height: 16),
                        _BatchSection(data: data),
                        const SizedBox(height: 16),
                        _BatchMetrics(metrics: data.metrics),
                        const SizedBox(height: 16),
                        _BiomassChart(data: data),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PondHeader extends StatelessWidget {
  const _PondHeader({required this.pondName, required this.onClose});

  final String pondName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF183D74), Color(0xFF136DA3), Color(0xFF057FB0)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5CBF73),
                border: Border.all(color: const Color(0xFFFFD34E), width: 3),
              ),
              child: const Icon(Icons.waves_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                pondName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: onClose,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
              ),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _AeratorCard extends StatelessWidget {
  const _AeratorCard({
    required this.data,
    required this.manualOn,
    required this.automationEnabled,
    required this.minimumDo,
    required this.maximumDo,
    required this.onManualChanged,
    required this.onAutomationChanged,
    required this.onSave,
  });

  final PondDetailData data;
  final bool manualOn;
  final bool automationEnabled;
  final TextEditingController minimumDo;
  final TextEditingController maximumDo;
  final ValueChanged<bool> onManualChanged;
  final ValueChanged<bool> onAutomationChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;
    final manual = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manual ON / OFF',
            style: TextStyle(
              color: Color(0xFF34495E),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Instant manual aerator switch',
            style: TextStyle(
              color: Color(0xFF34495E),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.aeratorName,
                        style: TextStyle(
                          color: Color(0xFF2B4158),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        manualOn
                            ? 'Currently ON - Online'
                            : 'Currently OFF - Offline',
                        style: const TextStyle(
                          color: Color(0xFF60758A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: manualOn,
                  onChanged: automationEnabled ? null : onManualChanged,
                  activeThumbColor: const Color(0xFF18A0C7),
                ),
              ],
            ),
          ),
          if (automationEnabled) ...[
            const SizedBox(height: 10),
            const Text(
              'Manual switch locked while DO automation is ON.',
              style: TextStyle(
                color: Color(0xFF60758A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );

    final automation = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBEE9F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DO-based Automation',
                      style: TextStyle(
                        color: Color(0xFF34495E),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Auto aerator control by DO level',
                      style: TextStyle(
                        color: Color(0xFF34495E),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: automationEnabled,
                onChanged: (value) => onAutomationChanged(value ?? false),
                activeColor: const Color(0xFF16869F),
              ),
              const Text(
                'ENABLE',
                style: TextStyle(
                  color: Color(0xFF34495E),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DoField(label: 'DO MIN (MG/L)', controller: minimumDo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DoField(label: 'DO MAX (MG/L)', controller: maximumDo),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F8),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'DO below minimum  → ON · DO above maximum → OFF',
              style: TextStyle(
                color: Color(0xFF34495E),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Live DO: ${data.liveDo.toStringAsFixed(2)} mg/L · ${data.isOnline ? 'Live' : 'Stale'}',
                  style: TextStyle(
                    color: Color(0xFF34495E),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0784A3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(106, 34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F99A9).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.air,
            title: 'Aerator Control',
            subtitle: 'Manual ON/OFF & dissolved oxygen automation',
            trailing: 'Device #${data.deviceNumber}',
          ),
          const SizedBox(height: 14),
          if (isMobile)
            Column(children: [manual, const SizedBox(height: 12), automation])
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: manual),
                const SizedBox(width: 16),
                Expanded(child: automation),
              ],
            ),
        ],
      ),
    );
  }
}

class _DoField extends StatelessWidget {
  const _DoField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF34495E),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              filled: true,
              fillColor: const Color(0xFFF3F6F8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFBDE6F5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFF16869F),
                  width: 1.5,
                ),
              ),
            ),
            style: const TextStyle(
              color: Color(0xFF34495E),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFDDF3FA),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF16869F), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1C2E40),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF34495E),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: Color(0xFF60758A),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _SensorSection extends StatelessWidget {
  const _SensorSection({required this.sensors});

  final List<PondSensorData> sensors;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F99A9).withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.memory, color: Color(0xFF315BDA), size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'All Live IoT Water Sensors',
                  style: TextStyle(
                    color: Color(0xFF1C2E40),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F6EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Offline',
                  style: TextStyle(
                    color: Color(0xFF168C52),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sensors.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 78,
            ),
            itemBuilder: (_, index) {
              final sensor = sensors[index];
              return Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFEFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: switch (sensor.label) {
                      'TEMPERATURE' => const Color(0xFFFFD8CF),
                      'TDS' => const Color(0xFFFFDEB8),
                      'PH' => const Color(0xFFD7DEF8),
                      'DO' => const Color(0xFFCFEAFF),
                      'SALINITY' => const Color(0xFFCAECDD),
                      _ => const Color(0xFFE5D4F8),
                    },
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sensor.label,
                            style: const TextStyle(
                              color: Color(0xFF34495E),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Icon(sensor.icon, color: sensor.color, size: 15),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      sensor.value,
                      style: TextStyle(
                        color: sensor.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BatchSection extends StatelessWidget {
  const _BatchSection({required this.data});

  final PondDetailData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBDE6F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALL BATCHES & SPACES IN ${data.pondName.toUpperCase()} (1)',
            style: TextStyle(
              color: Color(0xFF34495E),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(minHeight: 70),
            width: 430,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2863E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.settings, color: Colors.white, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.batchName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${data.cultureZone} · ${data.batchName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchMetrics extends StatelessWidget {
  const _BatchMetrics({required this.metrics});

  final List<PondMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Batch Performance',
          style: TextStyle(
            color: Color(0xFF1C2E40),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 100,
          ),
          itemBuilder: (_, index) {
            final metric = metrics[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: index == 1
                      ? const Color(0xFFFFD8A6)
                      : index == 2
                      ? const Color(0xFFBDE3ED)
                      : index == 3
                      ? const Color(0xFFCFEDE1)
                      : const Color(0xFFE0E6EE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style: const TextStyle(
                      color: Color(0xFF34495E),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    metric.value,
                    style: const TextStyle(
                      color: Color(0xFF1C2E40),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.unit,
                    style: const TextStyle(
                      color: Color(0xFF34495E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BiomassChart extends StatelessWidget {
  const _BiomassChart({required this.data});

  final PondDetailData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCFEAF7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4F1FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.show_chart, color: Color(0xFF3D82E7)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standing Biomass',
                      style: TextStyle(
                        color: Color(0xFF1C2E40),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Current level and available 3-month projection',
                      style: TextStyle(
                        color: Color(0xFF34495E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFEFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E8EE)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT STANDING BIOMASS',
                        style: TextStyle(
                          color: Color(0xFF8FA0B5),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${data.biomassValues.first.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          color: Color(0xFF1C2E40),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F8EC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFB4EAD1)),
                      ),
                      child: const Text(
                        '↗ +193.6 kg (3-Mo)',
                        style: TextStyle(
                          color: Color(0xFF168C52),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LegendDot(color: Color(0xFF2877DD), label: 'Actual'),
                        SizedBox(width: 10),
                        _LegendDot(color: Color(0xFFF3A51A), label: 'Forecast'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _BiomassPainter(values: data.biomassValues)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF60758A),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BiomassPainter extends StatelessWidget {
  const _BiomassPainter({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BiomassChartPainter(values: values),
      child: const SizedBox.expand(),
    );
  }
}

class _BiomassChartPainter extends CustomPainter {
  const _BiomassChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 48.0;
    const right = 18.0;
    const top = 18.0;
    const bottom = 38.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final gridPaint = Paint()
      ..color = const Color(0xFFE6EDF3)
      ..strokeWidth = 1;
    for (final y in [0.0, 0.33, 0.66, 1.0]) {
      final yy = top + chartHeight * y;
      canvas.drawLine(
        Offset(left, yy),
        Offset(size.width - right, yy),
        gridPaint,
      );
    }

    final labelStyle = const TextStyle(
      color: Color(0xFF91A1B3),
      fontSize: 11,
      fontWeight: FontWeight.w800,
    );
    void label(String text, Offset offset) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, offset);
    }

    label('736', Offset(18, top - 6));
    label('490', Offset(18, top + chartHeight * 0.33 - 6));
    label('245', Offset(18, top + chartHeight * 0.66 - 6));
    label('0', Offset(30, top + chartHeight - 6));

    double yFor(double value) =>
        top + chartHeight - (value / 736 * chartHeight);
    final safeValues = <double>[
      ...values.take(4),
      ...List<double>.filled(values.length >= 4 ? 0 : 4 - values.length, 0),
    ];
    final points = [
      for (var i = 0; i < 4; i++)
        Offset(left + chartWidth * i / 3, yFor(safeValues[i])),
    ];

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height - bottom)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      fillPath.cubicTo(
        previous.dx + (current.dx - previous.dx) * 0.45,
        previous.dy,
        current.dx - (current.dx - previous.dx) * 0.45,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    fillPath.lineTo(points.last.dx, size.height - bottom);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x304A92D8), Color(0x0A4A92D8)],
        ).createShader(Rect.fromLTWH(left, top, chartWidth, chartHeight)),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      linePath.cubicTo(
        previous.dx + (current.dx - previous.dx) * 0.45,
        previous.dy,
        current.dx - (current.dx - previous.dx) * 0.45,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2877DD),
          Color(0xFF0F96BD),
          Color(0xFF68A4A4),
          Color(0xFFF3A51A),
        ],
      ).createShader(Rect.fromLTWH(left, 0, chartWidth, 1));
    canvas.drawPath(linePath, linePaint);

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final isForecast = i == 3;
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = isForecast
              ? const Color(0xFFF3A51A)
              : const Color(0xFF2877DD),
      );
    }

    final chartLabels = [
      for (final value in safeValues) '${value.toStringAsFixed(1)} kg',
    ];
    for (var i = 0; i < points.length; i++) {
      label(chartLabels[i], Offset(points[i].dx - 28, points[i].dy - 24));
    }

    const xLabels = ['Now', 'M1', 'M2', 'M3'];
    for (var i = 0; i < xLabels.length; i++) {
      final dx = left + chartWidth * i / 3 - (i == 0 ? 0 : 10);
      label(xLabels[i], Offset(dx, size.height - bottom + 10));
    }
  }

  @override
  bool shouldRepaint(covariant _BiomassChartPainter oldDelegate) =>
      oldDelegate.values != values;
}
