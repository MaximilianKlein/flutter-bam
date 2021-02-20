import 'package:flutter_bam/src/specs/source_graph/block.dart';
import 'package:flutter_bam/src/specs/source_graph/condition.dart';
import 'package:flutter_bam/src/specs/source_graph/if.dart';
import 'package:meta/meta.dart';

import 'package:flutter_bam/src/specs/source_graph/node.dart';

class SourceEdge {
  const SourceEdge({
    @required this.start,
    @required this.end,
  });

  final SourceNode start;
  final SourceNode end;
}

class SourceGraph {
  const SourceGraph({
    @required this.nodes,
    @required this.edges,
    @required this.startNode,
    @required this.endNodes,
  });

  final List<SourceNode> nodes;
  final List<SourceEdge> edges;
  final SourceNode startNode;
  final List<SourceNode> endNodes;

  int _nodeIndex(SourceNode node) {
    return nodes.indexWhere((_node) => _node.id() == node.id());
  }

  SourceFormula _condition(SourceEdge edge) {
    if (edge is SourceConditionalEdge) {
      return edge.condition;
    }
    return null;
  }

  List<List<SourceNode>> _pathsFrom(SourceNode node) {
    final path = [node];
    SourceNode curNode = node;
    while (true) {
      if (endNodes.contains(curNode)) {
        return [path];
      }
      final nodeOutEdges = edges.where((edge) => edge.start == curNode);
      if (nodeOutEdges.length > 1) {
        return [
          ...nodeOutEdges
              .expand((edge) => _pathsFrom(edge.end).map((pathSuffix) => [
                    ...path,
                    ...pathSuffix,
                  ]))
        ];
      } else if (nodeOutEdges.isNotEmpty) {
        path.add(nodeOutEdges.first.end);
        curNode = nodeOutEdges.first.end;
      } else {
        return [];
      }
    }
  }

  List<List<SourceNode>> paths() {
    return _pathsFrom(startNode)
        .where((element) => element.isNotEmpty)
        .toList();
  }

  @override
  String toString() {
    return '''
nodes:
  ${nodes.map((node) => '<${_nodeIndex(node)}, $node>').join('\n  ')}
edges:
  ${edges.map((edge) => '<${_nodeIndex(edge.start)}, ${_nodeIndex(edge.end)}, cond: ${_condition(edge)}>').join('\n  ')}
startNode: ${_nodeIndex(startNode)}
endNode: ${endNodes.map((endNode) => _nodeIndex(endNode))}
''';
  }
}
