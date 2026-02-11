import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'counter_controller.dart';

class CounterView extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());

  CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook Counter - Wafi"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Get.defaultDialog(
                title: "Konfirmasi Reset",
                middleText: "Hapus semua data riwayat dan counter?",
                textConfirm: "Ya",
                textCancel: "Batal",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  controller.reset();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Obx(
              () => Text(
                "${controller.counter}",
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.stepController,
              decoration: const InputDecoration(
                labelText: "Masukkan Nilai Step",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bolt),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => controller.setStep(value),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "5 Aktivitas Terakhir:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.history.length,
                  itemBuilder: (context, index) {
                    String logEntry = controller.history[index];
                    bool isAddition = logEntry.startsWith("+");

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isAddition ? Icons.add_circle : Icons.remove_circle,
                          color: isAddition ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          logEntry,
                          style: TextStyle(
                            color: isAddition
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () => controller.increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () => controller.decrement(),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
