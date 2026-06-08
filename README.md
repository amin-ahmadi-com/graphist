# Graphist

Graph capabilities for Flutter. Graphist provides a flexible way to represent and visualize data as graphs (nodes and relations).

## Features

- **Flexible Graph Structure**: Represent any data as nodes and relations.
- **Customizable Nodes**: Define node types, properties, and visual icons.
- **Dynamic Relations**: Create typed relationships between nodes.
- **In-Memory Implementation**: Ready-to-use `InMemoryGraph` for small to medium datasets.
- **Visual Widgets**: Integrated Flutter widgets (`GraphWidget`, `GraphController`) to manage graph state and rendering.

## Getting Started

### Installation

Add `graphist` to your `pubspec.yaml`:

```yaml
dependencies:
  graphist: ^0.3.1
```

### Basic Usage

Here is a simple example of how to set up a graph and add nodes and relations:

```dart
import 'package:graphist/graphist.dart';

void main() {
  final graph = InMemoryGraph();

  // Create a node
  final userNode = Node(
    type: 'User',
    properties: {'name': 'John Doe', 'email': 'john@example.com'},
    labelProperty: 'name',
    uniqueProperty: 'email',
    urlProperty: null,
  );

  // Create another node
  final productNode = Node(
    type: 'Product',
    properties: {'title': 'Smartphone', 'sku': 'SKU123'},
    labelProperty: 'title',
    uniqueProperty: 'sku',
    urlProperty: null,
  );

  graph.addNode(userNode);
  graph.addNode(productNode);

  // Create a relation between them
  final purchaseRelation = Relation(
    type: 'Purchased',
    fromNodeId: userNode.id,
    toNodeId: productNode.id,
    properties: {'date': '2023-10-27'},
    labelProperty: 'date',
  );

  graph.addRelation(purchaseRelation);

  print('Total nodes: ${graph.allNodes().length}'); // 2
  print('Total relations: ${graph.allRelations().length}'); // 1
}
```

## API Reference

- `Graph`: Abstract base class for graph implementations.
- `Node`: Represents a vertex in the graph.
- `Relation`: Represents an edge between two nodes.
- `InMemoryGraph`: A complete implementation of the `Graph` interface stored in memory.
- `GraphWidget`: Flutter widget for rendering the graph.

## Examples

For more advanced examples, see:
- [File System Graph](https://github.com/amin-ahmadi-com/file_system_graph)
- Related packages on pub.dev (e.g., `graphist_file_system`, `graphist_mesh_sqlite`).

## License

This project is licensed under the MIT License.
