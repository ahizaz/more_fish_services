import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class Farm {
  const Farm({required this.id, required this.name, required this.location});

  final String id;
  final String name;
  final String location;
}

class Pond {
  const Pond({
    required this.id,
    required this.name,
    required this.area,
    required this.areaUnit,
    required this.status,
  });

  final String id;
  final String name;
  final String area;
  final String areaUnit;
  final String status;
}

class Stocking {
  const Stocking({
    required this.id,
    required this.farmName,
    required this.pondName,
    required this.species,
    required this.batchName,
    required this.count,
    required this.initialWeight,
    required this.date,
  });

  final String id;
  final String farmName;
  final String pondName;
  final String species;
  final String batchName;
  final int count;
  final double initialWeight;
  final DateTime date;
}

class WeeklyUpdate {
  const WeeklyUpdate({
    required this.id,
    required this.batchName,
    required this.averageWeight,
    required this.mortality,
    required this.date,
  });

  final String id;
  final String batchName;
  final double averageWeight;
  final int mortality;
  final DateTime date;
}

class FarmDashboardPage extends StatefulWidget {
  const FarmDashboardPage({super.key});

  @override
  State<FarmDashboardPage> createState() => _FarmDashboardPageState();
}

class _FarmDashboardPageState extends State<FarmDashboardPage> {
  final List<Farm> _farms = [
    const Farm(
      id: 'farm-1',
      name: 'AquaNova Fish Farm',
      location: 'Bangladesh',
    ),
  ];

  final List<Pond> _ponds = [
    const Pond(
      id: 'pond-1',
      name: 'Blue Pearl Pond',
      area: '2.00',
      areaUnit: 'DECIMAL',
      status: 'Active',
    ),
    const Pond(
      id: 'pond-2',
      name: 'Green Valley Pond',
      area: '1.50',
      areaUnit: 'DECIMAL',
      status: 'Active',
    ),
  ];

  final List<Stocking> _stockings = [
    Stocking(
      id: 'stocking-1',
      farmName: 'AquaNova Fish Farm',
      pondName: 'Blue Pearl Pond',
      species: 'Tilapia',
      batchName: 'AquaNova Tilapia Batch 01',
      count: 1500,
      initialWeight: 150,
      date: DateTime(2026, 8, 1),
    ),
  ];

  final List<WeeklyUpdate> _weeklyUpdates = List.generate(
    10,
    (index) => WeeklyUpdate(
      id: 'update-$index',
      batchName: 'Batch #10',
      averageWeight: 341 - (index * 13),
      mortality: index % 4 == 2 ? 2 : 3,
      date: DateTime(2026, 11, 14).subtract(Duration(days: index * 7)),
    ),
  );

  String? _selectedFarmId;

  @override
  void initState() {
    super.initState();
    _selectedFarmId = _farms.first.id;
  }

