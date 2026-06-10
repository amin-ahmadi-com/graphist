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
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('graphist_test_');
      dbPath = path.join(tempDir.path, 'graphist_test.db');
      graph = SqliteGraph(dbPath: dbPath);
    });

    tearDown(() {
      graph.dispose();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
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
        graph
            .getRelationsBetween(node1.id, node2.id, bothDirections: true)
            .length,
        2,
      );
      expect(
        graph
            .getRelationsBetween(node1.id, node2.id, bothDirections: false)
            .length,
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

    test("persist and re-open", () {
      final reopenDir = Directory.systemTemp.createTempSync('graphist_reopen_');
      final reopenPath = path.join(reopenDir.path, 'graphist_reopen.db');
      final nodeWithDetails = Node(
        type: "User",
        properties: {
          "name": "Alice",
          "id": "1",
          "website": "https://example.com/alice",
          "score": 10,
          "tags": ["admin", "owner"],
        },
        labelProperty: "name",
        uniqueProperty: "id",
        urlProperty: "website",
        icon: const NodeIcon(fontFamily: "CustomIcons", codePoint: 12345),
      );

      final graph1 = SqliteGraph(dbPath: reopenPath);
      graph1.addNode(nodeWithDetails);
      graph1.addNode(node2);
      final rel = Relation(
        type: "Knows",
        fromNodeId: nodeWithDetails.id,
        toNodeId: node2.id,
        properties: {"strength": "high", "since": 2024},
        labelProperty: "strength",
      );
      graph1.addRelation(rel);

      graph1.dispose();

      final graph2 = SqliteGraph(dbPath: reopenPath);

      expect(graph2.nodeExists(nodeWithDetails.id), true);
      expect(graph2.nodeExists(node2.id), true);
      expect(graph2.allNodes().length, 2);
      expect(graph2.allRelations().length, 1);

      final restoredNode = graph2.getNode(nodeWithDetails.id);
      expect(restoredNode.type, nodeWithDetails.type);
      expect(restoredNode.properties, nodeWithDetails.properties);
      expect(restoredNode.labelProperty, nodeWithDetails.labelProperty);
      expect(restoredNode.uniqueProperty, nodeWithDetails.uniqueProperty);
      expect(restoredNode.urlProperty, nodeWithDetails.urlProperty);
      expect(restoredNode.icon, nodeWithDetails.icon);

      final restoredRelation = graph2.getRelation(rel.id);
      expect(restoredRelation.type, rel.type);
      expect(restoredRelation.fromNodeId, rel.fromNodeId);
      expect(restoredRelation.toNodeId, rel.toNodeId);
      expect(restoredRelation.properties, rel.properties);
      expect(restoredRelation.labelProperty, rel.labelProperty);

      graph2.dispose();
      reopenDir.deleteSync(recursive: true);
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

    test("addNode with replaceIfExists false keeps existing node", () {
      final updated = Node(
        type: "User",
        properties: {"name": "Alice Updated", "id": "1"},
        labelProperty: "name",
        uniqueProperty: "id",
        urlProperty: null,
      );
      graph.addNode(node1);
      graph.addNode(updated, replaceIfExists: false);

      final retrieved = graph.getNode("User-1");
      expect(retrieved.properties["name"], "Alice");
      expect(graph.allNodes().length, 1);
    });

    test("addRelation with replaceIfExists false keeps existing relation", () {
      final rel = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "high"},
        labelProperty: "strength",
      );
      final updated = Relation(
        type: "Knows",
        fromNodeId: node1.id,
        toNodeId: node2.id,
        properties: {"strength": "low"},
        labelProperty: "strength",
      );
      graph.addRelation(rel);
      graph.addRelation(updated, replaceIfExists: false);

      final retrieved = graph.getRelation(rel.id);
      expect(retrieved.properties["strength"], "high");
      expect(graph.allRelations().length, 1);
    });

    test("nodeIsDisconnected", () {
      graph.addNode(node1);
      graph.addNode(node2);
      expect(graph.nodeIsConnected(node1.id), false);
      expect(graph.nodeIsConnected(node2.id), false);
    });

    test("nodeIsOrphan", () {
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
  });
}
