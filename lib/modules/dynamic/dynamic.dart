import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../constrains.dart';
import '../copy/copy_display.dart';
import '../home/home_display.dart';
import '../static_monitor/static_monitor.dart';

class Dynamic extends StatefulWidget {
  const Dynamic({super.key});

  @override
  State<Dynamic> createState() => _DynamicState();
}

class _DynamicState extends State<Dynamic> with WindowListener {
  bool _isHovered = false;
  bool _isPinned = false;
  bool _showContent = false;
  String _currentDisplay = 'HomeDisplayContent';

  void setSize(Size size) {
    windowManager.setSize(size);
  }

  void setPinned(bool pinned) {
    setState(() {
      _isPinned = pinned;
    });
  }

  void setHovered(bool hovered) {
    setState(() {
      _isHovered = hovered;
    });
  }

  void setShowContent(bool showContent) {
    setState(() {
      _showContent = showContent;
    });
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DropTarget(
        onDragDone: (e) {
          setState(() {
            _isPinned = false;
          });
        },
        onDragEntered: (e) {
          setState(() {
            setSize(Size(widthMax, heightMax));
            setHovered(true);
            _currentDisplay = 'CopyDisplayContent';
            _isPinned = true;
          });
        },
        child: MouseRegion(
          onHover: (e) {
            setState(() {
              if (e.localPosition.dy < 50) {
                setSize(Size(widthMax, heightMax));
                setHovered(true);
              }
            });
          },
          onExit: (event) {
            setState(() {
              if (!_isPinned) {
                setHovered(false);
                setShowContent(false);
                Future.delayed(Duration(milliseconds: 100), () {
                  setSize(Size(widthMin, heightMin));
                });
              }
            });
          },
          child: Align(
            alignment: Alignment.topCenter,
            child: _buildWindows(_isHovered),
          ),
        ),
      ),
    );
  }

  Widget _buildWindows(bool isHovered) {
    return isHovered
        ? _buildExpanded(
            left: Container(
              height: heightMin,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                spacing: 10,
                children: [
                  HomeDisplay(onTap: () {
                    setState(() {
                      _currentDisplay = 'HomeDisplayContent';
                      _isPinned = false;
                    });
                  }),
                  CopyDisplay(onTap: () {
                    setState(() {
                      _currentDisplay = 'CopyDisplayContent';
                      _isPinned = true;
                    });
                  }),
                ],
              ),
            ),
            center: Container(
              height: 100,
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: _buildCenter(),
            ),
            right: Container(
              height: heightMin,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StaticMonitor(),
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
            ),
          )
        : _buildCollapsed(
            left: Container(
              width: 75,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            right: Container(
              width: 75,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StaticMonitor(),
                ],
              ),
            ),
          );
  }

  Widget _buildCenter() {
    switch (_currentDisplay) {
      case 'HomeDisplayContent':
        return HomeDisplayContent();
      case 'CopyDisplayContent':
        return CopyDisplayContent();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildCollapsed({Widget? left, Widget? right}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      color: Colors.black,
      alignment: Alignment.center,
      width: _isHovered ? widthMax : widthMin,
      height: _isHovered ? heightMax : heightMin,
      child: AnimatedOpacity(
        opacity: _isHovered ? 0 : 1,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            left ?? Container(),
            Container(
              width: 100,
              color: Colors.black,
            ),
            right ?? Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded({Widget? left, Widget? center, Widget? right}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      color: Colors.black,
      alignment: Alignment.center,
      width: _isHovered ? widthMax : widthMin,
      height: _isHovered ? heightMax : heightMin,
      onEnd: () {
        setState(() {
          _showContent = true;
        });
      },
      child: AnimatedOpacity(
        opacity: _isHovered ? 1 : 0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _showContent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      left ?? Container(),
                      right ?? Container(),
                    ],
                  ),
                  center ?? Container(),
                ],
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
