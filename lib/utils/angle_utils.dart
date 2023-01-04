import 'dart:math' as math;
import 'dart:ui';

enum TextDirection {
  leftToRight,
  rightToLeft,
}

class AngleUtils {
  static TextDirection directionFromAngle(Offset from, Offset to) {
    var angle = math.atan2(
      to.dy - from.dy,
      to.dx - from.dx,
    );

    if (angle < -math.pi / 2 || angle > math.pi / 2) {
      return TextDirection.rightToLeft;
    } else {
      return TextDirection.leftToRight;
    }
  }

  static double bestTextAngle(Offset from, Offset to) {
    var angle = math.atan2(
      to.dy - from.dy,
      to.dx - from.dx,
    );

    if (angle < -math.pi / 2 || angle > math.pi / 2) {
      angle = math.atan2(
        from.dy - to.dy,
        from.dx - to.dx,
      );
    }

    return angle;
  }
}