  Farm get _selectedFarm =>
      _farms.firstWhere((farm) => farm.id == _selectedFarmId);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        toolbarHeight: isMobile ? 104 : 92,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF102A43),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: isMobile
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 24),
                child: _LogoIcon(),
              ),
        leadingWidth: isMobile ? 48 : 78,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Farm Dashboard',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              '${_farms.length} ${_farms.length == 1 ? 'Farm' : 'Farms'}'
              ' - ${_ponds.length} Ponds - ${_ponds.where((p) => p.status == 'Active').length} Active Batches',
              style: const TextStyle(
                color: Color(0xFF506579),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: _DesktopActions(
                farms: _farms,
                selectedFarmId: _selectedFarmId,
                onFarmChanged: (value) =>
                    setState(() => _selectedFarmId = value),
                onCreateFarm: _openCreateFarm,
                onCreatePond: _openCreatePond,
                onCreateStocking: _openCreateStocking,
                onWeeklyUpdate: _openWeeklyUpdate,
                onLogout: _logout,
              ),
            ),
        ],
        bottom: isMobile
            ? PreferredSize(
                preferredSize: const Size.fromHeight(108),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: _MobileActions(
                    farms: _farms,
                    selectedFarmId: _selectedFarmId,
                    onFarmChanged: (value) =>
                        setState(() => _selectedFarmId = value),
                    onCreateFarm: _openCreateFarm,
                    onCreatePond: _openCreatePond,
                    onCreateStocking: _openCreateStocking,
                    onWeeklyUpdate: _openWeeklyUpdate,
                  ),
                ),
              )
            : null,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 14 : 24,
          16,
          isMobile ? 14 : 24,
          28,
        ),
        children: [
          _SummarySection(
            pondCount: _ponds.length,
            activeCount: _ponds.where((pond) => pond.status == 'Active').length,
            weeklyUpdateCount: _weeklyUpdates.length,
          ),
          const SizedBox(height: 16),
          if (_ponds.isEmpty)
            const _EmptyPonds()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = isMobile
                    ? 1
                    : (constraints.maxWidth >= 1100 ? 3 : 2);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ponds.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 220,
                  ),
                  itemBuilder: (_, index) => _PondCard(
                    pond: _ponds[index],
                    farmName: _selectedFarm.name,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _openCreateFarm() async {
    final farm = await showDialog<Farm>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateFarmDialog(),
    );
    if (farm != null && mounted) {
      setState(() {
        _farms.add(farm);
        _selectedFarmId = farm.id;
      });
    }
  }

  Future<void> _openCreatePond() async {
    final pond = await showDialog<Pond>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _CreatePondDialog(farms: _farms, selectedFarmId: _selectedFarmId),
    );
    if (pond != null && mounted) {
      setState(() => _ponds.add(pond));
    }
  }

  Future<void> _openCreateStocking() async {
    final stocking = await showDialog<Stocking>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StockingDialog(
        farms: _farms,
        ponds: _ponds,
        stockings: _stockings,
        selectedFarmId: _selectedFarmId,
      ),
    );
    if (stocking != null && mounted) {
      setState(() {
        final index = _stockings.indexWhere((item) => item.id == stocking.id);
        if (index >= 0) {
          _stockings[index] = stocking;
        } else {
          _stockings.insert(0, stocking);
        }
      });
    }
  }

  Future<void> _openWeeklyUpdate() async {
    final update = await showDialog<WeeklyUpdate>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WeeklyUpdateDialog(
        farms: _farms,
        ponds: _ponds,
        stockings: _stockings,
        updates: _weeklyUpdates,
        selectedFarmId: _selectedFarmId,
      ),
    );
    if (update != null && mounted) {
      setState(() {
        final index = _weeklyUpdates.indexWhere((item) => item.id == update.id);
        if (index >= 0) {
          _weeklyUpdates[index] = update;
        } else {
          _weeklyUpdates.insert(0, update);
        }
      });
    }
  }

  void _logout() => Navigator.of(context).maybePop();
}

class _LogoIcon extends StatelessWidget {
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

class _DesktopActions extends StatelessWidget {
  const _DesktopActions({
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
          foregroundColor: Color(0xFFFB3D6B),
          borderColor: Color(0xFFFFBCCB),
          color: Colors.white,
        ),
      ],
    );
  }
}

