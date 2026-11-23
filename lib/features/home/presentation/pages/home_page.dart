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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [const SizedBox(height: 10), const _CombinedTopCard()],
          ),
        ),
      ),
    );
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

class _WeatherHeader extends StatelessWidget {
  const _WeatherHeader();

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
          const Expanded(
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
                  '23-Nov-2026',
                  style: TextStyle(color: Color(0xFF777777), fontSize: 11),
                ),
                Text(
                  '2:12:56 PM',
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
                color: Color(0xFF111111),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
