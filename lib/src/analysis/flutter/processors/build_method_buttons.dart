import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_bam/src/analysis/flutter/processor.dart';
import 'package:flutter_bam/src/analysis/flutter/processors/control_flow_graph_converter.dart';
import 'package:flutter_bam/src/specs/flutter/widget_build.dart';
import 'package:flutter_bam/src/specs/source_graph/block.dart';
import 'package:flutter_bam/src/specs/source_graph/graph.dart';
import 'package:flutter_bam/src/specs/source_graph/if.dart';
import 'package:flutter_bam/src/specs/source_graph/node.dart';
import 'package:flutter_bam/src/specs/source_graph/statement.dart';

import 'package:flutter_bam/src/utils/of.dart';

/// finds buttons in the build method with conditionals
class BuildMethodButtons implements Processor {
  const BuildMethodButtons({this.widgets});

  final List<String> widgets;

  @override
  generateDescriptor(ClassDeclaration decl) {
    final methodGraph = _extractBuildMethodGraph(decl);
    return [];
    // return invocations.map((inv) => WidgetBuildSpec(
    //       widgetName: inv.constructorName.type.name.name,
    //       namedArguments: Map<String, String>.fromEntries(
    //           inv.argumentList.arguments.of<NamedExpression>().map((arg) =>
    //               MapEntry(arg.name.label.name, arg.expression.toString()))),
    //     ));
  }

  Iterable<InstanceCreationExpression> _allInvocations(Expression expression) {
    if (expression is InstanceCreationExpression) {
      return [
        expression,
        ...expression.argumentList.arguments.expand((argument) {
          if (argument is NamedExpression) {
            return _allInvocations(argument.expression);
          }
          return _allInvocations(argument);
        }),
      ];
    } else if (expression is ListLiteral) {
      return expression.elements.expand((e) => _allInvocations(e));
    } else if (expression is SimpleIdentifier) {
      return [];
    } else {
      print('found unhandled ' + expression.runtimeType.toString());
    }
    return [];
  }

  bool _isWidget(String name) => widgets.contains(name);

  SourceGraph _extractBuildMethodGraph(ClassDeclaration decl) {
    return ControlGraphConverter().forClassMethod(decl, 'build');
  }
}
