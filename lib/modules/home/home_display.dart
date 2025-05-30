import 'package:flutter/material.dart';

import '../calendar/modern_calendar.dart';
import '../camera/camera_display.dart';
import '../playing/playing_display.dart';

class HomeDisplay extends StatelessWidget {
  final VoidCallback onTap;
  const HomeDisplay({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.home_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class HomeDisplayContent extends StatelessWidget {
  const HomeDisplayContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PlayingDisplay(),
        const SizedBox(width: 16),
        const ModernCalendarWidget(),
        const SizedBox(width: 16),
        CameraDisplay(),
      ],
    );
  }
}
