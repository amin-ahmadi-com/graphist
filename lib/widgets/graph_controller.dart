import 'package:flutter/cupertino.dart';

import '../graph/base/node.dart';
import '../graph/base/relation.dart';
import '../graph/graph_implementations/in_memory_graph.dart';

/// GraphController controls the nodes and relations on a GraphWidget
class GraphController extends ChangeNotifier {
  final _graph = InMemoryGraph();
  final Map<String, Rect> _rects = {};

  bool nodeIsShown(String nodeId) {
    return _graph.nodeExists(nodeId) && _rects.containsKey(nodeId);
  }

  void showNode(Node node, Rect rect) {
    _graph.addNode(node);
    _rects[node.id] = rect;
    notifyListeners();
  }

  void showRelation(Relation relation) {
    _graph.addRelation(relation);
    notifyListeners();
  }

  void hideNode(String nodeId, {bool removeRelations = true}) {
    _graph.removeNode(nodeId);
    if (removeRelations) {
      final relationsTo = _graph.getRelationsTo(nodeId).toList(growable: false);
      for (final relation in relationsTo) {
        hideRelation(relation.id);
      }
      final relationsFrom =
          _graph.getRelationsFrom(nodeId).toList(growable: false);
      for (final relation in relationsFrom) {
        hideRelation(relation.id);
      }
    }
    notifyListeners();
  }

  void hideRelation(String relationId) {
    _graph.removeRelation(relationId);
    notifyListeners();
  }

  void moveNode(String nodeId, Rect rect) {
    _rects[nodeId] = rect;
    notifyListeners();
  }

  Rect? getNodeRect(String nodeId) {
    return _rects[nodeId];
  }

  void clear() {
    _graph.clear();
    _rects.clear();
    notifyListeners();
  }

  Iterable<Node> displayedNodes() {
    return _graph.allNodes();
  }

  Iterable<Relation> displayedRelations() {
    return _graph.allRelations();
  }

  Iterable<Relation> getRelationsFrom(String nodeId) {
    return _graph.getRelationsFrom(nodeId);
  }

  Iterable<Relation> getRelationsTo(String nodeId) {
    return _graph.getRelationsTo(nodeId);
  }

  bool nodeIsLeaf(String nodeId) {
    return _graph.nodeIsLeaf(nodeId);
  }

  bool nodeIsNotLeaf(String nodeId) => !nodeIsLeaf(nodeId);

  bool nodeIsConnected(String nodeId) {
    return _graph.nodeIsConnected(nodeId);
  }

  bool nodeIsDisconnected(String nodeId) => !nodeIsConnected(nodeId);

  void loadGraph(String graphJson) {
    throw UnimplementedError();
  }

  void saveGraph(String graphJson) {
    throw UnimplementedError();
  }

  bool nodeIsExpanded(String nodeId) {
    return _graph.getRelationsFrom(nodeId).isNotEmpty;
  }

  bool nodeIsNotExpanded(String nodeId) => !nodeIsExpanded(nodeId);

  void collapseNode(
    String nodeId, {
    bool recursively = true,
    String? collapseRootNodeId,
  }) {
    collapseRootNodeId ??= nodeId;

    final nodesTo = _graph.getRelationsFrom(nodeId).map((relation) {
      return relation.toNodeId;
    }).toList(growable: false);

    for (final nodeToId in nodesTo) {
      if (nodeToId == collapseRootNodeId) continue;

      if (recursively && nodeIsExpanded(nodeToId)) {
        collapseNode(
          nodeToId,
          recursively: recursively,
          collapseRootNodeId: collapseRootNodeId,
        );
      }
      hideNode(nodeToId);
    }
  }

  Future<void> expandNode(
    String nodeId,
    Iterable<Node> relatedNodes,
    Iterable<Relation> relations,
  ) async {
    double yStart = 0;

    for (final node in relatedNodes) {
      if (nodeIsShown(node.id)) continue;

      var rect = Rect.fromLTWH(
        getNodeRect(nodeId)!.right + 100,
        getNodeRect(nodeId)!.top + yStart,
        175,
        50,
      );
      yStart += 80;
      showNode(node, rect);
    }

    for (final relation in relations) {
      showRelation(relation);
    }
  }
}
