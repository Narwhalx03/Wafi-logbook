import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'counter_controller.dart';

class CounterView extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LogBook Counter - Wafi"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
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
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Masukkan Nilai Step",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bolt),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  controller.setStep(int.tryParse(value) ?? 1),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "5 Aktivitas Terakhir:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.history.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.history, color: Colors.grey),
                        title: Text(controller.history[index]),
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
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () => controller.decrement(),
            child: Icon(Icons.remove),
            backgroundColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
