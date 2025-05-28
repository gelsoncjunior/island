import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'modules/copy/copy_display.dart';
import 'modules/home/home_display.dart';
import 'modules/camera/camera_display.dart';

void main() async {
  // Inicializa o window_manager antes do runApp
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Configurações da janela
  WindowOptions windowOptions = WindowOptions(
    size: Size(200, 48),
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

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  bool _isHovered = false;
  bool _isPinned = false;
  String _currentDisplay = 'HomeDisplayContent';

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildWindow(
          left: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: HomeDisplay(
                  onCameraTap: () {
                    setState(() {
                      _isPinned = true;
                    });
                  },
                  onTap: () {
                    setState(() {
                      _isPinned = false;
                      _currentDisplay = 'HomeDisplayContent';
                    });
                  },
                ),
              ),
              Flexible(
                child: CopyDisplay(
                  onTap: () {
                    setState(() {
                      _isPinned = true;
                      _currentDisplay = 'CopyDisplayContent';
                    });
                  },
                ),
              ),
            ],
          ),
          right: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isPinned = !_isPinned;
                    });
                  },
                  child: Icon(
                    _isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          center: _buildDisplayContent(),
        ),
      ),
    );
  }

  Widget _buildDisplayContent() {
    switch (_currentDisplay) {
      case 'HomeDisplayContent':
        return HomeDisplayContent(
          onCameraTap: () {},
        );
      case 'CopyDisplayContent':
        return CopyDisplayContent();
      default:
        return Container();
    }
  }

  Widget _buildWindow({Widget? left, Widget? center, Widget? right}) {
    return MouseRegion(
      onExit: (event) {
        setState(() {
          if (!_isPinned) {
            _isHovered = false;
            Future.delayed(Duration(milliseconds: 200), () {
              windowManager.setSize(Size(200, 48));
            });
          }
        });
      },
      onHover: (event) {
        setState(() {
          if (event.localPosition.dy < 50) {
            _isHovered = true;
            windowManager.setSize(Size(600, 150));
          }
        });
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          width: _isHovered ? 600 : 200,
          height: _isHovered ? 150 : 48,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(_isHovered ? 32 : 16),
              bottomRight: Radius.circular(_isHovered ? 32 : 16),
            ),
          ),
          child: Visibility(
            visible: _isHovered,
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          width: 150,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black,
                          ),
                          child: left,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          width: 150,
                          height: 48,
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: right,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Container(
                      height: 100,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
