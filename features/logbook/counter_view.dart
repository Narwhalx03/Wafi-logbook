import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    await _controller.loadData(widget.username);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return "Selamat Pagi";
    } else if (hour >= 11 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false,
                );
              },
              child: const Text(
                "Ya, Keluar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _controller.reset(widget.username)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blueAccent..withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ----------------------------------------
                  const SizedBox(height: 20),
                  Text(
                    '${_controller.counter}',
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller.stepController,
                    decoration: const InputDecoration(
                      labelText: "Besar Langkah (Step)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bolt),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _controller.setStep(value),
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Riwayat Aktivitas:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: _controller.history.isEmpty
                        ? const Center(child: Text("Belum ada aktivitas."))
                        : ListView.builder(
                            itemCount: _controller.history.length,
                            itemBuilder: (context, index) {
                              String logEntry = _controller.history[index];
                              bool isAddition = logEntry.startsWith("+");
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: Icon(
                                    isAddition
                                        ? Icons.add_circle
                                        : Icons.remove_circle,
                                    color: isAddition
                                        ? Colors.green
                                        : Colors.red,
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
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_inc",
            onPressed: () =>
                setState(() => _controller.increment(widget.username)),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn_dec",
            onPressed: () =>
                setState(() => _controller.decrement(widget.username)),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
