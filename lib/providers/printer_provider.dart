import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/services/printer_services.dart';

// Provides the core printer logic (Real or Mock)
final printerProvider = Provider<PrinterService>((ref) {
  return RealPrinterService(); 
});

// Holds the currently selected Bluetooth Device in memory
final selectedPrinterProvider = StateProvider<BluetoothDevice?>((ref) => null);
