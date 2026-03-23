import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:smartpos/models/order_model.dart';

abstract class PrinterService {
  Future<void> connect(BluetoothDevice device);
  Future<void> printReceipt(OrderModel order);
  Future<void> disconnect();
}
class MockPrinterService implements PrinterService {
  @override
  Future<void> connect(BluetoothDevice device) async {
    print('🖨️ [MOCK] Connected to printer at ${device.name}');
  }

  @override
  Future<void> printReceipt(OrderModel order) async {
    print('\n================================');
    print('         SMART POS RECEIPT      ');
    print('================================');
    print('Receipt #: ${order.receiptNumber}');
    print('Date: ${order.createdAt.toDate()}');
    print('--------------------------------');
    for (var item in order.items) {
      print('\$${item.price} x${item.quantity}   ${item.name}');
    }
    print('--------------------------------');
    print('TOTAL: \$${order.grandTotal}');
    print('================================\n');
  }

  @override
  Future<void> disconnect() async {
    print('🖨️ [MOCK] Disconnected from printer.');
  }
}


class RealPrinterService implements PrinterService {
  // This is the core package controller
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  Future<void> connect(BluetoothDevice device) async {
    // We only connect if it isn't already connected!
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == false) {
      await bluetooth.connect(device);
    }
  }

  @override
  Future<void> printReceipt(OrderModel order) async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected != true) {
       print('Cannot print: Printer is not connected!');
       return;
    }

    // 0 = Normal, 1 = Bold, 2 = Bold/Large
    // 0 = Left, 1 = Center, 2 = Right
    
    // Header
    bluetooth.printCustom("SMART POS RECEIPT", 2, 1); 
    bluetooth.printNewLine();
    
    // Info
    bluetooth.printCustom("Receipt #: ${order.receiptNumber}", 0, 0); 
    
    // Format the date simply (e.g. 2026-03-23)
    String date = order.createdAt.toDate().toString().split('.')[0];
    bluetooth.printCustom("Date: $date", 0, 0); 
    bluetooth.printNewLine();

    // Divider
    bluetooth.printCustom("--------------------------------", 0, 1); 
    
    // Items
    for (var item in order.items) {
      // Print item name on left
      bluetooth.printCustom(item.name, 1, 0); 
      // Print price/qty slightly indented
      bluetooth.printCustom("  \$${item.price} x ${item.quantity}", 0, 0); 
    }
    
    // Divider
    bluetooth.printCustom("--------------------------------", 0, 1); 
    
    // Total
    bluetooth.printCustom("TOTAL: \$${order.grandTotal}", 2, 1); 
    
    // You MUST add empty lines at the end so the paper pushes out of the printer
    // far enough for the cashier to tear it off!
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    
    // Tells the printer the job is done
    bluetooth.paperCut(); 
  }





  @override
  Future<void> disconnect() async {
    await bluetooth.disconnect();
  }
}
