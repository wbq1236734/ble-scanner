import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'characteristic_tile.dart';

class DeviceDetailPage extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceDetailPage({super.key, required this.device});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  bool _connecting = false;
  bool _connected = false;
  List<BluetoothService> _services = [];
  String _statusMsg = '未连接';

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _statusMsg = '连接中...';
    });
    try {
      await widget.device.connect(timeout: const Duration(seconds: 10));
      final services = await widget.device.discoverServices();
      setState(() {
        _connected = true;
        _connecting = false;
        _services = services;
        _statusMsg = '已连接，发现 ${services.length} 个服务';
      });
    } catch (e) {
      setState(() {
        _connecting = false;
        _statusMsg = '连接失败: $e';
      });
    }
  }

  Future<void> _disconnect() async {
    await widget.device.disconnect();
    setState(() {
      _connected = false;
      _services = [];
      _statusMsg = '已断开';
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.device.platformName.isNotEmpty
        ? widget.device.platformName
        : '未知设备';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 状态卡片
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        color: _connected ? Colors.blue : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text(widget.device.remoteId.str,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_statusMsg,
                      style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _connecting
                          ? null
                          : (_connected ? _disconnect : _connect),
                      icon: _connecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(_connected ? Icons.link_off : Icons.link),
                      label: Text(_connecting
                          ? '连接中...'
                          : (_connected ? '断开连接' : '连接设备')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _connected ? Colors.red[100] : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 服务列表
          if (_connected && _services.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (ctx, i) {
                  final service = _services[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: ExpansionTile(
                      leading: const Icon(Icons.miscellaneous_services,
                          color: Colors.blue),
                      title: Text(
                        _uuidLabel(service.uuid.str),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        service.uuid.str,
                        style: const TextStyle(fontSize: 11),
                      ),
                      children: service.characteristics
                          .map((c) => CharacteristicTile(characteristic: c))
                          .toList(),
                    ),
                  );
                },
              ),
            ),

          if (_connected && _services.isEmpty)
            const Expanded(
              child: Center(child: Text('没有发现服务')),
            ),

          if (!_connected)
            const Expanded(
              child: Center(
                child: Text('连接设备后查看服务',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }

  String _uuidLabel(String uuid) {
    final known = {
      '1800': '通用访问',
      '1801': '通用属性',
      '180a': '设备信息',
      '180d': '心率',
      '180f': '电池',
      'fe59': 'DFU服务',
    };
    final short = uuid.length > 8 ? uuid.substring(4, 8).toLowerCase() : uuid.toLowerCase();
    return known[short] ?? '服务';
  }
}
