import '../base/graph.dart';
import '../base/node.dart';
import '../base/relation.dart';

class InMemoryGraph extends Graph {
  final _nodes = <Node>[];
  final _relations = <Relation>[];

  @override
  void addNode(Node node, {bool replaceIfExists = true}) {
    if (replaceIfExists) {
      removeNode(node.id);
    }
    _nodes.add(node);
  }

  @override
  void addRelation(Relation relation, {bool replaceIfExists = true}) {
    if (replaceIfExists) {
      removeRelation(relation.id);
    }
    _relations.add(relation);
  }

  @override
  void clear() {
    _nodes.clear();
    _relations.clear();
  }

  @override
  Node getNode(String nodeId) {
    return _nodes.firstWhere((node) => node.id == nodeId);
  }

  @override
  Relation getRelation(String relationId) {
    return _relations.firstWhere((relation) => relation.id == relationId);
  }

  @override
  Iterable<Relation> getRelationsFrom(String nodeId) {
    return _relations.where((relation) => relation.fromNodeId == nodeId);
  }

  @override
  Iterable<Relation> getRelationsTo(String nodeId) {
    return _relations.where((relation) => relation.toNodeId == nodeId);
  }

  @override
  bool nodeExists(String nodeId) {
    return _nodes.where((node) => node.id == nodeId).isNotEmpty;
  }

  @override
  bool relationExists(String relationId) {
    return _relations.where((relation) => relation.id == relationId).isNotEmpty;
  }

  @override
  void removeNode(String nodeId) {
    _nodes.removeWhere((node) => node.id == nodeId);
  }

  @override
  void removeRelation(String relationId) {
    _relations.removeWhere((relation) => relation.id == relationId);
  }

  @override
  bool nodeIsConnected(String nodeId) {
    return _relations
        .where((relation) =>
            relation.toNodeId == nodeId || relation.fromNodeId == nodeId)
        .isNotEmpty;
  }

  @override
  bool nodeIsLeaf(String nodeId) {
    return _relations
        .where((relation) => relation.fromNodeId == nodeId)
        .isNotEmpty;
  }

  @override
  Iterable<Node> allNodes() {
    return _nodes;
  }

  @override
  Iterable<Relation> allRelations() {
    return _relations;
  }

  @override
  Iterable<Relation> getRelationsBetween(String fromNodeId, String toNodeId,
      {bool bothDirections = true}) {
    List<Relation> side1, side2;
    side1 = _relations
        .where((relation) =>
            relation.toNodeId == toNodeId && relation.fromNodeId == fromNodeId)
        .toList(growable: false);

    if (bothDirections) {
      side2 = _relations
          .where((relation) =>
              relation.fromNodeId == toNodeId &&
              relation.toNodeId == fromNodeId)
          .toList(growable: false);
    } else {
      side2 = [];
    }

    return side1 + side2;
  }
}
