import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:flutter_bam/src/analysis/source.dart';
import 'package:flutter_bam/src/button_test_descriptor.dart';
import 'package:flutter_bam/src/specs/flutter/widget_build.dart';
import 'package:flutter_bam/src/specs/source.dart';
import 'package:flutter_bam/src/specs/source_graph/block.dart';
import 'package:flutter_bam/src/specs/source_graph/class.dart';
import 'package:flutter_bam/src/specs/source_graph/condition.dart';
import 'package:flutter_bam/src/specs/source_graph/expression.dart';
import 'package:flutter_bam/src/specs/source_graph/function.dart';
import 'package:flutter_bam/src/specs/source_graph/if.dart';
import 'package:flutter_bam/src/specs/source_graph/node.dart';
import 'package:flutter_bam/src/specs/source_graph/statement.dart';
import 'package:flutter_bam/src/specs/source_graph/value.dart';
import 'package:flutter_bam/src/test_generation/test_generator.dart';
import 'src/utils/of.dart';

Future<void> main() async {
  final filePath =
      '/Users/maximilianklein/Dev/misc/flutter_bam/example/basic/lib/widget_2.dart';
  final sourceSpec = await Source.analyse(filePath);
  // print(sourceSpec.classes);
  // print(sourceSpec.classes.first.methods['build'].body.paths());
  print(generateTests2(sourceSpec));
  // final widgets = getWidgets(fileDesc.unitElement);
  // final buildFunctions = widgets.expand(extractBuildFunctions);
  // final btns =
  //     buildFunctions.expand((buildFunction) => findButtons(buildFunction));
  // print(generateTests(btns, fileDesc));
}

T _up<T>(AstNode exp) {
  if (exp is T) {
    return exp as T;
  }
  if (exp == null) {
    return null;
  }
  return _up(exp.parent);
}

NamedExpression _getNamedArgument(MethodInvocation invocation, String name) {
  return invocation.argumentList.arguments
      .of<NamedExpression>()
      .firstWhere((argument) => argument.name.label.name == name);
}

String _findCallback(Expression exp) {
  if (exp is SimpleIdentifier) {
    return exp.name;
  }
  assert(false);
}

List<SourceFunctionCall> _buttonFromExpression(SourceExpression expression) {
  if (expression is SourceFunctionCall) {
    if (expression.name == 'RaisedButton') {
      // currently skipping non var assignments
      if (expression.arguments.namedArguments['onPressed'].value
          is! SourceVariableExpression) {
        return [];
      }
      return [expression];
    }
    return expression.arguments
        .allArguments()
        .expand((arg) => _buttonFromExpression(arg.value))
        .toList();
  } else if (expression is SourceListExpression) {
    return expression.expressionList.expand(_buttonFromExpression).toList();
  } else {
    // currently cannot handle variables :(
    return [];
  }
}

List<SourceFunctionCall> _buttonFromNode(SourceNode node) {
  if (node is SourceBlock) {
    final lastStmt = node.statements.last;
    if (lastStmt is SourceReturnStatement) {
      return _buttonFromExpression(lastStmt.expression);
    }
  }
}

List<SourceFormula> _traceFormulas(
  SourceNode node,
  List<SourceNode> path,
  SourceMethod method,
  SourceClass decl,
  SourceSpec spec,
) {
  List<SourceFormula> assignments = [];
  SourceNode curNode = node;
  int curIndex = path.indexOf(curNode);
  while (curNode != path.first) {
    final backEdge = method.body.edges.firstWhere(
        (edge) => edge.end == curNode && edge.start == path[curIndex - 1]);
    if (backEdge is SourceConditionalEdge) {
      assignments.add(backEdge.condition);
    }
    curIndex--;
    curNode = backEdge.start;
  }
  return assignments;
}

List<SourceFormula> _reduceFormula(bool value, SourceFormula formula) {
  if (formula is SourceVariableFormula) {
    return [formula.withValue(value)];
  } else if (formula is SourceConjunctionFormula) {
    return formula.formulas
        .expand((cur) => _reduceFormula(value, cur))
        .toList();
  } else if (formula is SourceDisjunctionFormula) {
    return formula.formulas
        .expand((cur) => _reduceFormula(value, cur))
        .toList();
  } else if (formula is SourceNotFormula) {
    return _reduceFormula(!value, formula.formula);
  } else if (formula is SourceBinaryFormula) {
    return [formula.withValue(value)];
  }
  throw new Exception('unhandled conditional case ${formula.runtimeType}');
}

// SourceAssignment _reduceAssignment(SourceAssignment assignment) {
//   if (assignment == SourceValueAssignment) {
//     return assignment;
//   } else if (assignment is SourceConjunctionAssignment<SourceAssignment>) {
//     return assignment.cases.reduce((value, element) => SourceValueAssignment(value: value))
//   }
// }

// SourceValue _conditionToValue(SourceCondition condition) {
//   final assignment = _conditionToAssignment(true, condition);
//   return _assignmentToValue(assignment);
// }

SourceAssignment _extractAssignments(SourceFormula formula) {
  if (formula is SourceVariableFormula) {
    return SourceVariableAssignment(
      variable:
          SourceVariableTerm(variable: formula.variable, value: formula.value),
      value: formula.value,
    );
  } else if (formula is SourceBinaryFormula) {
    if (formula.operator == '==') {
      return SourceEqualityAssignment(
        left: formula.t1,
        right: formula.t2,
        value: formula.value,
      );
    }
    throw new Exception(
        'unhandled binary formula operator ${formula.operator}');
  }
  throw new Exception('unhandled assignment case ${formula.runtimeType}');
}

