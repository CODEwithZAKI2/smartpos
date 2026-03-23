import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/providers/printer_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrinters();
  }

  Future<void> _fetchPrinters() async {
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching printers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch which printer is currently selected globally
    final selectedPrinter = ref.watch(selectedPrinterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paired Bluetooth Printers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a printer to use for receipts.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _devices.isEmpty
                      ? const Center(
                          child: Text('No paired bluetooth devices found. Pair one in your phone settings first!'),
                        )
                      : ListView.builder(
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            final isSelected = selectedPrinter?.address == device.address;

                            return Card(
                              elevation: isSelected ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isSelected ? Colors.blue : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.print),
                                title: Text(device.name ?? 'Unknown Device'),
                                subtitle: Text(device.address ?? 'No Address'),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Colors.blue)
                                    : null,
                                onTap: () {
                                  // Update the global Riverpod state with the chosen printer!
                                  ref.read(selectedPrinterProvider.notifier).state = device;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Selected ${device.name} as active printer!'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fetchPrinters,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Printers'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}