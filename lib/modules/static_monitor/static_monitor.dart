import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StaticMonitor extends StatefulWidget {
  const StaticMonitor({super.key});

  @override
  State<StaticMonitor> createState() => _StaticMonitorState();
}

class _StaticMonitorState extends State<StaticMonitor> {
  static const platform = MethodChannel('com.example.island');

  double cpuUsage = 0.0;
  double memoryUsage = 0.0;
  double totalMemoryGB = 0.0;
  double usedMemoryGB = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    // Primeira execução imediata
    _getSystemInfo();

    // Atualização periódica a cada 2 segundos
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _getSystemInfo();
    });
  }

  Future<void> _getSystemInfo() async {
    try {
      // Chama o método nativo
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getSystemInfo');

      if (mounted) {
        setState(() {
          cpuUsage = (result['cpu'] as num?)?.toDouble().roundToDouble() ?? 0.0;
          memoryUsage =
              (result['memoryUsage'] as num?)?.toDouble().roundToDouble() ??
                  0.0;
          totalMemoryGB = (result['totalMemory'] as num?)?.toDouble() ?? 0.0;
          usedMemoryGB = (result['usedMemory'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } on PlatformException catch (e) {
      print("Erro ao obter informações do sistema: '${e.message}'");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.computer_outlined, color: Colors.red[200], size: 12),
            SizedBox(width: 4),
            Text(
              '$cpuUsage%',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
        SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.memory_rounded, color: Colors.green[200], size: 12),
            SizedBox(width: 4),
            Text(
              '$memoryUsage%',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
