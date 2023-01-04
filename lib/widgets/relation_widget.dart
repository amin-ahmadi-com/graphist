library graphist;

import 'package:flutter/material.dart';

class RelationWidget extends StatelessWidget {
  final Offset from;
  final Offset to;
  final String label;
  final Color color;
  final double strokeWidth;

  const RelationWidget({
    super.key,
    required this.from,
    required this.to,
    required this.label,
    required this.color,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomPaint(
          painter: _LinePainter(
            from,
            to,
            color,
            strokeWidth,
          ),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color color;
  final double strokeWidth;

  _LinePainter(this.from, this.to, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
