import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:more_fish/core/localization/app_translations.dart';

import '../../controllers/pond_detail_controller.dart';
import '../../models/pond_detail_models.dart';

class PondDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tag = '$farmName-$pondName';
    final controller = Get.isRegistered<PondDetailController>(tag: tag)
        ? Get.find<PondDetailController>(tag: tag)
        : Get.put(
            PondDetailController(
              pondName: pondName,
              farmName: farmName,
              initialData: data,
            ),
            tag: tag,
          );

    final isMobile = MediaQuery.sizeOf(context).width < 760;
    return Obx(() {
      final pondData = controller.data.value;
      if (pondData == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        backgroundColor: const Color(0xFFEAF1F5),
        body: SafeArea(
          child: Column(
            children: [
              _PondHeader(
                pondName: pondData.pondName,
                onClose: () {
                  Get.delete<PondDetailController>(tag: tag);
                  Navigator.of(context).pop();
                },
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
                            data: pondData,
                            manualOn: controller.manualOn.value,
                            automationEnabled:
                                controller.automationEnabled.value,
                            minimumDo: controller.minimumDo,
                            maximumDo: controller.maximumDo,
                            onManualChanged: controller.setManual,
                            onAutomationChanged: controller.setAutomation,
                            onSave: () async {
                              FocusScope.of(context).unfocus();
                              final saved = await controller
                                  .saveAeratorSettings();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    saved
                                        ? appText('Aerator settings saved')
                                        : appText(
                                            'Unable to save aerator settings',
                                          ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _SensorSection(sensors: pondData.sensors),
                          const SizedBox(height: 16),
                          _BatchSection(data: pondData),
                          const SizedBox(height: 16),
                          _BatchMetrics(metrics: pondData.metrics),
                          const SizedBox(height: 16),
                          _BiomassChart(data: pondData),
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
    });
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
                appText(pondName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: appText('Close'),
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
          Text(
            appText('Manual ON / OFF'),
            style: TextStyle(
              color: Color(0xFF34495E),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appText('Instant manual aerator switch'),
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
                        appText(data.aeratorName),
                        style: TextStyle(
                          color: Color(0xFF2B4158),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        manualOn
                            ? appText('Currently ON - Online')
                            : appText('Currently OFF - Offline'),
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
            Text(
              appText('Manual switch locked while DO automation is ON.'),
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
                      appText('DO-based Automation'),
                      style: TextStyle(
                        color: Color(0xFF34495E),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      appText('Auto aerator control by DO level'),
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
              Text(
                appText('ENABLE'),
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
            child: Text(
              appText('DO below minimum  → ON · DO above maximum → OFF'),
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
                  appText(
                    '${appText('Live DO')}: ${data.liveDo.toStringAsFixed(2)} mg/L · ${appText(data.isOnline ? 'Live' : 'Stale')}',
                  ),
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
                child: Text(
                  appText('Save Settings'),
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
            title: appText('Aerator Control'),
            subtitle: appText('Manual ON/OFF & dissolved oxygen automation'),
            trailing:
                '${appText('Device')} #${appText(data.deviceNumber.toString())}',
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
          appText(label),
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
              Expanded(
                child: Text(
                  appText('All Live IoT Water Sensors'),
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
                child: Text(
                  appText('Offline'),
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
                            appText(sensor.label),
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
                      appText(sensor.value),
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
            '${appText('ALL BATCHES & SPACES IN')} ${appText(data.pondName.toUpperCase())} (${appText('1')})',
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
                        appText(data.batchName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${appText(data.cultureZone)} · ${appText(data.batchName)}',
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
        Text(
          appText('Batch Performance'),
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
                    appText(metric.label),
                    style: const TextStyle(
                      color: Color(0xFF34495E),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    appText(metric.value),
                    style: const TextStyle(
                      color: Color(0xFF1C2E40),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appText(metric.unit),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appText('Standing Biomass'),
                      style: TextStyle(
                        color: Color(0xFF1C2E40),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      appText('Current level and available 3-month projection'),
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
                        appText('CURRENT STANDING BIOMASS'),
                        style: TextStyle(
                          color: Color(0xFF8FA0B5),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        appText(
                          '${data.biomassValues.first.toStringAsFixed(1)} kg',
                        ),
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
                      child: Text(
                        appText('↗ +193.6 kg (3-Mo)'),
                        style: TextStyle(
                          color: Color(0xFF168C52),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
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
          appText(label),
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
        text: TextSpan(text: appText(text), style: labelStyle),
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
      for (final value in safeValues) appText('${value.toStringAsFixed(1)} kg'),
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
