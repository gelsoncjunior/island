import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'constrains.dart';
import 'modules/dynamic/dynamic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Configurações da janela
  WindowOptions windowOptions = WindowOptions(
    size: Size(widthMin, heightMin),
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    backgroundColor: Colors.transparent,
    center: false,
  );

  // Aplica as configurações e mostra a janela
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setResizable(false);
    await windowManager.setSkipTaskbar(true);
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setAlignment(Alignment.topCenter);
    await windowManager.setMovable(false);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
      ),
    ),
    home: Dynamic(),
  ));
}
