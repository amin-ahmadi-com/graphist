import 'package:flutter_test/flutter_test.dart';
import 'package:graphist/graph/base/relation.dart';

void main() {
  test("Relation construction", () {
    final relation = Relation(
      type: "Knows",
      fromNodeId: "User-1",
      toNodeId: "User-2",
      properties: {"strength": "high", "since": "2020"},
      labelProperty: "strength",
    );

    expect(relation.id, "Knows-User-1-User-2");
    expect(relation.label, "high");
  });

  test("Relation fromJson", () {
    final relation = Relation.fromJson({
      "type": "Knows",
      "fromNodeId": "User-1",
      "toNodeId": "User-2",
      "properties": {"strength": "low", "since": "2019"},
      "labelProperty": "strength",
    });

    expect(relation.id, "Knows-User-1-User-2");
    expect(relation.label, "low");
    expect(relation.type, "Knows");
    expect(relation.fromNodeId, "User-1");
    expect(relation.toNodeId, "User-2");
    expect(relation.properties["strength"], "low");
    expect(relation.properties["since"], "2019");
  });

  test("Relation toJson", () {
    final relation = Relation(
      type: "Knows",
      fromNodeId: "User-1",
      toNodeId: "User-2",
      properties: {"strength": "high", "since": "2020"},
      labelProperty: "strength",
    );

    final json = relation.toJson();

    expect(json["type"], "Knows");
    expect(json["fromNodeId"], "User-1");
    expect(json["toNodeId"], "User-2");
    expect(json["properties"]["strength"], "high");
    expect(json["properties"]["since"], "2020");
    expect(json["labelProperty"], "strength");
  });

  test("Relation equality", () {
    final relation1 = Relation(
      type: "Knows",
      fromNodeId: "User-1",
      toNodeId: "User-2",
      properties: {"strength": "high"},
      labelProperty: "strength",
    );

    final relation2 = Relation(
      type: "Knows",
      fromNodeId: "User-1",
      toNodeId: "User-2",
      properties: {"different": "value"},
      labelProperty: "different",
    );

    expect(relation1, equals(relation2));
    expect(relation1.hashCode, equals(relation2.hashCode));
  });

  test("Relation toJson toJson roundtrip", () {
    final originalJson = {
      "type": "Knows",
      "fromNodeId": "User-1",
      "toNodeId": "User-2",
      "properties": {"strength": "high"},
      "labelProperty": "strength",
    };

    final relation = Relation.fromJson(originalJson);
    final roundtripJson = relation.toJson();

    expect(roundtripJson, equals(originalJson));
  });
}
