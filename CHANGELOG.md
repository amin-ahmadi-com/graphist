## 0.5.0

* Added `nodeIsOrphan` and `nodeIsNotOrphan` helpers for disconnected nodes
* Fixed `nodeIsLeaf` so orphan nodes are not reported as leaves
* Fixed `replaceIfExists: false` handling for nodes and relations
* Made SQLite node and relation writes transactional
* Fixed duplicate self-loop results in `getRelationsBetween`
* Improved SQLite persistence and graph behavior test coverage

## 0.4.0

* Added `SqliteGraph` — a persistent graph implementation backed by SQLite with support for nodes, relations, and key-value properties
* Restructured folders
* Added more and better unit tests
* Bug fixes

## 0.3.2

* Fixed `nodeIsLeaf` — now correctly returns `true` when a node has no outgoing relations (i.e., it is a terminal leaf node)
* Fixed `getRelationsBetween` signature to match the `Graph` interface
* Updated README with comprehensive usage instructions

## 0.3.1

* Added Relation tests.
* Improved package validation — clean build with 0 warnings.

## 0.3.0

* Updated SDK constraints to Dart 3.0+ and Flutter 3.0+.
* Expanded README with comprehensive usage instructions and examples.
* Added extensive test suite for `InMemoryGraph`.

## 0.2.5

* Example added

## 0.2.4

* Added icons

## 0.2.3

* Documentation and examples

## 0.2.2

* dartdoc issues fixed

## 0.2.1

* LICENSE fixed/updated

## 0.2.0

* Reorganized and restructured (first functional version)
