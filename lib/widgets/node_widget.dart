import 'package:flutter/material.dart';

/// A widget representing a node in the graph.
/// 
/// It is positioned according to [rect] and handles interactive events
/// like taps, secondary taps, long presses, and panning.
class NodeWidget extends StatefulWidget {
  /// The bounding box where the node should be positioned and sized.
  final Rect rect;

  /// The icon displayed within the node.
  final IconData icon;

  /// The label widget displayed next to the icon.
  final Widget label;

  /// Callback invoked when the node is pressed (left click).
  final VoidCallback? onPressed;

  /// Callback invoked when the node is secondary tapped (right click).
  final VoidCallback? onSecondaryTap;

  /// Callback invoked when the node is long pressed.
  final VoidCallback? onLongPress;

  /// Callback invoked when the node is dragged.
  final Function(DragUpdateDetails) onPanUpdate;

  /// The background color of the node's button.
  final Color backgroundColor;

  /// Creates a [NodeWidget].
  const NodeWidget({

    super.key,
    required this.rect,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.onSecondaryTap,
    required this.onLongPress,
    required this.onPanUpdate,
    required this.backgroundColor,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.rect.left,
      top: widget.rect.top,
      child: SizedBox(
        width: widget.rect.width,
        height: widget.rect.height,
        child: GestureDetector(
          onPanUpdate: widget.onPanUpdate,
          onSecondaryTap: widget.onSecondaryTap,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor,
              elevation: 10,
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            icon: Icon(widget.icon),
            label: widget.label,
            onPressed: widget.onPressed,
            onLongPress: widget.onLongPress,
          ),
        ),
      ),
    );
  }
}
