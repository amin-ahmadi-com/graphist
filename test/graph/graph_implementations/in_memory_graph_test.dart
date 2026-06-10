import 'package:flutter_test/flutter_test.dart';
import 'package:graphist/graph/base/node.dart';
import 'package:graphist/graph/base/relation.dart';
import 'package:graphist/graph/graph_implementations/in_memory_graph.dart';

void main() {
  group("InMemoryGraph Tests", () {
    late InMemoryGraph graph;

    setUp(() {
      graph = InMemoryGraph();
    });

    final node1 = Node(
      type: "User",
      properties: {"name": "Alice", "id": "1"},
      labelProperty: "name",
      uniqueProperty: "id",
      urlProperty: null,
    );
    final node2 = Node(
      type: "User",
      properties: {"name": "Bob", "id": "2"},
      labelProperty: "name",
      uniqueProperty: "id",
      urlProperty: null,
    );

    // --- addNode / allNodes / nodeExists ---

    test("addNode and allNodes", () {
      graph.addNode(node1);
      graph.addNode(node2);
      expect(graph.allNodes().length, 2);
      expect(graph.nodeExists("User-1"), true);
      expect(graph.nodeExists("User-2"), true);
    });

    test("getNode", () {
      graph.addNode(node1);
      expect(graph.getNode("User-1"), node1);
    });

    test("getNode returns correct node data", () {
      graph.addNode(node1);
      final retrieved = graph.getNode("User-1");
      expect(retrieved.type, "User");
      expect(retrieved.properties["name"], "Alice");
      expect(retrieved.properties["id"], "1");
    });

    test("getNode throws when node not found", () {
      expect(() => graph.getNode("NonExistent"), throwsStateError);
    });

    test("nodeExists returns true for added node", () {
      graph.addNode(node1);
      expect(graph.nodeExists("User-1"), true);
    });

    test("nodeExists returns false for non-existent node", () {
      expect(graph.nodeExists("NonExistent"), false);
    });

    test("addNode with replaceIfExists true replaces existing node", () {
      graph.addNode(node1);
      final updatedNode = Node(
        type: "User",
        properties: {"name": "Alice Updated", "id": "1"},
        labelProperty: "name",
        uniqueProperty: "id",
        urlProperty: null,
      );
      graph.addNode(updatedNode, replaceIfExists: true);
      final retrieved = graph.getNode("User-1");
      expect(retrieved.properties["name"], "Alice Updated");
    });

    test("addNode with replaceIfExists false keeps existing node", () {
      graph.addNode(node1);
      final updatedNode = Node(
        type: "User",
        properties: {"name": "Alice Updated", "id": "1"},
        labelProperty: "name",
        uniqueProperty: "id",
        urlProperty: null,
      );
      graph.addNode(updatedNode, replaceIfExists: false);
      final retrieved = graph.getNode("User-1");
      expect(retrieved.properties["name"], "Alice");
    });

    test("addNode without replaceIfExists (default) replaces existing node",
        () {
      graph.addNode(node1);
      final updatedNode = Node(
        type: "User",
        properties: {"name": "Alice Updated", "id": "1"},
        labelProperty: "name",
        uniqueProperty: "id",
        urlProperty: null,
      );
      graph.addNode(updatedNode);
      final retrieved = graph.getNode("User-1");
      expect(retrieved.properties["name"], "Alice Updated");
    });

    // --- removeNode ---

    test("removeNode", () {
      graph.addNode(node1);
      graph.removeNode("User-1");
      expect(graph.nodeExists("User-1"), false);
    });

    test("removeNode removes the correct node among many", () {
      graph.addNode(node1);
      graph.addNode(node2);
      graph.removeNode("User-1");
      expect(graph.nodeExists("User-1"), false);
      expect(graph.nodeExists("User-2"), true);
      expect(graph.allNodes().length, 1);
    });

    test("removeNode on non-existent node does nothing", () {
      expect(graph.nodeExists("NonExistent"), false);
      graph.removeNode("NonExistent");
      expect(graph.nodeExists("NonExistent"), false);
      expect(graph.allNodes().length, 0);
    });

    // --- addRelation / allRelations / relationExists ---

    test("addRelation and allRelations", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      expect(graph.allRelations().length, 1);
      expect(graph.relationExists(rel.id), true);
    });

    test("getRelation", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      final retrieved = graph.getRelation(rel.id);
      expect(retrieved.type, "Knows");
      expect(retrieved.fromNodeId, "User-1");
      expect(retrieved.toNodeId, "User-2");
      expect(retrieved.properties["strength"], "high");
    });

    test("getRelation throws when relation not found", () {
      expect(() => graph.getRelation("NonExistent"), throwsStateError);
    });

    test("relationExists returns true for added relation", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      expect(graph.relationExists(rel.id), true);
    });

    test("relationExists returns false for non-existent relation", () {
      expect(graph.relationExists("NonExistent"), false);
    });

    test("addRelation with replaceIfExists true replaces existing relation",
        () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      final updatedRel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "low"},
        labelProperty: "strength",
      );
      graph.addRelation(updatedRel, replaceIfExists: true);
      final retrieved = graph.getRelation(rel.id);
      expect(retrieved.properties["strength"], "low");
    });

    test("addRelation with replaceIfExists false keeps existing relation", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      final updatedRel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "low"},
        labelProperty: "strength",
      );
      graph.addRelation(updatedRel, replaceIfExists: false);
      final retrieved = graph.getRelation(rel.id);
      expect(retrieved.properties["strength"], "high");
    });

    // --- removeRelation ---

    test("removeRelation", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      graph.removeRelation(rel.id);
      expect(graph.relationExists(rel.id), false);
    });

    test("removeRelation removes the correct relation among many", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel1 = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      final rel2 = Relation(
        type: "Follows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "low"},
        labelProperty: "strength",
      );
      graph.addRelation(rel1);
      graph.addRelation(rel2);
      graph.removeRelation(rel1.id);
      expect(graph.relationExists(rel1.id), false);
      expect(graph.relationExists(rel2.id), true);
    });

    test("removeRelation on non-existent relation does nothing", () {
      expect(graph.relationExists("NonExistent"), false);
      graph.removeRelation("NonExistent");
      expect(graph.relationExists("NonExistent"), false);
    });

    // --- getRelationsFrom / getRelationsTo ---

    test("getRelationsFrom and getRelationsTo", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      expect(graph.getRelationsFrom(node1.id).length, 1);
      expect(graph.getRelationsTo(node2.id).length, 1);
    });

    // --- nodeIsConnected / nodeIsLeaf ---

    test("nodeIsConnected and nodeIsLeaf", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);

      expect(graph.nodeIsConnected(node1.id), true);
      expect(graph.nodeIsConnected(node2.id), true);
      expect(graph.nodeIsLeaf(node1.id), false);
      expect(graph.nodeIsLeaf(node2.id), true);
    });

    test("nodeIsConnected returns false for unconnected node", () {
      graph.addNode(node1);
      graph.addNode(node2);
      expect(graph.nodeIsConnected(node1.id), false);
      expect(graph.nodeIsConnected(node2.id), false);
    });

    test("nodeIsOrphan returns true for node without relations", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);

      expect(graph.nodeIsOrphan(node1.id), false);
      expect(graph.nodeIsOrphan(node2.id), false);
      expect(graph.nodeIsOrphan("User-3"), true);
    });

    test("nodeIsLeaf returns false for orphan node", () {
      graph.addNode(node1);

      expect(graph.nodeIsLeaf(node1.id), false);
      expect(graph.nodeIsOrphan(node1.id), true);
    });

    test("nodeIsLeaf returns false for non-leaf node", () {
      graph.addNode(node1);
      graph.addNode(node2);
      graph.addRelation(
        Relation(
          type: "Knows",
          fromNodeId: node1.id,
          toNodeId: node2.id,
          properties: {},
          labelProperty: "L",
        ),
      );
      expect(graph.nodeIsLeaf(node1.id), false);
    });

    // --- getRelationsBetween ---

    test("getRelationsBetween", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);

      expect(graph.getRelationsBetween(node1.id, node2.id).length, 1);
    });

    test("getRelationsBetween with bothDirections true", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel1 = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      final rel2 = Relation(
        type: "Follows",
        fromNodeId: node2.id,
        toNodeId: node1.id,
        properties: {"strength": "low"},
        labelProperty: "strength",
      );
      graph.addRelation(rel1);
      graph.addRelation(rel2);

      expect(
        graph
            .getRelationsBetween(node1.id, node2.id, bothDirections: true)
            .length,
        2,
      );
    });

    test("getRelationsBetween with bothDirections false", () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel1 = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      final rel2 = Relation(
        type: "Follows",
        fromNodeId: node2.id,
        toNodeId: node1.id,
        properties: {"strength": "low"},
        labelProperty: "strength",
      );
      graph.addRelation(rel1);
      graph.addRelation(rel2);

      expect(
        graph
            .getRelationsBetween(node1.id, node2.id, bothDirections: false)
            .length,
        1,
      );
    });

    test("getRelationsBetween does not duplicate self-loop", () {
      final rel = Relation(
        type: "Self",
        fromNodeId: node1.id,
        toNodeId: node1.id,
        properties: {"label": "self"},
        labelProperty: "label",
      );
      graph.addRelation(rel);

      final relations = graph
          .getRelationsBetween(node1.id, node1.id, bothDirections: true)
          .toList(growable: false);

      expect(relations, hasLength(1));
      expect(relations.single.id, rel.id);
    });

    // --- clear ---

    test("clear", () {
      graph.addNode(node1);
      graph.addRelation(
        Relation(
          type: "T",
          fromNodeId: "A",
          toNodeId: "B",
          properties: {},
          labelProperty: "L",
        ),
      );
      graph.clear();
      expect(graph.allNodes().length, 0);
      expect(graph.allRelations().length, 0);
    });

    // --- Edge cases / bulk queries ---

    test("empty graph has no nodes", () {
      expect(graph.allNodes().length, 0);
    });

    test("empty graph has no relations", () {
      expect(graph.allRelations().length, 0);
    });

    test("getRelationsFrom returns empty for node with no outgoing relations",
        () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      expect(graph.getRelationsFrom(node2.id).length, 0);
    });

    test("getRelationsTo returns empty for node with no incoming relations",
        () {
      graph.addNode(node1);
      graph.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      expect(graph.getRelationsTo(node1.id).length, 0);
    });

    test("graph with three nodes and multiple relations", () {
      final node3 = Node(
        type: "User",
        properties: {"name": "Charlie", "id": "3"},
        labelProperty: "name",
        uniqueProperty: "id",
        urlProperty: null,
      );
      graph.addNode(node1);
      graph.addNode(node2);
      graph.addNode(node3);

      final rel1 = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      final rel2 = Relation(
        type: "Knows",
        fromNodeId: node2.id,
        toNodeId: node3.id,
        properties: {"strength": "low"},
        labelProperty: "strength",
      );
      graph.addRelation(rel1);
      graph.addRelation(rel2);

      expect(graph.allNodes().length, 3);
      expect(graph.allRelations().length, 2);
      expect(graph.getRelationsFrom(node1.id).length, 1);
      expect(graph.getRelationsFrom(node2.id).length, 1);
      expect(graph.getRelationsTo(node3.id).length, 1);
      expect(graph.nodeIsConnected(node3.id), true);
      expect(graph.nodeIsLeaf(node3.id), true);
      expect(graph.nodeIsLeaf(node1.id), false);
    });
  });
}
