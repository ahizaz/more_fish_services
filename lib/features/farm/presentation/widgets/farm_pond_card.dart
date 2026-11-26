import 'package:flutter/material.dart';
import 'package:more_fish/core/api/api.dart';
import 'package:more_fish/core/localization/app_translations.dart';

import '../../models/farm_models.dart';
import '../pages/pond_detail_page.dart';

class FarmPondCard extends StatelessWidget {
  const FarmPondCard({super.key, required this.pond, required this.farmName});

  final Pond pond;
  final String farmName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF315BDA),
                      Color(0xFF1887E8),
                      Color(0xFF24A5D8),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    if (pond.imageUrl != null && pond.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _pondImageUrl(pond.imageUrl!),
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        appText(pond.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pond.area.isEmpty
                            ? appText(pond.areaUnit)
                            : '${pond.area} ${appText(pond.areaUnit)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFBF25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appText('ACTIVE'),
                        style: TextStyle(
                          color: Color(0xFF102A43),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sensors,
                            size: 14,
                            color: Color(0xFF315BDA),
                          ),
                          SizedBox(width: 6),
                          Text(
                            appText('LIVE SENSORS'),
                            style: TextStyle(
                              color: Color(0xFF315BDA),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Spacer(),
                          Text(
                            appText('Live'),
                            style: TextStyle(
                              color: Color(0xFF00A67E),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _SensorTile(
                              label: 'PH',
                              value: '8.5 ph',
                              color: Color(0xFF315BDA),
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: _SensorTile(
                              label: 'TEMPERATURE',
                              value: '25.8 C',
                              color: Color(0xFFE06C5C),
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: _SensorTile(
                              label: 'DO',
                              value: '5.46 mg/L',
                              color: Color(0xFF1887E8),
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: _SensorTile(
                              label: 'SALINITY',
                              value: '0.062 ppt',
                              color: Color(0xFF00A67E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 72,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appText('AquaNova Tilapia Batch 01'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF102A43),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    appText('Blue Pearl Culture Zone'),
                                    style: TextStyle(
                                      color: Color(0xFF66788A),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PondDetailPage(
                                      pondName: pond.name,
                                      farmName: farmName,
                                    ),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF315BDA),
                                minimumSize: const Size(82, 34),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                appText('View Pond'),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: _PondMetric(
                              label: 'STOCK',
                              value: '1,158 fish',
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: _PondMetric(
                              label: 'BIOMASS',
                              value: '394.88 kg',
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: _PondMetric(
                              label: 'MEAN WT',
                              value: '341 g',
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: _PondMetric(label: 'FCR', value: '1.29'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _pondImageUrl(String imageUrl) {
  final uri = Uri.tryParse(imageUrl);
  if (uri == null || uri.hasScheme) return imageUrl;
  return Uri.parse(Api.baseUrl).resolveUri(uri).toString();
}

class _SensorTile extends StatelessWidget {
  const _SensorTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appText(label),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            appText(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PondMetric extends StatelessWidget {
  const _PondMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              appText(label),
              style: const TextStyle(
                color: Color(0xFF7A8A99),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              appText(value),
              style: const TextStyle(
                color: Color(0xFF102A43),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FarmEmptyPonds extends StatelessWidget {
  const FarmEmptyPonds({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water, size: 44, color: Color(0xFF9FB4C7)),
          SizedBox(height: 10),
          Text(
            appText('No ponds added yet'),
            style: TextStyle(
              color: Color(0xFF102A43),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
