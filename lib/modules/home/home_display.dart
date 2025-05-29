import 'package:flutter/material.dart';

import '../camera/camera_display.dart';
import '../playing/playing_display.dart';

class HomeDisplay extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onCameraTap;

  const HomeDisplay({
    super.key,
    required this.onTap,
    required this.onCameraTap,
  });

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

class ModernCalendarWidget extends StatelessWidget {
  const ModernCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[900]!,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CalendarHeader(month: _getMonthName(now.month)),
              const SizedBox(height: 8),
              Expanded(child: _MiniCalendarGrid(currentDate: now)),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ'
    ];
    return months[month - 1];
  }
}

class _MiniCalendarGrid extends StatelessWidget {
  final DateTime currentDate;

  const _MiniCalendarGrid({required this.currentDate});

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxHeight: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho dos dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                .map(
                  (day) => SizedBox(
                    width: 16,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Dias da semana atual
          Flexible(
            child: _buildWeekDays(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final weekDays = _getCurrentWeekDays();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((date) {
        final isToday = date.day == currentDate.day &&
            date.month == currentDate.month &&
            date.year == currentDate.year;

        return Container(
          width: 16,
          height: 20,
          decoration: BoxDecoration(
            color: isToday ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: isToday ? Colors.black : Colors.white,
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<DateTime> _getCurrentWeekDays() {
    // Encontrar o domingo da semana atual
    final today = currentDate;
    final weekday = today.weekday % 7; // Domingo = 0, Segunda = 1, etc.
    final startOfWeek = today.subtract(Duration(days: weekday));

    // Gerar os 7 dias da semana
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }
}

class _CalendarHeader extends StatelessWidget {
  final String month;

  const _CalendarHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    return Text(
      month,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}
