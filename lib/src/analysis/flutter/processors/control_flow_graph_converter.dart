import 'dart:math';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_bam/src/specs/source_graph/block.dart';
import 'package:flutter_bam/src/specs/source_graph/condition.dart';
import 'package:flutter_bam/src/specs/source_graph/expression.dart';
import 'package:flutter_bam/src/specs/source_graph/function.dart';
import 'package:flutter_bam/src/specs/source_graph/graph.dart';
import 'package:flutter_bam/src/specs/source_graph/if.dart';
import 'package:flutter_bam/src/specs/source_graph/node.dart';
import 'package:flutter_bam/src/specs/source_graph/statement.dart';
import 'package:flutter_bam/src/utils/neighbors.dart';
import 'package:flutter_bam/src/utils/of.dart';

class _AstIfCase {
  const _AstIfCase(this.condition, this.block) : assert(block != null);

  final Expression condition;
  final Statement block;
}

class _SourceIfCase {
  const _SourceIfCase(this.edge, this.block)
      : assert(edge != null),
        assert(block != null);

  final SourceConditionalEdge edge;
  final SourceGraph block;
}

class ControlGraphConverter {
  const ControlGraphConverter();

  SourceGraph contractEdges(SourceGraph graph) {
    // we can combine nodes that have indegree = 1 and outdegree = 1
    // if we find a non-start / non-end node with indegree equal to
    // 0 we found a problem in our conversion. It is a node that is never
    // reachable (should not happen)
    final Map<int, int> inDegree = {};
    final Map<int, int> outDegree = {};

    return graph;
  }

  /// merges the list of source graphs into one. The order is important
  /// it will determine which end nodes are connected to which starting nodes.
  /// If you there are branching graphs make sure that all branches are
  /// connected to the end node (even returns). The merge algorithm will
  /// ensure that those returns then get connected to the new end-node
  /// If you want to combine a function graph with another function graph
  /// this is not the correct function consider (not yet implemented) `combine`
  SourceGraph merge(List<SourceGraph> graphs) {
    if (graphs.isEmpty) {
      final noop = SourceNode.Noop();
      return SourceGraph(
          nodes: [noop], edges: [], startNode: noop, endNodes: [noop]);
    }
    return SourceGraph(
      nodes: graphs.expand((graph) => graph.nodes).toList(),
      edges: [
        ...graphs.expand((graph) => graph.edges),
        ...graphs.neighborsExpand((prev, next) => prev.endNodes
            .map((endNode) => SourceEdge(start: endNode, end: next.startNode))),
      ],
      startNode: graphs.first.startNode,
      endNodes: graphs
          .expand((graph) => graph.endNodes
              .where((node) => (node is SourceBlock && node.hasReturn)))
          .toList(),
    );
  }

  SourceExpression _getExpression(Expression expression) {
    if (expression is InstanceCreationExpression) {
      return SourceFunctionCall(
        name: expression.staticType.name,
        arguments: SourceArguments(
          namedArguments: Map<String, SourceArgument>.fromEntries(expression
              .argumentList.arguments
              .where((element) => element is NamedExpression)
              .of<NamedExpression>()
              .map((named) => MapEntry(
                  named.name.label.name,
                  SourceArgument(
                    type: named.staticType.name,
                    value: _getExpression(named.expression),
                  )))),
        ),
      );
    }
    if (expression is ListLiteral) {
      return SourceListExpression(
          expressionList:
              expression.elements.map((e) => _getExpression(e)).toList());
    }
    if (expression is SimpleIdentifier) {
      return SourceVariableExpression(
          name: expression.name, type: expression.staticType.toString());
    }
    print('unknown expression type ${expression.runtimeType}');
    return SourceValueExpression(value: expression.toString());
  }

