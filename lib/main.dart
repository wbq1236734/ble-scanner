import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'device_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      home: const ScanPage(),
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final List<ScanResult> _results = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (final r in results) {
          final idx = _results.indexWhere(
              (e) => e.device.remoteId == r.device.remoteId);
          if (idx >= 0) {
            _results[idx] = r;
          } else {
            _results.add(r);
          }
        }
        _results.sort((a, b) => b.rssi.compareTo(a.rssi));
      });
    });
    FlutterBluePlus.isScanning.listen((scanning) {
      setState(() => _isScanning = scanning);
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> _toggleScan() async {
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
    } else {
      setState(() => _results.clear());
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_searching,
                      size: 80,
                      color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _isScanning ? '扫描中...' : '点击按钮开始扫描',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (ctx, i) {
                final r = _results[i];
                final name = r.device.platformName.isNotEmpty
                    ? r.device.platformName
                    : '未知设备';
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.bluetooth),
                    ),
                    title: Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(r.device.remoteId.str),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${r.rssi} dBm',
                            style: TextStyle(
                              color: _rssiColor(r.rssi),
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 2),
                        Icon(Icons.signal_cellular_alt,
                            size: 16, color: _rssiColor(r.rssi)),
                      ],
                    ),
                    onTap: () {
                      FlutterBluePlus.stopScan();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DeviceDetailPage(device: r.device),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleScan,
        icon: Icon(_isScanning ? Icons.stop : Icons.search),
        label: Text(_isScanning ? '停止' : '开始扫描'),
        backgroundColor: _isScanning ? Colors.red : null,
      ),
    );
  }

  Color _rssiColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -80) return Colors.orange;
    return Colors.red;
  }
}
