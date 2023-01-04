import 'node.dart';
import 'relation.dart';

/// Graph is an abstract class that defines common interfaces required from a
/// graph. Everything that has to do with managing Nodes and Relations.
abstract class Graph {

  /// Add a new Node to graph
  void addNode(Node node, {bool replaceIfExists = true});

  bool nodeExists(String nodeId);

  bool nodeDoesNotExist(String nodeId) => !nodeExists(nodeId);

  Node getNode(String nodeId);

  /// Check if a Node has at least one Relation to it, but none from it.
  bool nodeIsLeaf(String nodeId);

  bool nodeIsNotLeaf(String nodeId) => !nodeIsLeaf(nodeId);

  /// Check if a Node has at least one Relation to or from it.
  bool nodeIsConnected(String nodeId);

  bool nodeIsDisconnected(String nodeId) => !nodeIsConnected(nodeId);

  void removeNode(String nodeId);

  void addRelation(Relation relation, {bool replaceIfExists = true});

  bool relationExists(String relationId);

  Relation getRelation(String relationId);

  Iterable<Relation> getRelationsFrom(String nodeId);

  Iterable<Relation> getRelationsTo(String nodeId);

  void removeRelation(String relationId);

  void clear();

  Iterable<Node> allNodes();

  Iterable<Relation> allRelations();

  Iterable<Relation> getRelationsBetween(String fromNodeId, String toNodeId);
}