  SourceTerm _sourceTerm(Expression expression) {
    if (expression is SimpleIdentifier) {
      if (expression.staticElement is PropertyAccessorElement) {
        return SourceVariableTerm(
            variable: SourceVariable(
          name: expression.staticElement.name,
          declaredIn: expression.staticElement.enclosingElement.name,
        ));
      }
    } else if (expression is BooleanLiteral) {
      return SourceValueTerm(value: expression.value);
    }
    throw Exception('unknown term expression type ${expression.runtimeType}');
  }

  SourceFormula _sourceCondition(Expression condition) {
    if (condition is SimpleIdentifier) {
      if (condition.staticElement is PropertyAccessorElement) {
        return SourceVariableFormula(
            variable: SourceVariable(
          name: condition.staticElement.name,
          declaredIn: condition.staticElement.enclosingElement.name,
        ));
      }
    } else if (condition is PrefixExpression) {
      if (condition.operator.lexeme == '!') {
        return SourceNotFormula(_sourceCondition(condition.operand));
      }
    } else if (condition is BinaryExpression) {
      return SourceBinaryFormula(
        t1: _sourceTerm(condition.leftOperand),
        t2: _sourceTerm(condition.rightOperand),
        operator: condition.operator.lexeme,
      );
    }
    throw Exception('unknown expression type ${condition.runtimeType}');
  }

  SourceGraph _controlFlow(Statement stmt) {
    if (stmt is IfStatement) {
      final ifNode = SourceNode.If();
      final endNode = SourceNode.Noop();
      final cases = [
        _AstIfCase(stmt.condition, stmt.thenStatement),
        if (stmt.elseStatement != null) _AstIfCase(null, stmt.elseStatement)
      ];
      List<SourceFormula> allFormulas = [];
      final sourceCases = cases.map((_case) {
        final innerGraph = _controlFlow(_case.block);
        // else case must not be any of the others
        final condition = _case.condition != null
            ? _sourceCondition(_case.condition)
            : SourceNotFormula(SourceDisjunctionFormula(allFormulas));
        if (_case.condition != null) {
          allFormulas.add(condition);
        }
        return _SourceIfCase(
            SourceConditionalEdge(
              condition: condition,
              start: ifNode,
              end: innerGraph.startNode,
            ),
            innerGraph);
      }).toList();
      return SourceGraph(
        nodes: [
          ifNode,
          ...sourceCases.expand((_cases) => _cases.block.nodes),
          endNode,
        ],
        edges: [
          ...sourceCases.map((_cases) => _cases.edge),
          ...sourceCases.expand((_cases) => _cases.block.endNodes
              .where((_endNode) =>
                  _endNode is! SourceBlock ||
                  (_endNode is SourceBlock && !_endNode.hasReturn))
              .map((_endNode) => SourceEdge(start: _endNode, end: endNode))),
        ],
        startNode: ifNode,
        endNodes: [
          endNode,
          ...sourceCases.expand((_cases) => _cases.block.endNodes.where(
              (_endNode) => _endNode is SourceBlock && _endNode.hasReturn))
        ],
      );
    }
    // if we have a simple statement create a graph for that we will merge
    // the graphs later
    if (stmt is Block) {
      return merge(stmt.statements.map(_controlFlow).toList());
    }
    final hasReturn = stmt is ReturnStatement;
    final node = SourceNode.Block([
      hasReturn
          ? SourceReturnStatement(
              expression: _getExpression((stmt as ReturnStatement).expression))
          : SourceStatement(text: stmt.toSource()),
    ], hasReturn: hasReturn);
    return SourceGraph(
      nodes: [node],
      edges: [],
      startNode: node,
      endNodes: [node],
    );
  }

  SourceGraph forClassMethod(ClassDeclaration decl, String methodName) {
    final buildMethod = decl.getMethod(methodName);
    if (buildMethod.body is BlockFunctionBody) {
      final buildMethodBody = buildMethod.body as BlockFunctionBody;
      final statements = buildMethodBody.block.statements;
      return merge(statements.map(_controlFlow).toList());
    }
    return null;
  }
}
