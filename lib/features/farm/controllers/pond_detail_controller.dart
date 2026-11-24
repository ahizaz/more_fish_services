import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/pond_detail_models.dart';

class PondDetailController extends GetxController {
  PondDetailController({
    required this.pondName,
    required this.farmName,
    this.initialData,
  });

  final String pondName;
  final String farmName;
  final PondDetailData? initialData;

  final RxBool automationEnabled = false.obs;
  final RxBool manualOn = false.obs;
  final Rx<PondDetailData?> data = Rx<PondDetailData?>(null);
  final TextEditingController minimumDo = TextEditingController(text: '3');
  final TextEditingController maximumDo = TextEditingController(text: '6');

  @override
  void onInit() {
    super.onInit();
    data.value =
        initialData ??
        PondDetailData.demo(pondName: pondName, farmName: farmName);
  }

  @override
  void onClose() {
    minimumDo.dispose();
    maximumDo.dispose();
    super.onClose();
  }

  void setManual(bool value) {
    if (!automationEnabled.value) {
      manualOn.value = value;
    }
  }

  void setAutomation(bool value) {
    automationEnabled.value = value;
    if (value) manualOn.value = false;
  }

  Future<PondDetailData?> loadPondDetail() async {
    // API integration point: replace this demo assignment with repository/service call.
    data.value =
        initialData ??
        PondDetailData.demo(pondName: pondName, farmName: farmName);
    return data.value;
  }

  Future<bool> saveAeratorSettings() async {
    // API integration point: send manual/automation and DO limits to the backend.
    return true;
  }
}