List<SourceAssignment> _traceAssignments(
  SourceNode node,
  List<SourceNode> path,
  SourceMethod method,
  SourceClass decl,
  SourceSpec spec,
) {
  final formulas = _traceFormulas(node, path, method, decl, spec);
  final combinedCondition = SourceConjunctionFormula(formulas);
  final reducedConditions = _reduceFormula(true, combinedCondition);
  return reducedConditions.map((cond) => _extractAssignments(cond)).toList();

  // what it does
  // true = Not(And(a, Or(b, Not(c))))
  // false = And(a, Or(b, Not(c)))
  // And(false = a, false = Or(b, Not(c)))
  // And(false = a, Or(false = b, false = Not(c)))
  // And(false = a, Or(false = b, true = c))
}

String generateTests2(SourceSpec spec) {
  final gen = TestGenerator();
  return gen.testFile(
      spec.classes.expand<String>((decl) {
        if (!decl.baseClasses.contains('StatelessWidget') ||
            !decl.methods.containsKey('build')) {
          return [];
        }
        return decl.methods['build'].body.paths().expand((path) {
          return _buttonFromNode(path.last).map((call) {
            final onTapVariable = call.arguments.namedArguments['onPressed']
                .value as SourceVariableExpression;
            final assignments = _traceAssignments(
                path.last, path, decl.methods['build'], decl, spec);
            print(assignments);
            // final classConstructorAssignments = assignments
            //     .where((a) =>
            //         a.variable.declaredIn == decl.name &&
            //         decl.arguments.namedArguments.containsKey(a.variable.name))
            //     .toList();
            return '';
            // gen.testButton(
            //     '${call.name} test',
            //     ButtonTestDescriptor(
            //       basicClass: decl.name,
            //       buttonClass: call.name,
            //       tapCallbackName: onTapVariable.name,
            //       arguments: decl.arguments,
            //       constructorAssignments: [], // classConstructorAssignments,
            //     ));
          });
        });
      }).toList(),
      spec);
  // for (final decl in spec.classes) {
  //   final paths = decl.methods.gen.testButton(
  //       'button',
  //       ButtonTestDescriptor(
  //         basicClass: decl.name,
  //         buttonClass: buttonClass,
  //         tapCallbackName: tapCallbackName,
  //         namedArguments: namedArguments,
  //       ));
  // }
}
//   return gen.testFile(spec.widgets.expand((widget) {
//     return widget.specs.map((spec) {
//       if (spec is WidgetBuildSpec) {
//         return gen.testButton(
//             'name',
//             ButtonTestDescriptor(
//               basicClass: widget.className,
//               buttonClass: spec.widgetName,
//               namedArguments: widget.namedArguments,
//               tapCallbackName: widget.namedArguments
//                   .firstWhere((element) =>
//                       element.name == spec.namedArguments['onPressed'])
//                   .name,
//             ));
//       } else {
//         return '';
//       }
//     });
//   }), spec);
// }

String generateTests(Iterable<MethodInvocation> btns, SourceSpec spec) {
  final gen = TestGenerator();
  return gen.testFile(btns.map((btn) {
    final widgetClass = _up<ClassDeclaration>(btn);
    final constructor = widgetClass.getConstructor(null);
    final onPressedArgument = _getNamedArgument(btn, 'onPressed');
    final onPressedCallback = _findCallback(onPressedArgument.expression);
    final params =
        constructor.parameters.parameters.map((elem) => elem.identifier);
    return gen.testButton(
        'name',
        ButtonTestDescriptor(
          basicClass: widgetClass.name.name,
          buttonClass: btn.methodName.name,
          tapCallbackName: params
              .firstWhere((element) => element.name == onPressedCallback)
              .name,
        ));
  }), spec);
}

Iterable<MethodInvocation> allInvocations(Expression expression) {
  if (expression is MethodInvocation) {
    return [
      expression,
      ...expression.argumentList.arguments.expand((argument) {
        if (argument is NamedExpression) {
          return allInvocations(argument.expression);
        }
        return allInvocations(argument);
      }),
    ];
  } else if (expression is ListLiteral) {
    return expression.elements.expand((e) => allInvocations(e));
  } else if (expression is SimpleIdentifier) {
    return [];
  } else {
    print('found unhandled ' + expression.runtimeType.toString());
  }
  return [];
}

bool _isButton(String name) => name.contains('Button');

Iterable<MethodInvocation> findButtons(MethodDeclaration methodDecl) {
  final returns = methodDecl.body.childEntities.map<ReturnStatement>((stmt) {
    if (stmt is Block) {
      return stmt.childEntities
              .firstWhere((element) => element is ReturnStatement)
          as ReturnStatement;
    }
    return null;
  }).of<ReturnStatement>();
  return returns.expand((element) {
    return allInvocations(element.expression);
  }).where((method) => _isButton(method.methodName.name));
}

const _widgetBases = ['StatelessWidget', 'State'];

Iterable<ClassDeclaration> getWidgets(CompilationUnit comp) {
  return comp.declarations
      .where((CompilationUnitMember decl) {
        return decl is ClassDeclaration;
      })
      .cast<ClassDeclaration>()
      .where((decl) {
        return _widgetBases.contains(decl.extendsClause.superclass.name.name);
      });
}

Iterable<MethodDeclaration> extractBuildFunctions(ClassDeclaration decl) {
  return decl.members
      .where((member) {
        return member is MethodDeclaration;
      })
      .cast<MethodDeclaration>()
      .where((functionDecl) {
        final metadataNames = functionDecl.metadata.map((e) => e.name.name);
        final isOverride = metadataNames.contains('override');
        return functionDecl.name.name == 'build' && isOverride;
      });
}
