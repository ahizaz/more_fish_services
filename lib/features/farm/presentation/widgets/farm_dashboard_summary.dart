import 'package:flutter/material.dart';

class FarmDashboardSummary extends StatelessWidget {
  const FarmDashboardSummary({
    super.key,
    required this.pondCount,
    required this.activeCount,
    required this.weeklyUpdateCount,
  });

  final int pondCount;
  final int activeCount;
  final int weeklyUpdateCount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cards = [
      _SummaryCard(
        title: 'Total Ponds',
        value: pondCount.toString(),
        icon: Icons.water,
        color: const Color(0xFF1887E8),
      ),
      _SummaryCard(
        title: 'Active Batches',
        value: activeCount.toString(),
        icon: Icons.science_outlined,
        color: const Color(0xFF0A9D70),
      ),
      _SummaryCard(
        title: 'Weekly Updates',
        value: weeklyUpdateCount.toString(),
        icon: Icons.calendar_month_outlined,
        color: const Color(0xFF315BDA),
      ),
    ];

    if (width < 760) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF66788A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
