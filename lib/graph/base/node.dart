import 'dart:convert';

import 'package:tuple/tuple.dart';

import 'relation.dart';

/// Base class of all Nodes
class Node {
  /// Node type
  final String type;

  /// Node properties. Keys must be string and values must be JSON serializable.
  final Map<String, dynamic> properties;

  /// A property key within properties to be used as the label of the node.
  /// Mainly used for visual identification purposes.
  final String labelProperty;

  /// A property key within properties that is unique for a given Node type.
  final String uniqueProperty;

  /// A property key within properties that contains a launchable URL (web address).
  final String? urlProperty;

  /// Node icon
  final NodeIcon icon;

  Node({
    required this.type,
    required this.properties,
    required this.labelProperty,
    required this.uniqueProperty,
    required this.urlProperty,
    this.icon = const NodeIcon(), // Material icon for circle
  });

  /// Identifier of this Node. It's a combination of Node type and its unique
  /// property, concatenated by a dash.
  String get id => "$type-${properties[uniqueProperty]}";

  /// Getter for label property
  String get label => properties[labelProperty];

  /// Getter for unique value property
  String get uniqueValue => properties[uniqueProperty];

  /// Getter for url
  String? get url => urlProperty == null ? null : properties[urlProperty];

  /// Equality checks for Node id only
  @override
  bool operator ==(Object other) {
    return other is Node && other.id == id;
  }

  /// Hash code of this Node, which is equal to hash code of the Node id.
  @override
  int get hashCode => id.hashCode;

  /// Construct a Node from a JSON object.
  factory Node.fromJson(dynamic json) {
    return Node(
      type: json["type"],
      properties: json["properties"],
      labelProperty: json["labelProperty"],
      uniqueProperty: json["uniqueProperty"],
      urlProperty: json["urlProperty"],
      icon: NodeIcon.fromJson(json["icon"]),
    );
  }

  /// Create JSON serializable representation of this Node.
  dynamic toJson() => {
        "type": type,
        "properties": properties,
        "labelProperty": labelProperty,
        "uniqueProperty": uniqueProperty,
        "urlProperty": urlProperty,
        "icon": icon.toJson(),
      };

  /// Relatives of this node that can be generated if/when needed.
  /// Subclasses must implement this getter, while making sure each generated
  /// Relation either starts or ends at this Node.
  Future<Iterable<Tuple2<Relation, Node>>> get relatives async => [];

  /// Generates a string of the JSON output of this node
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

/// NodeIcon is
class NodeIcon {
  final String fontFamily;
  final int codePoint;

  const NodeIcon({this.fontFamily = "MaterialIcons", this.codePoint = 0xe163});

  /// Construct a NodeIcon from a JSON object.
  factory NodeIcon.fromJson(dynamic json) {
    return NodeIcon(
      fontFamily: json["fontFamily"],
      codePoint: json["codePoint"],
    );
  }

  /// Create JSON serializable representation of this NodeIcon.
  dynamic toJson() => {
        "fontFamily": fontFamily,
        "codePoint": codePoint,
      };

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    return other is NodeIcon &&
        other.fontFamily == fontFamily &&
        other.codePoint == codePoint;
  }

  @override
  int get hashCode => toString().hashCode;
}
