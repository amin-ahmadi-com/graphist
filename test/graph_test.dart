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

    test("removeNode", () {
      graph.addNode(node1);
      graph.removeNode("User-1");
      expect(graph.nodeExists("User-1"), false);
    });

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
    });

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

    test("clear", () {
      graph.addNode(node1);
      graph.addRelation(
        Relation(type: "T", fromNodeId: "A", toNodeId: "B", properties: {}, labelProperty: "L"),
      );
      graph.clear();
      expect(graph.allNodes().length, 0);
      expect(graph.allRelations().length, 0);
    });
  });
}
