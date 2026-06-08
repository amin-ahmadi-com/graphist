import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../base/graph.dart';
import '../base/node.dart';
import '../base/relation.dart';

/// A persistent graph implementation backed by SQLite.
///
/// Stores [Node] and [Relation] objects as JSON in two tables:
/// - `nodes`: id, type, properties, labelProperty, uniqueProperty, urlProperty, icon
/// - `relations`: id, type, fromNodeId, toNodeId, properties, labelProperty
class SqliteGraph extends Graph {
  final String dbPath;
  late final Database _db;

   /// Creates a [SqliteGraph] storing data at [dbPath].
   ///
   /// The database and required tables are initialized eagerly.
  SqliteGraph({required this.dbPath}) {
     _db = sqlite3.open(path.normalize(dbPath));
     _initializeDb();
   }

  void _initializeDb() {
     _db.execute(
       '''CREATE TABLE IF NOT EXISTS nodes (
        id TEXT PRIMARY KEY,
        type TEXT,
        properties TEXT,
        labelProperty TEXT,
        uniqueProperty TEXT,
        urlProperty TEXT,
        icon TEXT
       )''',
     );

     _db.execute(
       '''CREATE TABLE IF NOT EXISTS relations (
        id TEXT PRIMARY KEY,
        type TEXT,
        fromNodeId TEXT,
        toNodeId TEXT,
        properties TEXT,
        labelProperty TEXT
       )''',
     );
   }

  List<Object?> _nodeToRow(Node node) {
    return [
      node.id,
      node.type,
      jsonEncode(node.properties),
      node.labelProperty,
      node.uniqueProperty,
      node.urlProperty,
      jsonEncode(node.icon.toJson()),
    ];
   }

  List<Object?> _relationToRow(Relation relation) {
    return [
      relation.id,
      relation.type,
      relation.fromNodeId,
      relation.toNodeId,
      jsonEncode(relation.properties),
      relation.labelProperty,
    ];
   }

  Node _rowToNode(Row row) {
    return Node(
      type: row['type'] as String,
      properties: Map<String, dynamic>.from(
        jsonDecode(row['properties'] as String),
      ),
      labelProperty: row['labelProperty'] as String,
      uniqueProperty: row['uniqueProperty'] as String,
      urlProperty: row['urlProperty'] as String?,
      icon: NodeIcon.fromJson(jsonDecode(row['icon'] as String)),
    );
   }

  Relation _rowToRelation(Row row) {
    return Relation(
      type: row['type'] as String,
      fromNodeId: row['fromNodeId'] as String,
      toNodeId: row['toNodeId'] as String,
      properties: Map<String, dynamic>.from(
        jsonDecode(row['properties'] as String),
      ),
      labelProperty: row['labelProperty'] as String,
    );
   }

  Iterable<Row> _select(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) {
    String query = 'SELECT * FROM $table';
    if (where != null) {
      query += ' WHERE $where';
    }
    return _db.select(query, whereArgs ?? const []);
   }

   @override
  void addNode(Node node, {bool replaceIfExists = true}) {
    final row = _nodeToRow(node);
    if (replaceIfExists) {
       _db.execute('DELETE FROM nodes WHERE id = ?', [node.id]);
    }
     _db.execute(
      'INSERT INTO nodes '
      '(id, type, properties, labelProperty, uniqueProperty, urlProperty, icon) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      row,
    );
   }

   @override
  void addRelation(Relation relation, {bool replaceIfExists = true}) {
    final row = _relationToRow(relation);
    if (replaceIfExists) {
       _db.execute('DELETE FROM relations WHERE id = ?', [relation.id]);
    }
     _db.execute(
      'INSERT INTO relations '
      '(id, type, fromNodeId, toNodeId, properties, labelProperty) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      row,
    );
   }

   @override
  void clear() {
     _db.execute('DELETE FROM nodes');
     _db.execute('DELETE FROM relations');
   }

   @override
  Node getNode(String nodeId) {
    final rows = _select(
      'nodes',
      where: 'id = ?',
      whereArgs: [nodeId],
    );
    if (rows.isEmpty) {
      throw StateError('Node with id $nodeId not found');
    }
    return _rowToNode(rows.first);
   }

   @override
  Relation getRelation(String relationId) {
    final rows = _select(
      'relations',
      where: 'id = ?',
      whereArgs: [relationId],
    );
    if (rows.isEmpty) {
      throw StateError('Relation with id $relationId not found');
    }
    return _rowToRelation(rows.first);
   }

   @override
  Iterable<Relation> getRelationsFrom(String nodeId) {
    return _mapRelations(
      _select(
        'relations',
        where: 'fromNodeId = ?',
        whereArgs: [nodeId],
      ),
    );
   }

   @override
  Iterable<Relation> getRelationsTo(String nodeId) {
    return _mapRelations(
      _select(
        'relations',
        where: 'toNodeId = ?',
        whereArgs: [nodeId],
      ),
    );
   }

   @override
  bool nodeExists(String nodeId) {
    return _select(
      'nodes',
      where: 'id = ?',
      whereArgs: [nodeId],
    ).isNotEmpty;
   }

   @override
  bool relationExists(String relationId) {
    return _select(
      'relations',
      where: 'id = ?',
      whereArgs: [relationId],
    ).isNotEmpty;
   }

   @override
  void removeNode(String nodeId) {
     _db.execute('DELETE FROM nodes WHERE id = ?', [nodeId]);
   }

   @override
  void removeRelation(String relationId) {
     _db.execute('DELETE FROM relations WHERE id = ?', [relationId]);
   }

   @override
  bool nodeIsConnected(String nodeId) {
    return _select(
      'relations',
      where: 'toNodeId = ? OR fromNodeId = ?',
      whereArgs: [nodeId, nodeId],
    ).isNotEmpty;
   }

   @override
  bool nodeIsLeaf(String nodeId) {
    return _select(
      'relations',
      where: 'fromNodeId = ?',
      whereArgs: [nodeId],
    ).isEmpty;
   }

   @override
  Iterable<Node> allNodes() {
    return _mapNodes(_db.select('SELECT * FROM nodes'));
   }

   @override
  Iterable<Relation> allRelations() {
    return _mapRelations(_db.select('SELECT * FROM relations'));
   }

   @override
  Iterable<Relation> getRelationsBetween(
    String fromNodeId,
    String toNodeId, {
    bool bothDirections = true,
  }) {
    final side1 = _mapRelations(
      _select(
        'relations',
        where: 'toNodeId = ? AND fromNodeId = ?',
        whereArgs: [toNodeId, fromNodeId],
      ),
    ).toList(growable: false);

    if (bothDirections) {
      final side2 = _mapRelations(
        _select(
          'relations',
          where: 'fromNodeId = ? AND toNodeId = ?',
          whereArgs: [toNodeId, fromNodeId],
        ),
      ).toList(growable: false);
      return side1 + side2;
    }

    return side1;
   }

  Iterable<Node> _mapNodes(Iterable<Row> rows) sync* {
    for (final row in rows) {
      yield _rowToNode(row);
    }
   }

  Iterable<Relation> _mapRelations(Iterable<Row> rows) sync* {
    for (final row in rows) {
      yield _rowToRelation(row);
    }
   }

   /// Closes the database connection and releases associated resources.
  void dispose() {
     _db.dispose();
   }
}
