import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/widgets/common_container.dart';
import '../../../farm/presentation/pages/farm_dashboard_page.dart';
import '../../../farm/presentation/pages/accounting_dashboard_page.dart';
import '../../../login/presentation/pages/login_page.dart';
import 'live_monitoring_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const _CombinedTopCard(),
              const SizedBox(height: 16),
              _FeatureCards(onFeatureSelected: _openFeature),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFeature(WidgetBuilder destinationBuilder) async {
    if (!_isLoggedIn) {
      final loggedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const LoginPage(),
      );
      if (loggedIn != true || !mounted) return;
      setState(() => _isLoggedIn = true);
    }

    if (!mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: destinationBuilder));
  }
}

class _CombinedTopCard extends StatelessWidget {
  const _CombinedTopCard();

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      width: double.infinity,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFCADAE3), width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CompanyCard(),
            SizedBox(height: 8),
            _WeatherHeader(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2EAEE)),
      ),
      child: const Text(
        'DMA Technologies More Fish Services',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF111111),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'serif',
        ),
      ),
    );
  }
}

class _WeatherHeader extends StatefulWidget {
  const _WeatherHeader();

  @override
  State<_WeatherHeader> createState() => _WeatherHeaderState();
}

class _WeatherHeaderState extends State<_WeatherHeader> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _date {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = _now.day.toString().padLeft(2, '0');
    return '$day-${months[_now.month - 1]}-${_now.year}';
  }

  String get _time {
    final hour = _now.hour == 0
        ? 12
        : (_now.hour > 12 ? _now.hour - 12 : _now.hour);
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    final period = _now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/more_fish.jpeg',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MoreFish - মাছের...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  _date,
                  style: TextStyle(color: Color(0xFF777777), fontSize: 11),
                ),
                Text(
                  _time,
                  style: TextStyle(color: Color(0xFF777777), fontSize: 10),
                ),
              ],
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 15, color: Color(0xFF38A4A8)),
                  Text(
                    ' Dhaka',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _WeatherValue(label: 'Air Temp', value: '27.98°C'),
                  SizedBox(width: 10),
                  _WeatherValue(label: 'Humidity', value: '69%'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherValue extends StatelessWidget {
  const _WeatherValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777777), fontSize: 8),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard();

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      height: 72,
      width: double.infinity,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFCADAE3), width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Image.asset(
            'assets/dma_logo.png',
            width: 52,
            height: 52,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'DMA Technology Limited',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                height: 1.2,
                fontFamily: 'serif',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCards extends StatelessWidget {
  const _FeatureCards({required this.onFeatureSelected});

  final Future<void> Function(WidgetBuilder) onFeatureSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _FeatureCard(
            iconAsset: 'assets/live_data_monitoring.png',
            label: 'Live data Monitoring',
            onFeatureSelected: onFeatureSelected,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FeatureCard(
            iconAsset: 'assets/dashboard.png',
            label: 'Farm Management Dashboard',
            onFeatureSelected: onFeatureSelected,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FeatureCard(
            iconAsset: 'assets/accounting.png',
            label: 'Farm Accounting',
            onFeatureSelected: onFeatureSelected,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.iconAsset,
    required this.label,
    required this.onFeatureSelected,
  });

  final String iconAsset;
  final String label;
  final Future<void> Function(WidgetBuilder) onFeatureSelected;

  @override
  Widget build(BuildContext context) {
    final WidgetBuilder? destinationBuilder = switch (label) {
      'Live data Monitoring' => (_) => const LiveMonitoringPage(),
      'Farm Management Dashboard' => (_) => const FarmDashboardPage(),
      'Farm Accounting' => (_) => const AccountingDashboardPage(),
      _ => null,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: destinationBuilder == null
          ? null
          : () => onFeatureSelected(destinationBuilder),
      child: CommonContainer(
        height: 116,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCADAE3), width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconAsset, width: 34, height: 34, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
