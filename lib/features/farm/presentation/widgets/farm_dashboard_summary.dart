import 'package:flutter/material.dart';
import 'package:more_fish/core/localization/app_translations.dart';

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

    final isMobile = MediaQuery.sizeOf(context).width < 760;
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(
            child: _SummaryCardContainer(isMobile: isMobile, child: cards[i]),
          ),
          if (i != cards.length - 1) SizedBox(width: isMobile ? 6 : 12),
        ],
      ],
    );
  }
}

class _SummaryCardContainer extends StatelessWidget {
  const _SummaryCardContainer({required this.isMobile, required this.child});

  final bool isMobile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return isMobile ? SizedBox(height: 88, child: child) : child;
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
    final isMobile = MediaQuery.sizeOf(context).width < 760;
    return Container(
      height: isMobile ? 88 : 92,
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 36 : 48,
            height: isMobile ? 36 : 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isMobile ? 18 : 24),
          ),
          SizedBox(width: isMobile ? 6 : 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appText(value),
                  style: TextStyle(
                    color: const Color(0xFF102A43),
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  appText(title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF66788A),
                    fontSize: isMobile ? 9 : 12,
                    fontWeight: FontWeight.w600,
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
