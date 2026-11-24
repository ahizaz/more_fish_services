import 'package:flutter/material.dart';

class FarmDashboardExtras extends StatelessWidget {
  const FarmDashboardExtras({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _FinancialHubCard(),
        SizedBox(height: 14),
        _PerformanceCard(),
        SizedBox(height: 14),
        _FeedInventoryCard(),
      ],
    );
  }
}

class _FinancialHubCard extends StatelessWidget {
  const _FinancialHubCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFB83B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Color(0xFFEF8A12),
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x33D46A00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FINANCIAL HUB',
                      style: TextStyle(
                        color: Color(0xFF5B3A00),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Farm Accounting',
                    style: TextStyle(
                      color: Color(0xFF102A43),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF18214A),
                disabledBackgroundColor: const Color(0xFF18214A),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Open Accounting Dashboard',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: Color(0xFFFF8A24), size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Farm Performance Score',
                  style: TextStyle(
                    color: Color(0xFF102A43),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFFFFF1DD),
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Color(0xFFE28B27),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '+5',
            style: TextStyle(
              color: Color(0xFF102A43),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'If sold today valuation benchmark',
            style: TextStyle(
              color: Color(0xFF344A65),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10, child: _PerformanceGradient()),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('-5', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('0', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('+5', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceGradient extends StatelessWidget {
  const _PerformanceGradient();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF6B72),
                  Color(0xFFFFD42A),
                  Color(0xFFA8D35A),
                  Color(0xFF38A96B),
                ],
                stops: [0, 0.42, 0.72, 1],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 5,
              height: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFF102A43)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedInventoryCard extends StatelessWidget {
  const _FeedInventoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8F0)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: Color(0xFFEAF2FF),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF4D7FE7),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Feed Inventory',
                style: TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _InventoryValue(
                  title: 'Used Feed',
                  value: '349',
                  unit: 'kg',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InventoryValue(
                  title: 'In Stock (F9)',
                  value: '651',
                  unit: 'kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: 349,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3F80DF), Color(0xFF5C91E8)],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 651,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFB21D), Color(0xFFF4D45A)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF397EDB),
                disabledBackgroundColor: const Color(0xFF397EDB),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Manage Inventory',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryValue extends StatelessWidget {
  const _InventoryValue({
    required this.title,
    required this.value,
    required this.unit,
  });

  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF344A65),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: Color(0xFF344A65),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
