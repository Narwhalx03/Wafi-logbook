import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CounterController extends GetxController {
  var counter = 0.obs;
  var step = 1.obs;
  var history = <String>[].obs;

  // Controller untuk sinkronisasi teks di TextField
  final stepController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    stepController.text = step.value.toString();
  }

  void setStep(String value) {
    int parsedValue = int.tryParse(value) ?? 1;
    step.value = parsedValue;
  }

  void increment() {
    counter.value += step.value;
    _addLog("+ Tambah ${step.value}");
  }

  void decrement() {
    counter.value -= step.value;
    _addLog("- Kurang ${step.value}");
  }

  void reset() {
    counter.value = 0;
    step.value = 1;
    history.clear();
    stepController.text = "1";

    Get.snackbar(
      "Reset Berhasil",
      "Data telah dikembalikan ke awal",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
    );
  }

  void _addLog(String action) {
    String time = DateTime.now().toString().substring(11, 16);
    history.insert(0, "$action pada jam $time");

    if (history.length > 5) {
      history.removeLast();
    }
  }

  @override
  void onClose() {
    stepController.dispose();
    super.onClose();
  }
}
