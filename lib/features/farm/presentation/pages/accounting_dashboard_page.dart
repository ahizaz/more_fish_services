import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/farm_accounting_controller.dart';
import '../../controllers/farm_dashboard_controller.dart';
import '../../models/farm_expense.dart';
import '../../models/farm_sale.dart';
import '../../models/farm_selling_price.dart';
import '../widgets/expense_dialog.dart';
import '../widgets/sale_dialog.dart';
import '../widgets/selling_price_dialog.dart';

class AccountingDashboardPage extends StatefulWidget {
  const AccountingDashboardPage({super.key});

  @override
  State<AccountingDashboardPage> createState() =>
      _AccountingDashboardPageState();
}

class _AccountingDashboardPageState extends State<AccountingDashboardPage> {
  static const _teal = Color(0xFF0F6D72);
  static const _ink = Color(0xFF102A43);

  late final FarmDashboardController _controller;
  late final FarmAccountingController _accountingController;
  final _expenseSearchController = TextEditingController();
  final _sellingPriceSearchController = TextEditingController();
  final _saleSearchController = TextEditingController();
  final _revenueScrollController = ScrollController();
  final _metricsScrollController = ScrollController();

  String? _farm;
  String? _pond;
  String? _space;
  int _tab = 0;
  bool _revenueCanScrollLeft = false;
  bool _revenueCanScrollRight = false;
  bool _metricsCanScrollLeft = false;
  bool _metricsCanScrollRight = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<FarmDashboardController>()
        ? Get.find<FarmDashboardController>()
        : Get.put(FarmDashboardController());
    _accountingController = Get.isRegistered<FarmAccountingController>()
        ? Get.find<FarmAccountingController>()
        : Get.put(FarmAccountingController());
    _farm = _controller.farms
        .where((farm) => farm.id == _controller.selectedFarmId.value)
        .map((farm) => farm.name)
        .firstOrNull;
    _revenueScrollController.addListener(_updateScrollIndicators);
    _metricsScrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
    });
  }

  @override
  void dispose() {
    _expenseSearchController.dispose();
    _sellingPriceSearchController.dispose();
    _saleSearchController.dispose();
    _revenueScrollController.dispose();
    _metricsScrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!mounted) return;
    setState(() {
      _revenueCanScrollLeft =
          _revenueScrollController.hasClients &&
          _revenueScrollController.offset > 0;
      _revenueCanScrollRight =
          _revenueScrollController.hasClients &&
          _revenueScrollController.position.maxScrollExtent > 0 &&
          _revenueScrollController.offset <
              _revenueScrollController.position.maxScrollExtent;
      _metricsCanScrollLeft =
          _metricsScrollController.hasClients &&
          _metricsScrollController.offset > 0;
      _metricsCanScrollRight =
          _metricsScrollController.hasClients &&
          _metricsScrollController.position.maxScrollExtent > 0 &&
          _metricsScrollController.offset <
              _metricsScrollController.position.maxScrollExtent;
    });
  }

  void _scrollCards(ScrollController controller, double distance) {
    if (!controller.hasClients) return;
    final target = (controller.offset + distance)
        .clamp(0.0, controller.position.maxScrollExtent)
        .toDouble();
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Widget _horizontalCardScroller({
    required ScrollController controller,
    required Widget child,
    required bool canScrollLeft,
    required bool canScrollRight,
    required double height,
  }) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: child,
          ),
          if (canScrollLeft)
            Positioned(
              left: 0,
              top: (height - 38) / 2,
              child: _scrollArrow(
                icon: Icons.chevron_left,
                onPressed: () => _scrollCards(controller, -260),
              ),
            ),
          if (canScrollRight)
            Positioned(
              right: 0,
              top: (height - 38) / 2,
              child: _scrollArrow(
                icon: Icons.chevron_right,
                onPressed: () => _scrollCards(controller, 260),
              ),
            ),
        ],
      ),
    );
  }

  Widget _scrollArrow({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        color: _teal,
        tooltip: 'Scroll',
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMobile = MediaQuery.sizeOf(context).width < 760;
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          foregroundColor: _ink,
          elevation: 0,
          toolbarHeight: 72,
          leadingWidth: 96,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24, top: 12, bottom: 12),
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                side: const BorderSide(color: Color(0xFFE1E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('←  Back'),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dashboard refreshed'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      side: const BorderSide(color: Color(0xFFD8E1EA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _openExpenseDialog,
                    style: FilledButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Expense'),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 14 : 30,
            isMobile ? 18 : 22,
            isMobile ? 14 : 30,
            30,
          ),
          children: [
            const Text(
              'Farm Accounting',
              style: TextStyle(
                color: Color(0xFF102A43),
                fontFamily: 'serif',
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E9EF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Overview',
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Expenses',
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Selling Prices',
                      selected: _tab == 2,
                      onTap: () => setState(() => _tab = 2),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Sales',
                      selected: _tab == 3,
                      onTap: () => setState(() => _tab = 3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_tab == 0) _buildOverview(isMobile),
            if (_tab == 1) _buildExpenses(isMobile),
            if (_tab == 2) _buildSellingPrices(isMobile),
            if (_tab == 3) _buildSales(isMobile),
          ],
        ),
      );
    });
  }

  Widget _buildOverview(bool isMobile) {
    final selectedFarmId = _controller.farms
        .where((farm) => farm.name == _farm)
        .map((farm) => farm.id)
        .firstOrNull;
    final availablePonds = selectedFarmId == null
        ? const <String>[]
        : _controller.ponds
              .where((pond) => pond.farmId == selectedFarmId)
              .map((pond) => pond.name)
              .toList();
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: _panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Accounting Overview',
                style: TextStyle(
                  color: Color(0xFF102A43),
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a farm',
                style: TextStyle(
                  color: Color(0xFF607690),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('FARM'),
                    const SizedBox(height: 6),
                    _farmDropdown(),
                    const SizedBox(height: 14),
                    _fieldLabel('POND'),
                    const SizedBox(height: 6),
                    _pondDropdown(availablePonds),
                    const SizedBox(height: 14),
                    _fieldLabel('SPACE'),
                    const SizedBox(height: 6),
                    _spaceDropdown(),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('FARM'),
                          const SizedBox(height: 6),
                          _farmDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('POND'),
                          const SizedBox(height: 6),
                          _pondDropdown(availablePonds),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('SPACE'),
                          const SizedBox(height: 6),
                          _spaceDropdown(),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _openExpenseDialog,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: _teal,
                        backgroundColor: const Color(0xFFEEF4F8),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('+ Expense'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: _panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales & Revenue Projection',
                style: TextStyle(
                  color: Color(0xFF102A43),
                  fontFamily: 'serif',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Current valuation, projected revenue and recorded sales',
                style: TextStyle(
                  color: Color(0xFF607690),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (isMobile)
                _horizontalCardScroller(
                  controller: _revenueScrollController,
                  canScrollLeft: _revenueCanScrollLeft,
                  canScrollRight: _revenueCanScrollRight,
                  height: 118,
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: _RevenueCard(
                          title: 'If Sold Today',
                          value: '—',
                          subtitle: 'Standing biomass × latest selling price',
                          icon: Icons.phishing,
                          iconColor: Color(0xFF4F8FD8),
                        ),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 300,
                        child: _RevenueCard(
                          title: '3-Month Estimate',
                          value: '—',
                          subtitle: 'Backend 90-day projection',
                          icon: Icons.calendar_month,
                          iconColor: Color(0xFFBC82EA),
                        ),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 300,
                        child: _RevenueCard(
                          title: 'Actual Sales',
                          value: '—',
                          subtitle: 'Recorded sale revenue',
                          icon: Icons.attach_money,
                          iconColor: Color(0xFFF3A51A),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Row(
                  children: [
                    Expanded(
                      child: _RevenueCard(
                        title: 'If Sold Today',
                        value: '—',
                        subtitle: 'Standing biomass × latest selling price',
                        icon: Icons.phishing,
                        iconColor: Color(0xFF4F8FD8),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _RevenueCard(
                        title: '3-Month Estimate',
                        value: '—',
                        subtitle: 'Backend 90-day projection',
                        icon: Icons.calendar_month,
                        iconColor: Color(0xFFBC82EA),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _RevenueCard(
                        title: 'Actual Sales',
                        value: '—',
                        subtitle: 'Recorded sale revenue',
                        icon: Icons.attach_money,
                        iconColor: Color(0xFFF3A51A),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (isMobile)
          _horizontalCardScroller(
            controller: _metricsScrollController,
            canScrollLeft: _metricsCanScrollLeft,
            canScrollRight: _metricsCanScrollRight,
            height: 110,
            child: const Row(
              children: [
                SizedBox(
                  width: 210,
                  child: _MetricCard(
                    title: 'Gross Profit',
                    value: '—',
                    color: Color(0xFF6998EA),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 210,
                  child: _MetricCard(
                    title: 'Total Expense',
                    value: '—',
                    color: Color(0xFFFF7D7D),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 210,
                  child: _MetricCard(
                    title: 'Net Profit',
                    value: '—',
                    color: Color(0xFF1EB37A),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 210,
                  child: _MetricCard(
                    title: 'BCR',
                    value: '—',
                    color: Color(0xFFEF8C3A),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 210,
                  child: _MetricCard(
                    title: 'ROI',
                    value: '—',
                    color: Color(0xFFE872B7),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 210,
                  child: _MetricCard(
                    title: 'Score',
                    value: '—',
                    color: Color(0xFFE0B000),
                  ),
                ),
              ],
            ),
          )
        else
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Gross Profit',
                  value: '—',
                  color: Color(0xFF6998EA),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Total Expense',
                  value: '—',
                  color: Color(0xFFFF7D7D),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Net Profit',
                  value: '—',
                  color: Color(0xFF1EB37A),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'BCR',
                  value: '—',
                  color: Color(0xFFEF8C3A),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'ROI',
                  value: '—',
                  color: Color(0xFFE872B7),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Score',
                  value: '—',
                  color: Color(0xFFE0B000),
                ),
              ),
            ],
          ),
        const SizedBox(height: 18),
        if (isMobile)
          Column(
            children: [
              _buildOverviewExpenseCard(),
              const SizedBox(height: 14),
              _buildOverviewSellingPriceCard(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildOverviewExpenseCard()),
              const SizedBox(width: 18),
              Expanded(child: _buildOverviewSellingPriceCard()),
            ],
          ),
      ],
    );
  }

  Widget _buildOverviewExpenseCard() {
    final selectedFarm = _controller.farms
        .where((farm) => farm.name == _farm)
        .firstOrNull;
    final expenses = selectedFarm == null
        ? const <FarmExpense>[]
        : _accountingController.filterExpenses(
            farmId: selectedFarm.id,
            query: '',
          );

    return Container(
      height: 186,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Breakdown',
            style: TextStyle(
              color: Color(0xFF102A43),
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedFarm == null
                ? 'Category-wise expense for Select a farm'
                : 'Category-wise expense for ${selectedFarm.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF607690),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                selectedFarm == null
                    ? 'Select a farm to view expense breakdown.'
                    : expenses.isEmpty
                    ? 'No expenses recorded for this farm.'
                    : '${expenses.length} expense records',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF90A4BE),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSellingPriceCard() {
    final selectedFarm = _controller.farms
        .where((farm) => farm.name == _farm)
        .firstOrNull;
    final prices = selectedFarm == null
        ? const <FarmSellingPrice>[]
        : _accountingController.filterSellingPrices(
            farmId: selectedFarm.id,
            query: '',
          );
    final latestPrice = prices.isEmpty ? null : prices.first;

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Fish Selling Price',
                  style: TextStyle(
                    color: Color(0xFF102A43),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton(
                onPressed: selectedFarm == null
                    ? null
                    : _openSellingPriceDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 38),
                ),
                child: const Text('+ Add Price'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Latest price for each stocking',
            style: TextStyle(
              color: Color(0xFF607690),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (latestPrice == null)
            const Expanded(
              child: Center(
                child: Text(
                  'Select a farm to view selling prices.',
                  style: TextStyle(
                    color: Color(0xFF90A4BE),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else ...[
            Text(
              '${latestPrice.stockingBatch}  •  ৳${latestPrice.pricePerKg.toStringAsFixed(2)} / kg',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF506579),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _overviewActionButton(
              label: 'View Price History →',
              onPressed: () => setState(() => _tab = 2),
            ),
          ],
        ],
      ),
    );
  }

  Widget _overviewActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF506579),
          side: const BorderSide(color: Color(0xFFD1DDE8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildSales(bool isMobile) {
    final selectedFarm = _controller.farms
        .where((farm) => farm.name == _farm)
        .firstOrNull;
    final sales = selectedFarm == null
        ? const <FarmSale>[]
        : _accountingController.filterSales(
            farmId: selectedFarm.id,
            query: _saleSearchController.text,
          );
    final totalRevenue = sales.fold<double>(
      0,
      (total, sale) => total + sale.revenue,
    );
    final totalWeight = sales.fold<double>(
      0,
      (total, sale) => total + sale.weightSold,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fish Sales',
                      style: TextStyle(
                        color: Color(0xFF102A43),
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Actual recorded sales and revenue',
                      style: TextStyle(
                        color: Color(0xFF607690),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: selectedFarm == null ? null : _openSaleDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  disabledBackgroundColor: const Color(0xFFB7C7CE),
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 15),
                label: Text(isMobile ? 'Record' : '+ Record Sale'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _salesMetricCard(
                    'Total Sales',
                    '৳${totalRevenue.toStringAsFixed(0)}',
                    const Color(0xFFE9FAF7),
                    _teal,
                    cardWidth,
                  ),
                  _salesMetricCard(
                    'Sale Records',
                    '${sales.length}',
                    const Color(0xFFEAF2FF),
                    const Color(0xFF356AE6),
                    cardWidth,
                  ),
                  _salesMetricCard(
                    'Weight Sold',
                    '${totalWeight.toStringAsFixed(0)} kg',
                    const Color(0xFFFFF5E9),
                    const Color(0xFFF05A00),
                    cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _saleSearchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search sales...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1DDE8)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (sales.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No sales records found.',
                  style: TextStyle(color: Color(0xFF607690)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 1040
                    ? 1040.0
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.1),
                        1: FlexColumnWidth(1.8),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                        4: FlexColumnWidth(1),
                        5: FlexColumnWidth(1.6),
                        6: FlexColumnWidth(1.2),
                        7: FlexColumnWidth(1.2),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [_salesHeaderRow(), ...sales.map(_salesRow)],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _salesMetricCard(
    String title,
    String value,
    Color background,
    Color foreground,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1E7ED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: foreground, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: foreground,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _salesHeaderRow() {
    const headers = [
      'SALE DATE',
      'STOCKING',
      'WEIGHT (KG)',
      'FISH COUNT',
      'PRICE / KG',
      'BUYER',
      'REVENUE',
      'ACTIONS',
    ];
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDDE5EC))),
      ),
      children: headers
          .map(
            (header) => _expenseCell(
              Text(
                header,
                style: const TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _salesRow(FarmSale sale) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE7EDF2))),
      ),
      children: [
        _expenseCell(_expenseText(_formatExpenseDate(sale.date))),
        _expenseCell(_expenseText(sale.stockingBatch)),
        _expenseCell(_expenseText(sale.weightSold.toString())),
        _expenseCell(_expenseText('${sale.fishCount ?? '—'}')),
        _expenseCell(_expenseText('৳${sale.pricePerKg.toStringAsFixed(0)}')),
        _expenseCell(
          _expenseText(sale.buyerName.isEmpty ? '—' : sale.buyerName),
        ),
        _expenseCell(_expenseText('৳${sale.revenue.toStringAsFixed(0)}')),
        _expenseCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => _openSaleDialog(sale: sale),
                style: _smallActionStyle(padding: 6),
                child: const Text('Edit'),
              ),
              const SizedBox(width: 4),
              OutlinedButton(
                onPressed: () => _deleteSale(sale),
                style: _smallActionStyle(
                  foregroundColor: const Color(0xFFC62828),
                  padding: 6,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSellingPrices(bool isMobile) {
    final selectedFarm = _controller.farms
        .where((farm) => farm.name == _farm)
        .firstOrNull;
    final prices = selectedFarm == null
        ? const <FarmSellingPrice>[]
        : _accountingController.filterSellingPrices(
            farmId: selectedFarm.id,
            query: _sellingPriceSearchController.text,
          );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fish Selling Price',
                      style: TextStyle(
                        color: Color(0xFF102A43),
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stocking-wise selling price history',
                      style: TextStyle(
                        color: Color(0xFF607690),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: selectedFarm == null
                    ? null
                    : _openSellingPriceDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  disabledBackgroundColor: const Color(0xFFB7C7CE),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 15),
                label: Text(isMobile ? 'Add' : '+ Add Selling Price'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _sellingPriceSearchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search selling price records...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1DDE8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1DDE8)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (prices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No selling price records found.',
                  style: TextStyle(color: Color(0xFF607690)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 920
                    ? 920.0
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.7),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1.1),
                        3: FlexColumnWidth(1.5),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        _sellingPriceHeaderRow(),
                        ...prices.map(_sellingPriceRow),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  TableRow _sellingPriceHeaderRow() {
    const headers = [
      'STOCKING / BATCH',
      'PRICE PER KG',
      'PRICE DATE',
      'ACTIONS',
    ];
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDDE5EC))),
      ),
      children: headers
          .map(
            (header) => _expenseCell(
              Text(
                header,
                style: const TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _sellingPriceRow(FarmSellingPrice price) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE7EDF2))),
      ),
      children: [
        _expenseCell(_expenseText(price.stockingBatch)),
        _expenseCell(_expenseText('৳${price.pricePerKg.toStringAsFixed(2)}')),
        _expenseCell(_expenseText(_formatExpenseDate(price.date))),
        _expenseCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => _openSellingPriceDialog(sellingPrice: price),
                style: _smallActionStyle(padding: 6),
                child: const Text('Edit'),
              ),
              const SizedBox(width: 4),
              OutlinedButton(
                onPressed: () => _deleteSellingPrice(price),
                style: _smallActionStyle(
                  foregroundColor: const Color(0xFFC62828),
                  padding: 6,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenses(bool isMobile) {
    final selectedFarm = _controller.farms
        .where((farm) => farm.name == _farm)
        .firstOrNull;
    final expenses = selectedFarm == null
        ? const <FarmExpense>[]
        : _accountingController.filterExpenses(
            farmId: selectedFarm.id,
            query: _expenseSearchController.text,
          );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expenses',
                      style: TextStyle(
                        color: Color(0xFF102A43),
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${expenses.length} record(s)',
                      style: const TextStyle(
                        color: Color(0xFF607690),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: selectedFarm == null ? null : _openExpenseDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  disabledBackgroundColor: const Color(0xFFB7C7CE),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 15),
                label: Text(isMobile ? 'Add' : 'Add Expense'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _expenseSearchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search expenses...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1DDE8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1DDE8)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No expenses found.',
                  style: TextStyle(color: Color(0xFF607690)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 920
                    ? 920.0
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.7),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1.1),
                        4: FlexColumnWidth(2.4),
                        5: FlexColumnWidth(1.5),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        _expenseHeaderRow(),
                        ...expenses.map(_expenseRow),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  TableRow _expenseHeaderRow() {
    const headers = [
      'STOCKING / BATCH',
      'CATEGORY',
      'AMOUNT (BDT)',
      'EXPENSE DATE',
      'DESCRIPTION',
      'ACTIONS',
    ];
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDDE5EC))),
      ),
      children: headers
          .map(
            (header) => _expenseCell(
              Text(
                header,
                style: const TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _expenseRow(FarmExpense expense) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE7EDF2))),
      ),
      children: [
        _expenseCell(_expenseText(expense.stockingBatch)),
        _expenseCell(_expenseText(expense.category.toUpperCase())),
        _expenseCell(_expenseText('৳${expense.amount.toStringAsFixed(2)}')),
        _expenseCell(_expenseText(_formatExpenseDate(expense.date))),
        _expenseCell(_expenseText(expense.description)),
        _expenseCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => _openExpenseDialog(expense: expense),
                style: _smallActionStyle(padding: 6),
                child: const Text('Edit'),
              ),
              const SizedBox(width: 4),
              OutlinedButton(
                onPressed: () => _deleteExpense(expense),
                style: _smallActionStyle(
                  foregroundColor: const Color(0xFFC62828),
                  padding: 6,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _expenseCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: child,
    );
  }

  Text _expenseText(String value) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF102A43),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _smallActionStyle({Color? foregroundColor, double padding = 10}) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor ?? const Color(0xFF102A43),
      minimumSize: const Size(0, 36),
      padding: EdgeInsets.symmetric(horizontal: padding),
      side: BorderSide(
        color: foregroundColor == null
            ? const Color(0xFFD1DDE8)
            : const Color(0xFFFFB8B8),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF607690),
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _farmDropdown() {
    final farmNames = _controller.farms.map((farm) => farm.name).toList();
    return _DropdownField(
      value: farmNames.contains(_farm) ? _farm : null,
      hint: 'Select Farm',
      items: farmNames,
      onChanged: (value) => setState(() {
        _farm = value;
        _pond = null;
        _space = null;
      }),
    );
  }

  Widget _pondDropdown(List<String> ponds) {
    return _DropdownField(
      value: _pond,
      hint: _farm == null ? 'Select Farm First' : 'Select Pond',
      items: ponds,
      onChanged: (value) => setState(() {
        _pond = value;
        _space = null;
      }),
    );
  }

  Widget _spaceDropdown() {
    return _DropdownField(
      value: _space,
      hint: _pond == null ? 'Select Pond First' : 'Select Space',
      items: _pond == null ? const <String>[] : const ['Tank A', 'Tank B'],
      onChanged: (value) => setState(() => _space = value),
    );
  }

  Future<void> _openExpenseDialog({FarmExpense? expense}) async {
    final selectedFarm = _controller.farms
        .where((farm) => farm.name == _farm)
        .firstOrNull;
    if (selectedFarm == null) return;

    final batches = _controller.stockings
        .where((stocking) => stocking.farmName == selectedFarm.name)
        .map((stocking) => stocking.batchName)
        .toSet()
        .toList();
    final result = await showDialog<FarmExpense>(
      context: context,
      builder: (_) => ExpenseDialog(
        farmId: selectedFarm.id,
        batches: batches,
        expense: expense,
      ),
    );
    if (result == null || !mounted) return;

    if (expense == null) {
      await _accountingController.addExpense(result);
      _showMessage('Expense added successfully.');
    } else {
      await _accountingController.updateExpense(result);
      _showMessage('Expense updated successfully.');
    }
  }

  Future<void> _deleteExpense(FarmExpense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _accountingController.deleteExpense(expense.id);
    _showMessage('Expense deleted.');
  }

  Future<void> _openSellingPriceDialog({FarmSellingPrice? sellingPrice}) async {
    final selectedFarm = _controller.farms
        .where((farm) => farm.name == _farm)
        .firstOrNull;
    if (selectedFarm == null) return;

    final batches = _controller.stockings
        .where((stocking) => stocking.farmName == selectedFarm.name)
        .map((stocking) => stocking.batchName)
        .toSet()
        .toList();
    final result = await showDialog<FarmSellingPrice>(
      context: context,
      builder: (_) => SellingPriceDialog(
        farmId: selectedFarm.id,
        batches: batches,
        sellingPrice: sellingPrice,
      ),
    );
    if (result == null || !mounted) return;

    if (sellingPrice == null) {
      await _accountingController.addSellingPrice(result);
      _showMessage('Selling price added successfully.');
    } else {
      await _accountingController.updateSellingPrice(result);
      _showMessage('Selling price updated successfully.');
    }
  }

  Future<void> _deleteSellingPrice(FarmSellingPrice price) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Selling Price'),
        content: const Text(
          'Are you sure you want to delete this selling price?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _accountingController.deleteSellingPrice(price.id);
    _showMessage('Selling price deleted.');
  }

  Future<void> _openSaleDialog({FarmSale? sale}) async {
    final selectedFarm = _controller.farms
        .where((farm) => farm.name == _farm)
        .firstOrNull;
    if (selectedFarm == null) return;

    final batches = _controller.stockings
        .where((stocking) => stocking.farmName == selectedFarm.name)
        .map((stocking) => stocking.batchName)
        .toSet()
        .toList();
    final result = await showDialog<FarmSale>(
      context: context,
      builder: (_) =>
          SaleDialog(farmId: selectedFarm.id, batches: batches, sale: sale),
    );
    if (result == null || !mounted) return;

    if (sale == null) {
      await _accountingController.addSale(result);
      _showMessage('Sale recorded successfully.');
    } else {
      await _accountingController.updateSale(result);
      _showMessage('Sale updated successfully.');
    }
  }

  Future<void> _deleteSale(FarmSale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this sale?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _accountingController.deleteSale(sale.id);
    _showMessage('Sale deleted.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatExpenseDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE1E7ED)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F6D72) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: selected ? null : Border.all(color: const Color(0xFFE1E7ED)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF607690),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE7F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E9F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF607690),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF607690),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF607690),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
