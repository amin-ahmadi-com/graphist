import 'package:flutter_test/flutter_test.dart';
import 'package:graphist/graph/base/node.dart';

void main() {
  test("Node construction", () {
    final node = Node(
      type: "TestType",
      properties: {
        "no": 123,
        "name": "Graphist",
        "website": "https://graphist.dev",
      },
      labelProperty: "name",
      uniqueProperty: "no",
      urlProperty: "website",
    );

    expect(node.id, "TestType-123");
    expect(node.label, "Graphist");
    expect(node.url, "https://graphist.dev");
    expect(node.toJson(), {
      "type": node.type,
      "properties": node.properties,
      "labelProperty": node.labelProperty,
      "uniqueProperty": node.uniqueProperty,
      "urlProperty": node.urlProperty,
    });
  });

  test("Node fromJson", () {
    final node = Node.fromJson({
      "type": "TestType",
      "properties": {
        "no": 123,
        "name": "Graphist",
        "website": "https://graphist.dev",
      },
      "labelProperty": "name",
      "uniqueProperty": "no",
      "urlProperty": "website",
    });

    expect(node.id, "TestType-123");
    expect(node.label, "Graphist");
    expect(node.url, "https://graphist.dev");
    expect(node.toJson(), {
      "type": node.type,
      "properties": node.properties,
      "labelProperty": node.labelProperty,
      "uniqueProperty": node.uniqueProperty,
      "urlProperty": node.urlProperty,
    });
  });
}
