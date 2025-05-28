import 'package:flutter/material.dart';

/// Painter personalizado para desenhar bordas picotadas
/// Segue o princípio SRP - responsável apenas por desenhar bordas picotadas
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashLength = 5.0,
    this.gapLength = 3.0,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Criar retângulo com bordas arredondadas
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    path.addRRect(rrect);

    // Desenhar linha picotada
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < pathMetric.length) {
        final length = draw ? dashLength : gapLength;
        final nextDistance = distance + length;

        if (draw) {
          final extractPath = pathMetric.extractPath(
            distance,
            nextDistance > pathMetric.length ? pathMetric.length : nextDistance,
          );
          canvas.drawPath(extractPath, paint);
        }

        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! DashedBorderPainter ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// Widget que aplica bordas picotadas a um child
/// Segue o princípio OCP - aberto para extensão, fechado para modificação
class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.borderColor = Colors.grey,
    this.strokeWidth = 1.0,
    this.dashLength = 5.0,
    this.gapLength = 3.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: borderColor,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
