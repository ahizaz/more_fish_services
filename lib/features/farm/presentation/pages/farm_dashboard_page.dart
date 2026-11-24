import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/farm_dashboard_controller.dart';
import '../../models/farm_models.dart';
import '../widgets/create_farm_dialog.dart';
import '../widgets/create_pond_dialog.dart';
import '../widgets/farm_dashboard_header.dart';
import '../widgets/farm_dashboard_summary.dart';
import '../widgets/farm_dashboard_extras.dart';
import '../widgets/farm_pond_card.dart';
import '../widgets/stocking_dialog.dart';
import '../widgets/weekly_update_dialog.dart';

class FarmDashboardPage extends StatefulWidget {
  const FarmDashboardPage({super.key});

  @override
  State<FarmDashboardPage> createState() => _FarmDashboardPageState();
}

class _FarmDashboardPageState extends State<FarmDashboardPage> {
  final FarmDashboardController controller = Get.put(FarmDashboardController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMobile = MediaQuery.sizeOf(context).width < 760;
      final selectedPonds = controller.selectedPonds;
      final activePondCount = controller.activePondCount;

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
              : const Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: FarmDashboardLogo(),
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
                '${controller.farms.length} ${controller.farms.length == 1 ? 'Farm' : 'Farms'}'
                ' - ${selectedPonds.length} Ponds - $activePondCount Active Batches',
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
                child: FarmDashboardDesktopActions(
                  farms: controller.farms,
                  selectedFarmId: controller.selectedFarmId.value,
                  onFarmChanged: controller.selectFarm,
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
                    child: FarmDashboardMobileActions(
                      farms: controller.farms,
                      selectedFarmId: controller.selectedFarmId.value,
                      onFarmChanged: controller.selectFarm,
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
            FarmDashboardSummary(
              pondCount: selectedPonds.length,
              activeCount: activePondCount,
              weeklyUpdateCount: controller.weeklyUpdates.length,
            ),
            const SizedBox(height: 16),
            const FarmDashboardExtras(),
            const SizedBox(height: 16),
            if (selectedPonds.isEmpty)
              const FarmEmptyPonds()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = isMobile
                      ? 1
                      : (constraints.maxWidth >= 1100 ? 3 : 2);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedPonds.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: isMobile ? 360 : 300,
                    ),
                    itemBuilder: (_, index) => FarmPondCard(
                      pond: selectedPonds[index],
                      farmName: controller.selectedFarm.name,
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Future<void> _openCreateFarm() async {
    final farm = await showDialog<Farm>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CreateFarmDialog(),
    );
    if (farm != null && mounted) {
      await controller.createFarmApi(farm);
      if (!mounted) return;
      controller.addFarm(farm);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm created successfully.'),
          backgroundColor: Color(0xFFDCF6E7),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _openCreatePond() async {
    final pond = await showDialog<Pond>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreatePondDialog(
        farms: controller.farms,
        selectedFarmId: controller.selectedFarmId.value,
      ),
    );
    if (pond != null && mounted) {
      await controller.createPondApi(pond);
      if (!mounted) return;
      controller.addPond(pond);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pond created successfully.'),
          backgroundColor: Color(0xFFDCF6E7),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _openCreateStocking() async {
    final stocking = await showDialog<Stocking>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StockingDialog(
        farms: controller.farms,
        ponds: controller.ponds,
        stockings: controller.stockings,
        selectedFarmId: controller.selectedFarmId.value,
      ),
    );
    if (stocking != null && mounted) {
      await controller.saveStockingApi(stocking);
      controller.upsertStocking(stocking);
    }
  }

  Future<void> _openWeeklyUpdate() async {
    final update = await showDialog<WeeklyUpdate>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WeeklyUpdateDialog(
        farms: controller.farms,
        ponds: controller.ponds,
        stockings: controller.stockings,
        updates: controller.weeklyUpdates,
        selectedFarmId: controller.selectedFarmId.value,
      ),
    );
    if (update != null && mounted) {
      await controller.saveWeeklyUpdateApi(update);
      controller.upsertWeeklyUpdate(update);
    }
  }

  void _logout() => Navigator.of(context).maybePop();
}
