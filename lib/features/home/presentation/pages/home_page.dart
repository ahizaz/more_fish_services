import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const _TitleCard(),
              const SizedBox(height: 18),
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
    return Container(
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD0D9E2)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'DMA Technologies MoreFIsh Services',
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
    return Container(
      height: 72,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E7EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
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
