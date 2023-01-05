import 'package:flutter/material.dart';

class NodeWidget extends StatefulWidget {
  final Rect rect;
  final IconData icon;
  final Widget label;
  final VoidCallback? onPressed;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;
  final Function(DragUpdateDetails) onPanUpdate;
  final Color backgroundColor;

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
