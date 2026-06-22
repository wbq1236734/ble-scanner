import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  const CharacteristicTile({super.key, required this.characteristic});

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  String _value = '';
  bool _notifying = false;

  BluetoothCharacteristic get c => widget.characteristic;

  bool get canRead => c.properties.read;
  bool get canWrite => c.properties.write || c.properties.writeWithoutResponse;
  bool get canNotify => c.properties.notify || c.properties.indicate;

  Future<void> _read() async {
    try {
      final val = await c.read();
      setState(() => _value = _formatValue(val));
    } catch (e) {
      setState(() => _value = '读取失败: $e');
    }
  }

  Future<void> _toggleNotify() async {
    try {
      if (_notifying) {
        await c.setNotifyValue(false);
        setState(() => _notifying = false);
      } else {
        await c.setNotifyValue(true);
        c.lastValueStream.listen((val) {
          if (mounted) setState(() => _value = _formatValue(val));
        });
        setState(() => _notifying = true);
      }
    } catch (e) {
      setState(() => _value = '通知失败: $e');
    }
  }

  void _showWriteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('写入数据'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入十六进制，如: 01 02 03',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final hex = controller.text
                    .trim()
                    .split(RegExp(r'\s+'))
                    .where((s) => s.isNotEmpty)
                    .map((s) => int.parse(s, radix: 16))
                    .toList();
                await c.write(hex,
                    withoutResponse: c.properties.writeWithoutResponse);
                setState(() => _value = '写入成功');
              } catch (e) {
                setState(() => _value = '写入失败: $e');
              }
            },
            child: const Text('写入'),
          ),
        ],
      ),
    );
  }

  String _formatValue(List<int> val) {
    if (val.isEmpty) return '(空)';
    final hex = val.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    String ascii = '';
    try {
      ascii = ' | ${utf8.decode(val, allowMalformed: false)}';
    } catch (_) {}
    return 'HEX: $hex$ascii';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.memory, size: 16, color: Colors.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  c.uuid.str,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: c.uuid.str));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('UUID 已复制'), duration: Duration(seconds: 1)),
                  );
                },
                tooltip: '复制UUID',
              ),
            ],
          ),
          // 属性标签
          Wrap(
            spacing: 4,
            children: [
              if (canRead) _tag('读', Colors.blue),
              if (canWrite) _tag('写', Colors.green),
              if (canNotify) _tag('通知', Colors.orange),
            ],
          ),
          // 当前值
          if (_value.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_value,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
            ),
          // 操作按钮
          Row(
            children: [
              if (canRead)
                TextButton.icon(
                  onPressed: _read,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('读取'),
                ),
              if (canNotify)
                TextButton.icon(
                  onPressed: _toggleNotify,
                  icon: Icon(
                      _notifying ? Icons.notifications_off : Icons.notifications,
                      size: 16),
                  label: Text(_notifying ? '停止通知' : '开启通知'),
                  style: TextButton.styleFrom(
                    foregroundColor: _notifying ? Colors.orange : null,
                  ),
                ),
              if (canWrite)
                TextButton.icon(
                  onPressed: _showWriteDialog,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('写入'),
                ),
            ],
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
