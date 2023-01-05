/// Base class of all Relations between Nodes.
class Relation {
  /// Type of Relation
  final String type;

  /// Id of the Node at the starting end of the Relation
  final String fromNodeId;

  /// Id of the Node at the finishing end of the Relation
  final String toNodeId;

  /// Relation properties. Keys must be string and values must be JSON serializable.
  final Map<String, dynamic> properties;

  /// A property key within properties to be used as the label of the node.
  /// Mainly used for visual identification purposes.
  final String labelProperty;

  Relation({
    required this.type,
    required this.fromNodeId,
    required this.toNodeId,
    required this.properties,
    required this.labelProperty,
  });

  /// Identifier of this Node. It's a combination of Relation type and Node ids
  /// involved in this Relation, concatenated by a dash.
  ///
  /// The logic behind this implementation is that there cannot be more than one
  /// Relations of a given type between two given Nodes. If we need to indicate
  /// a type of Relation happening more than once between two nodes, they can
  /// definitely be represented as additional properties of the same Relation.
  /// For example, if the Relation between the Node PLAYER and MATCH is SCORED,
  /// and the Relation SCORED can potentially occur more than once between PLAYER
  /// and MATCH, then instead of having multiple SCORED Relations between those
  /// two Nodes, we need to use multiple properties on SCORED to represent it.
  String get id => "$type-$fromNodeId-$toNodeId";

  String get label => properties[labelProperty];

  /// Equality checks for Relation id only
  @override
  bool operator ==(Object other) {
    return other is Relation && other.id == id;
  }

  /// Hash code of this Relation, which is equal to hash code of the Relation id.
  @override
  int get hashCode => id.hashCode;

  /// Construct a Relation from a JSON object.
  factory Relation.fromJson(dynamic json) {
    return Relation(
      type: json["type"],
      fromNodeId: json["fromNodeId"],
      toNodeId: json["toNodeId"],
      properties: json["properties"],
      labelProperty: json["labelProperty"],
    );
  }

  /// Create JSON serializable representation of this Relation.
  dynamic toJson() => {
        "type": type,
        "fromNodeId": fromNodeId,
        "toNodeId": toNodeId,
        "properties": properties,
        "labelProperty": labelProperty,
      };
}
