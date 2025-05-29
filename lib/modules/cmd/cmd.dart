import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

Future<String> command(String command) async {
  try {
    final result = await Isolate.run(() {
      return Process.runSync(
        'osascript',
        ['-e', command],
        runInShell: true,
      );
    });
    return result.stdout.toString().trim();
  } catch (e) {
    debugPrint('Error running command: $command');
    debugPrint(e.toString());
    return '';
  }
}
