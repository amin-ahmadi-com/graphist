import 'package:flutter/cupertino.dart';

import '../graph/base/node.dart';
import '../graph/base/relation.dart';
import '../graph/graph_implementations/in_memory_graph.dart';

/// Controls the nodes and relations displayed on a [GraphWidget].
///
/// Manages the visibility, positioning, and layout of nodes and relations
/// in a tree-based graph visualization. Nodes and relations can be shown,
/// hidden, moved, and collapsed independently.
class GraphController extends ChangeNotifier {
  final _graph = InMemoryGraph();
  final Map<String, Rect> _rects = {};

  /// Returns whether [nodeId] is currently visible on the graph.
  ///
  /// A node is considered shown if it exists in the graph and has an
  /// associated position rect.
  bool nodeIsShown(String nodeId) {
    return _graph.nodeExists(nodeId) && _rects.containsKey(nodeId);
  }

  /// Shows [node] at the given [rect] position.
  ///
  /// Adds the node to the graph, records its position, and notifies listeners.
  void showNode(Node node, Rect rect) {
    _graph.addNode(node);
    _rects[node.id] = rect;
    notifyListeners();
  }

  /// Shows [relation] on the graph.
  ///
  /// Adds the relation to the graph and notifies listeners.
  void showRelation(Relation relation) {
    _graph.addRelation(relation);
    notifyListeners();
  }

  /// Hides [nodeId] from the graph.
  ///
  /// Also removes all relations connected to this node.
  void hideNode(String nodeId) {
    _graph.removeNode(nodeId);
    final relationsTo = _graph.getRelationsTo(nodeId).toList(growable: false);
    for (final relation in relationsTo) {
      hideRelation(relation.id);
    }
    final relationsFrom =
    _graph.getRelationsFrom(nodeId).toList(growable: false);
    for (final relation in relationsFrom) {
      hideRelation(relation.id);
    }
    notifyListeners();
  }

  /// Hides [relationId] from the graph.
  ///
  /// Removes the relation and notifies listeners.
  void hideRelation(String relationId) {
    _graph.removeRelation(relationId);
    notifyListeners();
  }

  /// Moves the node identified by [nodeId] to [rect].
  ///
  /// Updates the node's position and notifies listeners.
  void moveNode(String nodeId, Rect rect) {
    _rects[nodeId] = rect;
    notifyListeners();
  }

  /// Returns the current bounding rect of the node with [nodeId].
  ///
  /// Returns `null` if the node has no recorded position.
  Rect? getNodeRect(String nodeId) {
    return _rects[nodeId];
  }

  /// Clears all nodes and relations, and notifies listeners.
  void clear() {
    _graph.clear();
    _rects.clear();
    notifyListeners();
  }

  /// Returns all currently visible nodes.
  Iterable<Node> displayedNodes() {
    return _graph.allNodes();
  }

  /// Returns all currently visible relations.
  Iterable<Relation> displayedRelations() {
    return _graph.allRelations();
  }

  /// Returns all relations emanating from [nodeId].
  Iterable<Relation> getRelationsFrom(String nodeId) {
    return _graph.getRelationsFrom(nodeId);
  }

  /// Returns all relations pointing to [nodeId].
  Iterable<Relation> getRelationsTo(String nodeId) {
    return _graph.getRelationsTo(nodeId);
  }

  /// Returns whether [nodeId] has no outgoing relations.
  bool nodeIsLeaf(String nodeId) {
    return _graph.nodeIsLeaf(nodeId);
  }

  /// Returns whether [nodeId] has outgoing relations.
  bool nodeIsNotLeaf(String nodeId) => !nodeIsLeaf(nodeId);

  /// Returns whether [nodeId] has outgoing relations.
  bool nodeIsConnected(String nodeId) {
    return _graph.nodeIsConnected(nodeId);
  }

  /// Returns whether [nodeId] has no outgoing relations.
  bool nodeIsDisconnected(String nodeId) => !nodeIsConnected(nodeId);

  /// Loads a graph from a JSON string representation.
  ///
  /// Not yet implemented. Throws [UnimplementedError].
  void loadGraph(String graphJson) {
    throw UnimplementedError();
  }

  /// Saves the current graph as a JSON string.
  ///
  /// Not yet implemented. Throws [UnimplementedError].
  String saveGraph() {
    throw UnimplementedError();
  }

  /// Returns whether [nodeId] has relations starting from it
  bool nodeIsExpanded(String nodeId) {
    return _graph
        .getRelationsFrom(nodeId)
        .isNotEmpty;
  }

  /// Opposite of nodeIsExpanded.
  bool nodeIsNotExpanded(String nodeId) => !nodeIsExpanded(nodeId);

  /// Collapses the node identified by [nodeId], hiding all its descendants.
  ///
  /// If [recursively] is `true`, descendant nodes are also collapsed. Use
  /// [collapseRootNodeId] to designate which node acts as the root of the
  /// collapsed subtree (preventing its own visibility from being affected).
  void collapseNode(String nodeId, {
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

  /// Expands [nodeId] to show [relatedNodes] and [relations].
  ///
  /// Positions each newly shown node to the right of [nodeId] with a
  /// vertical offset that increments for each node added. Does nothing for
  /// nodes already shown.
  Future<void> expandNode(String nodeId,
      Iterable<Node> relatedNodes,
      Iterable<Relation> relations,) async {
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