class _MobileActions extends StatelessWidget {
  const _MobileActions({
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
              tooltip: 'Create farm',
              onPressed: onCreateFarm,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFEAF3FF),
                foregroundColor: const Color(0xFF315BDA),
              ),
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 4),
            IconButton.filled(
              tooltip: 'Create pond',
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
                    farm.name,
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
      child: Text(label),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
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

class _PondCard extends StatelessWidget {
  const _PondCard({required this.pond, required this.farmName});

  final Pond pond;
  final String farmName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.water, color: Color(0xFF1887E8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pond.name,
                      style: const TextStyle(
                        color: Color(0xFF102A43),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      farmName,
                      style: const TextStyle(
                        color: Color(0xFF66788A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pond.status,
                  style: const TextStyle(
                    color: Color(0xFF0A9D70),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PondMetric(
                  label: 'Area',
                  value: '${pond.area} ${pond.areaUnit}',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _PondMetric(label: 'Stocking', value: 'Pending'),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF315BDA),
                side: const BorderSide(color: Color(0xFFC9D6EC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('View pond'),
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
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7A8A99), fontSize: 10),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPonds extends StatelessWidget {
  const _EmptyPonds();

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
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water, size: 44, color: Color(0xFF9FB4C7)),
          SizedBox(height: 10),
          Text(
            'No ponds added yet',
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

class _CreateFarmDialog extends StatefulWidget {
  @override
  State<_CreateFarmDialog> createState() => _CreateFarmDialogState();
}

class _CreateFarmDialogState extends State<_CreateFarmDialog> {
  final _name = TextEditingController();
  String _location = 'Bangladesh';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        48;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 24,
      ),
      backgroundColor: const Color(0xFFAFC8EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 620, maxHeight: availableHeight),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Create New Farm',
                          style: TextStyle(
                            color: Color(0xFF102A43),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF61758A),
                        ),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'FARM NAME *',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _name,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a farm name'
                        : null,
                    decoration: _dialogFieldDecoration(
                      'Example: AquaNova Fish Farm',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LOCATION',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _location,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 20,
                    decoration: _dialogFieldDecoration(null),
                    items: const [
                      DropdownMenuItem(
                        value: 'Bangladesh',
                        child: Text('Bangladesh'),
                      ),
                      DropdownMenuItem(value: 'India', child: Text('India')),
                      DropdownMenuItem(value: 'Nepal', child: Text('Nepal')),
                    ],
                    onChanged: (value) =>
                        setState(() => _location = value ?? 'Bangladesh'),
                  ),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final cancelButton = OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF61758A),
                          side: const BorderSide(color: Colors.white),
                          minimumSize: Size(
                            constraints.maxWidth < 360 ? 120 : 110,
                            48,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      );
                      final createButton = FilledButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.of(context).pop(
                              Farm(
                                id: 'farm-${DateTime.now().millisecondsSinceEpoch}',
                                name: _name.text.trim(),
                                location: _location,
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF315BDA),
                          minimumSize: Size(
                            constraints.maxWidth < 360 ? 120 : 130,
                            48,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Create Farm'),
                      );

                      if (constraints.maxWidth < 360) {
                        return Row(
                          children: [
                            Expanded(child: cancelButton),
                            const SizedBox(width: 8),
                            Expanded(child: createButton),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          cancelButton,
                          const SizedBox(width: 10),
                          createButton,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreatePondDialog extends StatefulWidget {
  const _CreatePondDialog({required this.farms, required this.selectedFarmId});

  final List<Farm> farms;
  final String? selectedFarmId;

  @override
  State<_CreatePondDialog> createState() => _CreatePondDialogState();
}

class _CreatePondDialogState extends State<_CreatePondDialog> {
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _farmId;
  String _areaUnit = 'DECIMAL';
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _farmId = widget.selectedFarmId ?? widget.farms.first.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() => _imageName = result.files.single.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        48;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 24,
      ),
      backgroundColor: const Color(0xFFAFC8EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 660, maxHeight: availableHeight),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Create New Pond & Image',
                          style: TextStyle(
                            color: Color(0xFF102A43),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF61758A),
                        ),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'SELECT FARM *',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _farmId,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 20,
                    decoration: _dialogFieldDecoration(null),
                    items: widget.farms
                        .map(
                          (farm) => DropdownMenuItem(
                            value: farm.id,
                            child: Text(farm.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _farmId = value ?? _farmId),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'POND NAME *',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _name,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a pond name'
                        : null,
                    decoration: _dialogFieldDecoration(
                      'Example: Blue Pearl Pond',
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final areaField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AREA (OPTIONAL)',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _area,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _dialogFieldDecoration('2.00'),
                          ),
                        ],
                      );
                      final unitField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AREA UNIT',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _areaUnit,
                            isExpanded: true,
                            isDense: true,
                            iconSize: 20,
                            decoration: _dialogFieldDecoration(null),
                            items: const [
                              DropdownMenuItem(
                                value: 'DECIMAL',
                                child: Text('DECIMAL'),
                              ),
                              DropdownMenuItem(
                                value: 'ACRE',
                                child: Text('ACRE'),
                              ),
                              DropdownMenuItem(
                                value: 'SQUARE_METER',
                                child: Text('SQUARE_METER'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _areaUnit = value ?? 'DECIMAL'),
                          ),
                        ],
                      );
                      if (constraints.maxWidth < 500) {
                        return Column(
                          children: [
                            areaField,
                            const SizedBox(height: 16),
                            unitField,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: areaField),
                          const SizedBox(width: 12),
                          Expanded(child: unitField),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'POND IMAGE (OPTIONAL)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: _pickImage,
                          child: const Text('Choose File'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _imageName ?? 'No file chosen',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF61758A),
                          side: const BorderSide(color: Colors.white),
                          minimumSize: const Size(110, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.of(context).pop(
                              Pond(
                                id: 'pond-${DateTime.now().millisecondsSinceEpoch}',
                                name: _name.text.trim(),
                                area: _area.text.trim().isEmpty
                                    ? '0'
                                    : _area.text.trim(),
                                areaUnit: _areaUnit,
                                status: 'Active',
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF315BDA),
                          minimumSize: const Size(130, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Create Pond'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StockingDialog extends StatefulWidget {
  const _StockingDialog({
    required this.farms,
    required this.ponds,
    required this.stockings,
    required this.selectedFarmId,
  });

  final List<Farm> farms;
  final List<Pond> ponds;
  final List<Stocking> stockings;
  final String? selectedFarmId;

  @override
  State<_StockingDialog> createState() => _StockingDialogState();
}

class _StockingDialogState extends State<_StockingDialog> {
  final _species = TextEditingController();
  final _batch = TextEditingController();
  final _count = TextEditingController();
  final _weight = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _farmId;
  String? _pondId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _farmId = widget.selectedFarmId ?? widget.farms.first.id;
  }

  @override
  void dispose() {
    _species.dispose();
    _batch.dispose();
    _count.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ponds = widget.ponds;
    return _ScrollableDialog(
      title: 'Fish Stocking Management',
      titleColor: const Color(0xFF102A43),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogSection(
              title: '1. ADD NEW STOCKING',
              color: const Color(0xFF006B52),
              child: Column(
                children: [
                  _FormRow(
                    children: [
                      _selectField(
                        label: 'FARM *',
                        value: _farmId,
                        items: widget.farms
                            .map(
                              (farm) => DropdownMenuItem(
                                value: farm.id,
                                child: Text(farm.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() {
                          _farmId = value!;
                          _pondId = null;
                        }),
                      ),
                      _selectField(
                        label: 'POND *',
                        value: _pondId,
                        hint: 'Select Pond',
                        items: ponds
                            .map(
                              (pond) => DropdownMenuItem(
                                value: pond.id,
                                child: Text(pond.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _pondId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      _textField(
                        label: 'SPECIES *',
                        controller: _species,
                        hint: 'Example: Tilapia',
                        validator: _required,
                      ),
                      _textField(
                        label: 'BATCH NAME',
                        controller: _batch,
                        hint: 'Optional',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      _textField(
                        label: 'COUNT *',
                        controller: _count,
                        keyboardType: TextInputType.number,
                        validator: _required,
                      ),
                      _textField(
                        label: 'INITIAL WT (G) *',
                        controller: _weight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _required,
                      ),
                      _dateField(),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _save,
                      style: _primaryButtonStyle(const Color(0xFF0A9D70)),
                      child: const Text('Save Stocking'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _HistorySection(
              title: '2. STOCKING HISTORY (${widget.stockings.length})',
              headers: const [
                'DATE',
                'BATCH / SPECIES',
                'COUNT',
                'INIT WT',
                'ACTION',
              ],
              rows: [
                for (final item in widget.stockings)
                  [
                    _formatDate(item.date),
                    '${item.batchName} (${item.species})',
                    item.count.toString(),
                    '${item.initialWeight.toStringAsFixed(3)} g',
                    'Edit',
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField() {
    return _LabeledField(
      label: 'DATE *',
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            initialDate: _date,
          );
          if (picked != null) setState(() => _date = picked);
        },
        child: InputDecorator(
          decoration: _dialogFieldDecoration(null),
          child: Text(_formatDate(_date)),
        ),
      ),
    );
  }

  Widget _selectField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return _LabeledField(
      label: label,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        isDense: true,
        iconSize: 20,
        hint: hint == null ? null : Text(hint),
        decoration: _dialogFieldDecoration(null),
        items: items,
        selectedItemBuilder: (context) => [
          for (final item in items)
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: item.child,
                ),
              ),
            ),
        ],
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return _LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _dialogFieldDecoration(hint),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      Stocking(
        id: 'stocking-${DateTime.now().millisecondsSinceEpoch}',
        farmName: widget.farms.firstWhere((farm) => farm.id == _farmId).name,
        pondName: widget.ponds.firstWhere((pond) => pond.id == _pondId).name,
        species: _species.text.trim(),
        batchName: _batch.text.trim().isEmpty
            ? '${_species.text.trim()} Batch'
            : _batch.text.trim(),
        count: int.parse(_count.text.trim()),
        initialWeight: double.parse(_weight.text.trim()),
        date: _date,
      ),
    );
  }
}

class _WeeklyUpdateDialog extends StatefulWidget {
  const _WeeklyUpdateDialog({
    required this.farms,
    required this.ponds,
    required this.stockings,
    required this.updates,
    required this.selectedFarmId,
  });

  final List<Farm> farms;
  final List<Pond> ponds;
  final List<Stocking> stockings;
  final List<WeeklyUpdate> updates;
  final String? selectedFarmId;

  @override
  State<_WeeklyUpdateDialog> createState() => _WeeklyUpdateDialogState();
}

class _WeeklyUpdateDialogState extends State<_WeeklyUpdateDialog> {
  final _weight = TextEditingController();
  final _mortality = TextEditingController(text: '0');
  final _feedQuantity = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _farmId;
  String? _pondId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _farmId = widget.selectedFarmId ?? widget.farms.first.id;
  }

  @override
  void dispose() {
    _weight.dispose();
    _mortality.dispose();
    _feedQuantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ScrollableDialog(
      title: 'Weekly Update & History',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogSection(
              title: '1. SUBMIT NEW WEEKLY UPDATE',
              color: const Color(0xFF204DBB),
              child: Column(
                children: [
                  _FormRow(
                    children: [
                      _select(
                        label: 'FARM *',
                        value: _farmId,
                        items: widget.farms
                            .map(
                              (farm) => DropdownMenuItem(
                                value: farm.id,
                                child: Text(farm.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _farmId = value!),
                      ),
                      _select(
                        label: 'POND *',
                        value: _pondId,
                        hint: 'Select Pond',
                        items: widget.ponds
                            .map(
                              (pond) => DropdownMenuItem(
                                value: pond.id,
                                child: Text(pond.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _pondId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      _select(
                        label: 'SPECIES *',
                        value: null,
                        hint: 'Select Species',
                        items: const [
                          DropdownMenuItem(
                            value: 'Tilapia',
                            child: Text('Tilapia'),
                          ),
                          DropdownMenuItem(
                            value: 'Catfish',
                            child: Text('Catfish'),
                          ),
                        ],
                        onChanged: (_) {},
                        validator: (_) => null,
                      ),
                      _select(
                        label: 'ACTIVE BATCH *',
                        value: null,
                        hint: 'Select Batch',
                        items: widget.stockings
                            .map(
                              (stocking) => DropdownMenuItem(
                                value: stocking.id,
                                child: Text(stocking.batchName),
                              ),
                            )
                            .toList(),
                        onChanged: (_) {},
                        validator: (_) => null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      _field(
                        'AVG WEIGHT (G) *',
                        _weight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _required,
                      ),
                      _field(
                        'MORTALITY *',
                        _mortality,
                        keyboardType: TextInputType.number,
                        validator: _required,
                      ),
                      _dateField(),
                    ],
                  ),
                  const Divider(height: 26, color: Colors.white),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'FEED USAGE (OPTIONAL)',
                      style: TextStyle(
                        color: Color(0xFF344A65),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FormRow(
                    children: [
                      _select(
                        label: '',
                        value: null,
                        hint: 'Select Feed Type',
                        items: const [
                          DropdownMenuItem(
                            value: 'Pellets',
                            child: Text('Pellets'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      _field(
                        '',
                        _feedQuantity,
                        hint: 'Quantity used in kg',
                        validator: (_) => null,
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _save,
                      style: _primaryButtonStyle(const Color(0xFF1D63F5)),
                      child: const Text('Submit Update'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _HistorySection(
              title: '2. WEEKLY UPDATES HISTORY (${widget.updates.length})',
              headers: const [
                'DATE',
                'BATCH ID',
                'AVG WEIGHT',
                'MORTALITY',
                'ACTION',
              ],
              rows: [
                for (final update in widget.updates)
                  [
                    _formatDate(update.date),
                    update.batchName,
                    '${update.averageWeight.toStringAsFixed(3)} g',
                    '${update.mortality} fish',
                    'Edit',
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField() {
    return _LabeledField(
      label: 'DATE *',
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            initialDate: _date,
          );
          if (picked != null) setState(() => _date = picked);
        },
        child: InputDecorator(
          decoration: _dialogFieldDecoration(null),
          child: Text(_formatDate(_date)),
        ),
      ),
    );
  }

  Widget _select({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return _LabeledField(
      label: label,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        isDense: true,
        iconSize: 20,
        hint: hint == null ? null : Text(hint),
        decoration: _dialogFieldDecoration(null),
        items: items,
        selectedItemBuilder: (context) => [
          for (final item in items)
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: item.child,
                ),
              ),
            ),
        ],
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return _LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _dialogFieldDecoration(hint),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      WeeklyUpdate(
        id: 'update-${DateTime.now().millisecondsSinceEpoch}',
        batchName: 'Batch #10',
        averageWeight: double.parse(_weight.text.trim()),
        mortality: int.parse(_mortality.text.trim()),
        date: _date,
      ),
    );
  }
}

class _ScrollableDialog extends StatelessWidget {
  const _ScrollableDialog({
    required this.title,
    required this.child,
    this.titleColor = const Color(0xFF102A43),
  });

  final String title;
  final Widget child;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    final height = size.height - MediaQuery.viewInsetsOf(context).bottom - 44;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 24,
        vertical: 22,
      ),
      backgroundColor: const Color(0xE6DCE5EC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Colors.white70),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 820, maxHeight: height),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 22,
            16,
            isMobile ? 16 : 22,
            20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F8FC),
                        foregroundColor: const Color(0xFF61758A),
                      ),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(color: Colors.white, height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  const _DialogSection({
    required this.title,
    required this.child,
    required this.color,
  });

  final String title;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white70),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.headers,
    required this.rows,
  });

  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFB7EFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF344A65),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 64,
              columnSpacing: 28,
              columns: [
                for (final header in headers)
                  DataColumn(
                    label: Text(
                      header,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      for (final value in row)
                        DataCell(
                          Text(
                            value,
                            style: const TextStyle(
                              color: Color(0xFF344A65),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF17283D),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
        ],
        child,
      ],
    );
  }
}

ButtonStyle _primaryButtonStyle(Color color) {
  return FilledButton.styleFrom(
    backgroundColor: color,
    foregroundColor: Colors.white,
    minimumSize: const Size(132, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
  );
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'Required' : null;

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.year}';

InputDecoration _dialogFieldDecoration(String? hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xF5FFFFFF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB8F2FF), width: 2),
    ),
  );
}
