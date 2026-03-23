# SmartPOS 🛒📱

A modern, fast, and fully-featured Point of Sale (POS) system built with Flutter, Firebase, and Riverpod. Designed for efficient grocery and retail checkout flows with physical hardware integrations.

## ✨ Features

- **Auth & Role Management**: Secure cashier login and user state tracking using Firebase Auth.
- **Real-Time Inventory**: Lightning-fast product fetching and stock adjustments using Cloud Firestore.
- **Hardware Barcode Scanning**: Instant camera-based barcode detection (with an animated laser overlay) using `mobile_scanner`.
- **Dynamic Cart State**: Memory-efficient cart handling, quantity modification, and automatic subtotal calculation using Riverpod `StateNotifier`.
- **Bluetooth Thermal Printing**: Direct SPP connection to classic thermal receipt printers using `blue_thermal_printer`.
- **Mock Testing Mode**: Built-in Interface/Abstract structures allowing UI/UX receipt testing without physical printer hardware.
- **Modern UI**: Clean, rounded `CustomPaint` styling with intuitive layout constraints to optimize cashier workflow.

## 🛠️ Technology Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (`ConsumerStatefulWidget`, `StateProvider`, `StateNotifierProvider`)
- **Backend**: Firebase (Auth & Firestore)
- **Hardware Plugins**:
  - `mobile_scanner` (Camera/Barcode detection)
  - `blue_thermal_printer` (ESC/POS SPP Bluetooth Printing)

## 🏗️ Project Architecture

The codebase adheres strictly to the Separation of Concerns (SoC) principle:
- **`models/`**: Strongly-typed data structures (`ProductModel`, `OrderModel`, `CartModel`).
- **`services/`**: Exclusively handles external API/Hardware logic (Firebase queries, Bluetooth channels).
- **`providers/`**: The Riverpod layer connecting services to the UI intelligently.
- **`screens/`**: Pure UI layer that listens to providers and dispatches actions without housing business logic.

## 🚀 Getting Started

1. Clone the repository and run `flutter pub get`.
2. Connect your physical Android/iOS test device (required for Camera/Bluetooth functionality).
3. Ensure your Firebase `google-services.json` and `GoogleService-Info.plist` are properly configured in your local environment.
4. Run the app: `flutter run`

### Printer Setup
To test receipt layout without a printer, `printerProvider` currently defaults to `MockPrinterService()`. The receipt will print exactly formatted to your debug console. When your hardware arrives, simply switch the provider to return `RealPrinterService()`.

## ⏭️ Roadmap
- [ ] Implement PDF Generation for digital/email receipts.
- [ ] Add Daily Sales Summaries and Analytics.
- [ ] Integrate Credit Card terminal handshakes.
