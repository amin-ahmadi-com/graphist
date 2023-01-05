import 'dart:math' as math;
import 'dart:ui';

enum TextDirection {
  leftToRight,
  rightToLeft,
}

/// This class provides utility functions mainly used to handle the relation
/// widgets and their angle, which are lines starting and ending at nodes.
class AngleUtils {
  /// Suggest the best text direction for a string that sits on a given line,
  /// by using the start and end points of that line.
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

  /// Suggest the best text angle for a string that sits on a given line,
  /// by using the start and end points of that line.
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
