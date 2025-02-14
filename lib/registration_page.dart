import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  Future<void> _getDevices() async {
    try {
      List<BluetoothDevice> list = await bluetooth.getBondedDevices();
      setState(() {
        devices = list;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  Future<void> _toggleConnection() async {
    if (isConnected) {
      await bluetooth.disconnect();
      setState(() {
        isConnected = false;
      });
    } else {
      if (selectedDevice == null) return;
      try {
        await bluetooth.connect(selectedDevice!);
        setState(() {
          isConnected = true;
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error: $e");
        }
      }
    }
  }

  Future<void> _print() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        bluetooth.printCustom("Hello World!", 2, 1);
        bluetooth.printNewLine();
        bluetooth.paperCut();
      } else {
        if (kDebugMode) {
          print("Bluetooth is not connected");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Page'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: _getDevices, child: const Text("Search Devices")),
          Text("Devices: ${devices.length}"),
          DropdownButton<BluetoothDevice>(
            hint: const Text("Select Printer"),
            value: selectedDevice,
            onChanged: (BluetoothDevice? device) {
              setState(() {
                selectedDevice = device;
              });
            },
            items: devices
                .map((device) => DropdownMenuItem(
                      value: device,
                      child: Text(device.name!),
                    ))
                .toList(),
          ),
          Text("Selected: ${selectedDevice?.name ?? "None"}"),
          ElevatedButton(
              onPressed: _toggleConnection,
              child: Text(isConnected ? "Disconnect" : "Connect")),
          ElevatedButton(onPressed: _print, child: const Text("Print")),
        ],
      ),
    );
  }
}
