import 'node.dart';
import 'relation.dart';

/// Graph is an abstract class that defines common interfaces required from a
/// graph. Everything that has to do with managing Nodes and Relations.
abstract class Graph {
  /// Add a new node to graph
  void addNode(Node node, {bool replaceIfExists = true});

  /// Check if a node exists (by id)
  bool nodeExists(String nodeId);

  /// Opposite of nodeDoesNotExist
  bool nodeDoesNotExist(String nodeId) => !nodeExists(nodeId);

  /// Get node (by id)
  Node getNode(String nodeId);

  /// Check if a Node has at least one Relation to it, but none from it.
  bool nodeIsLeaf(String nodeId);

  /// Opposite of nodeIsLeaf
  bool nodeIsNotLeaf(String nodeId) => !nodeIsLeaf(nodeId);

  /// Check if a Node has at least one Relation to or from it.
  bool nodeIsConnected(String nodeId);

  /// Opposite of nodeIsConnected
  bool nodeIsDisconnected(String nodeId) => !nodeIsConnected(nodeId);

  /// Remove a node from the graph (by id)
  void removeNode(String nodeId);

  /// Add a new relation to the graph
  void addRelation(Relation relation, {bool replaceIfExists = true});

  /// Check if a relation exists (by id)
  bool relationExists(String relationId);

  /// Get a relation (by id)
  Relation getRelation(String relationId);

  /// Get relations starting from this node
  Iterable<Relation> getRelationsFrom(String nodeId);

  /// Get relations ending at this node
  Iterable<Relation> getRelationsTo(String nodeId);

  /// Remove a relation (by id)
  void removeRelation(String relationId);

  /// Clear the graph.
  /// This removes all nodes and relations from the graph.
  void clear();

  /// Get all nodes.
  Iterable<Node> allNodes();

  /// Get all relations.
  Iterable<Relation> allRelations();

  /// Get relations from a given node to another (by id)
  Iterable<Relation> getRelationsBetween(String fromNodeId, String toNodeId);
}
