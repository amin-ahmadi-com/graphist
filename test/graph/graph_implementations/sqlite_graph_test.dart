import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphist/graph/base/node.dart';
import 'package:graphist/graph/base/relation.dart';
import 'package:graphist/graph/graph_implementations/sqlite_graph.dart';
import 'package:path/path.dart' as path;

void main() {
  group("SqliteGraph Tests", () {
    late SqliteGraph graph;
    late String dbPath;

    setUp(() {
      dbPath = path.join(Directory.systemTemp.absolute.path, 'graphist_test_${DateTime.now().microsecond}.db');
      graph = SqliteGraph(dbPath: dbPath);
    });

    tearDown(() {
      graph.dispose();
      try {
        File(dbPath).delete();
      } catch (_) {}
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
      final retrieved = graph.getNode("User-1");
      expect(retrieved.id, node1.id);
      expect(retrieved.properties["name"], "Alice");
     });

    test("getNode throws when not found", () {
      expect(() => graph.getNode("NonExistent"), throwsStateError);
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
      expect(retrieved.id, rel.id);
      expect(retrieved.properties["strength"], "high");
     });

    test("getRelation throws when not found", () {
      expect(() => graph.getRelation("NonExistent"), throwsStateError);
     });

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
      expect(graph.nodeIsLeaf(node2.id), true);
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

    test("getRelationsBetween with bothDirections", () {
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
        graph.getRelationsBetween(node1.id, node2.id, bothDirections: true).length,
        2,
      );
      expect(
        graph.getRelationsBetween(node1.id, node2.id, bothDirections: false).length,
        1,
      );
     });

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

    test("persist and re-open", () async {
      final reopenPath = path.join(
        Directory.systemTemp.absolute.path,
         'graphist_reopen_${DateTime.now().microsecond}.db',
        );

      final graph1 = SqliteGraph(dbPath: reopenPath);
      graph1.addNode(node1);
      graph1.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
        );
      graph1.addRelation(rel);

      graph1.dispose();

      final graph2 = SqliteGraph(dbPath: reopenPath);

      expect(graph2.nodeExists(node1.id), true);
      expect(graph2.nodeExists(node2.id), true);
      expect(graph2.allNodes().length, 2);
      expect(graph2.allRelations().length, 1);

      graph2.dispose();
      await File(reopenPath).delete();
     });

    test("replaceIfExists", () {
      final updated = Node(
        type: "User",
        properties: {"name": "Alice Updated", "id": "1"},
        labelProperty: "name",
        uniqueProperty: "id",
        urlProperty: null,
       );
      graph.addNode(node1, replaceIfExists: true);
      graph.addNode(updated, replaceIfExists: true);

      final retrieved = graph.getNode("User-1");
      expect(retrieved.properties["name"], "Alice Updated");
     });

    test("nodeIsDisconnected", () {
      graph.addNode(node1);
      graph.addNode(node2);
      expect(graph.nodeIsConnected(node1.id), false);
      expect(graph.nodeIsConnected(node2.id), false);
     });

    test("relationExists", () {
      graph.addNode(node1);
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
       );
      graph.addRelation(rel);
      expect(graph.relationExists(rel.id), true);
      expect(graph.relationExists("NonExistent"), false);
     });
  });
}
