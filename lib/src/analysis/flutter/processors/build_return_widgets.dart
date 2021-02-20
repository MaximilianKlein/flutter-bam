import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_bam/src/analysis/flutter/processor.dart';
import 'package:flutter_bam/src/specs/flutter/widget_build.dart';

import 'package:flutter_bam/src/utils/of.dart';

/// finds widgets in the return statement of a build function
class BuildReturnWidgets implements Processor {
  const BuildReturnWidgets({this.widgets});

  final List<String> widgets;

  @override
  generateDescriptor(ClassDeclaration decl) {
    final invocations = _extractBuildReturn(decl);
    return invocations.map((inv) => WidgetBuildSpec(
          widgetName: inv.constructorName.type.name.name,
          namedArguments: Map<String, String>.fromEntries(
              inv.argumentList.arguments.of<NamedExpression>().map((arg) =>
                  MapEntry(arg.name.label.name, arg.expression.toString()))),
        ));
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

  Iterable<InstanceCreationExpression> _extractBuildReturn(
      ClassDeclaration decl) {
    final buildMethod = decl.getMethod('build');
    if (buildMethod.body is BlockFunctionBody) {
      final buildMethodBody = buildMethod.body as BlockFunctionBody;
      final returns =
          buildMethodBody.block.statements.map<ReturnStatement>((stmt) {
        if (stmt is ReturnStatement) {
          return stmt;
        }
        return null;
      }).of<ReturnStatement>();
      return returns.expand((element) {
        return _allInvocations(element.expression);
      }).where((method) => _isWidget(method.constructorName.type.name.name));
    }
  }
}
