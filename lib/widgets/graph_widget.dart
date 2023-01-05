import 'package:flutter/material.dart';

import '../graph/base/node.dart';
import '../graph/base/relation.dart';
import '../utils/angle_utils.dart';
import '../widgets/node_widget.dart';
import '../widgets/relation_widget.dart';
import 'graph_controller.dart';

typedef NodeActionCallback = void Function(Node node);

/// GraphView widget allows displaying and managing nodes and relations
/// on a graph.
class GraphWidget extends StatefulWidget {
  final GraphController controller;
  final NodeActionCallback onNodeSecondaryTap;
  final NodeActionCallback onNodeLongPress;

  const GraphWidget({
    super.key,
    required this.controller,
    required this.onNodeSecondaryTap,
    required this.onNodeLongPress,
  });

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  @override
  void initState() {
    super.initState();

    // Refresh GraphView when nodes are added, removed and so on
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctl = widget.controller;

    final nodeWidgets = ctl.displayedNodes().map<Widget>((node) {
      var nodeColor = Colors.blueGrey;

      if (ctl.getRelationsFrom(node.id).isNotEmpty) {
        nodeColor = Colors.lightGreen;
      }

      return NodeWidget(
        rect: ctl.getNodeRect(node.id)!,
        // Calculate icon from type and subtype
        icon: const Icon(Icons.circle),
        label: Text(node.label),
        onPressed: () async {
          if (ctl.nodeIsExpanded(node.id)) {
            ctl.collapseNode(node.id);
          } else {
            final relatives = await node.relatives;
            ctl.expandNode(
              node.id,
              relatives.map<Node>((r) => r.item2),
              relatives.map<Relation>((r) => r.item1),
            );
          }
        },
        onSecondaryTap: () => widget.onNodeSecondaryTap(node),
        onLongPress: () => widget.onNodeLongPress(node),
        onPanUpdate: (d) {
          final currentRect = ctl.getNodeRect(node.id)!;
          final updatedRect = Rect.fromLTWH(
            currentRect.left + d.delta.dx,
            currentRect.top + d.delta.dy,
            currentRect.width,
            currentRect.height,
          );
          ctl.moveNode(node.id, updatedRect);
        },
        backgroundColor: nodeColor,
      );
    }).toList();

    final relationWidgets = ctl.displayedRelations().map<Widget>((relation) {
      var relColor = Colors.grey;
      double relWidth = 2;

      if (ctl.nodeIsLeaf(relation.toNodeId)) {
        relColor = Colors.lightGreen;
        relWidth = 5;
      }

      return RelationWidget(
        from: ctl.getNodeRect(relation.fromNodeId)!.center,
        to: ctl.getNodeRect(relation.toNodeId)!.center,
        label: relation.label,
        color: relColor,
        strokeWidth: relWidth,
      );
    }).toList();

    final relationNames = ctl.displayedRelations().map<Widget>((e) {
      final r = Rect.fromPoints(
        ctl.getNodeRect(e.fromNodeId)!.center,
        ctl.getNodeRect(e.toNodeId)!.center,
      );

      return Positioned.fromRect(
        rect: r,
        child: Center(
          child: Transform.rotate(
            angle: AngleUtils.bestTextAngle(
              ctl.getNodeRect(e.fromNodeId)!.center,
              ctl.getNodeRect(e.toNodeId)!.center,
            ),
            child: Text(
              AngleUtils.directionFromAngle(
                        ctl.getNodeRect(e.fromNodeId)!.center,
                        ctl.getNodeRect(e.toNodeId)!.center,
                      ) ==
                      TextDirection.leftToRight
                  ? "${e.label} 🢂"
                  : "🢀 ${e.label}",
              softWrap: false,
              overflow: TextOverflow.visible,
              style: const TextStyle(),
            ),
          ),
        ),
      );
    }).toList();

    return InteractiveViewer(
      panEnabled: true,
      constrained: false,
      minScale: 0.2,
      child: SizedBox(
        width: 100000,
        height: 100000,
        child: Stack(
          children: relationWidgets + relationNames + nodeWidgets,
        ),
      ),
    );
  }
}
