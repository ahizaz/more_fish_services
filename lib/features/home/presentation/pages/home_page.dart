import 'package:flutter/material.dart';

import '../../../../core/widgets/common_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 6, 3, 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const _TitleCard(),
              const SizedBox(height: 10),
              const _WeatherForecastCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard();

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      height: 64,
      width: double.infinity,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFCADAE3), width: 1.2),
      alignment: Alignment.center,
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
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

class _WeatherForecastCard extends StatelessWidget {
  const _WeatherForecastCard();

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      height: 72,
      width: double.infinity,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFCADAE3), width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          _WeatherIcon(),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Weather Forecast',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'serif',
              ),
            ),
          ),
          Icon(Icons.chevron_right, size: 28, color: Color(0xFF777777)),
        ],
      ),
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.cloud, size: 42, color: Color(0xFF3FC6DE)),
          Positioned(
            left: 8,
            bottom: 7,
            child: Icon(Icons.water_drop, size: 10, color: Color(0xFF2A91D6)),
          ),
        ],
      ),
    );
  }
}
