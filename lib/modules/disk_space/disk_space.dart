import 'dart:async';

import 'package:disk_space_2/disk_space_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiskSpaceMonitor extends StatefulWidget {
  const DiskSpaceMonitor({super.key});

  @override
  State<DiskSpaceMonitor> createState() => _DiskSpaceMonitorState();
}

class _DiskSpaceMonitorState extends State<DiskSpaceMonitor> {
  static const platform = MethodChannel('com.example.island');
  Timer? _timer;
  double _usedPercent = 0.0;

  void _getFreeSpace() async {
    try {
      final double percentage =
          await platform.invokeMethod('getDiskUsagePercentage');

      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _usedPercent = percentage.roundToDouble();
        });
      }
    } catch (e) {
      print('Erro ao obter uso do disco: $e');
    }
  }

  void _startMonitoring() {
    // Primeira execução imediata
    _getFreeSpace();

    // Atualização periódica a cada 2 segundos
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _getFreeSpace();
    });
  }

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    // Cancela o timer para evitar vazamentos de memória e setState após dispose
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.storage_rounded, color: Colors.green[200], size: 14),
        SizedBox(width: 4),
        Text(
          '$_usedPercent%',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
