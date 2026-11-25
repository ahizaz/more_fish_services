import 'package:flutter/material.dart';
import 'package:more_fish/core/localization/app_translations.dart';

import '../../models/farm_models.dart';

class FarmDashboardLogo extends StatelessWidget {
  const FarmDashboardLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF1B89E6),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.waves, color: Colors.white, size: 28),
      ),
    );
  }
}

class FarmDashboardDesktopActions extends StatelessWidget {
  const FarmDashboardDesktopActions({
    super.key,
    required this.farms,
    required this.selectedFarmId,
    required this.onFarmChanged,
    required this.onCreateFarm,
    required this.onCreatePond,
    required this.onCreateStocking,
    required this.onWeeklyUpdate,
    required this.onLogout,
  });

  final List<Farm> farms;
  final String? selectedFarmId;
  final ValueChanged<String?> onFarmChanged;
  final VoidCallback onCreateFarm;
  final VoidCallback onCreatePond;
  final VoidCallback onCreateStocking;
  final VoidCallback onWeeklyUpdate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FarmDropdown(
          farms: farms,
          value: selectedFarmId,
          onChanged: onFarmChanged,
          width: 220,
        ),
        const SizedBox(width: 8),
        _ActionButton(label: '+ Farm', onPressed: onCreateFarm),
        const SizedBox(width: 8),
        _ActionButton(label: '+ Pond', onPressed: onCreatePond),
        const SizedBox(width: 8),
        _ActionButton(
          label: '+ Stocking',
          color: const Color(0xFF0A9D70),
          onPressed: onCreateStocking,
        ),
        const SizedBox(width: 8),
        _ActionButton(
          label: 'Weekly Update',
          color: const Color(0xFF315BDA),
          onPressed: onWeeklyUpdate,
        ),
        const SizedBox(width: 8),
        _ActionButton(
          label: 'Logout',
          onPressed: onLogout,
          foregroundColor: const Color(0xFFFB3D6B),
          borderColor: const Color(0xFFFFBCCB),
          color: Colors.white,
        ),
      ],
    );
  }
}

class FarmDashboardMobileActions extends StatelessWidget {
  const FarmDashboardMobileActions({
    super.key,
    required this.farms,
    required this.selectedFarmId,
    required this.onFarmChanged,
    required this.onCreateFarm,
    required this.onCreatePond,
    required this.onCreateStocking,
    required this.onWeeklyUpdate,
  });

  final List<Farm> farms;
  final String? selectedFarmId;
  final ValueChanged<String?> onFarmChanged;
  final VoidCallback onCreateFarm;
  final VoidCallback onCreatePond;
  final VoidCallback onCreateStocking;
  final VoidCallback onWeeklyUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _FarmDropdown(
                farms: farms,
                value: selectedFarmId,
                onChanged: onFarmChanged,
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              tooltip: appText('Create farm'),
              onPressed: onCreateFarm,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFEAF3FF),
                foregroundColor: const Color(0xFF315BDA),
              ),
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 4),
            IconButton.filled(
              tooltip: appText('Create pond'),
              onPressed: onCreatePond,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFEAF3FF),
                foregroundColor: const Color(0xFF315BDA),
              ),
              icon: const Icon(Icons.water),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: '+ Stocking',
                color: const Color(0xFF0A9D70),
                foregroundColor: Colors.white,
                borderColor: const Color(0xFF0A9D70),
                onPressed: onCreateStocking,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                label: 'Weekly Update',
                color: const Color(0xFF315BDA),
                foregroundColor: Colors.white,
                borderColor: const Color(0xFF315BDA),
                onPressed: onWeeklyUpdate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FarmDropdown extends StatelessWidget {
  const _FarmDropdown({
    required this.farms,
    required this.value,
    required this.onChanged,
    this.width,
  });

  final List<Farm> farms;
  final String? value;
  final ValueChanged<String?> onChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final dropdown = Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1DDE8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: farms
              .map(
                (farm) => DropdownMenuItem(
                  value: farm.id,
                  child: Text(
                    appText(farm.name),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF102A43),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
    return width == null ? dropdown : SizedBox(width: width, child: dropdown);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.onPressed,
    this.color = const Color(0xFFEAF3FF),
    this.foregroundColor = const Color(0xFF315BDA),
    this.borderColor = const Color(0xFFC4D6F7),
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foregroundColor,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
          side: BorderSide(color: borderColor),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      child: Text(appText(label)),
    );
  }
}
