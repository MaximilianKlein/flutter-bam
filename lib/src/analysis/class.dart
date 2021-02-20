import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_bam/src/analysis/flutter/processors/control_flow_graph_converter.dart';
import 'package:flutter_bam/src/specs/source_graph/class.dart';
import 'package:flutter_bam/src/specs/source_graph/function.dart';

class ClassAnalyzer {
  const ClassAnalyzer();

  SourceArguments _sourceArgumentsFromParameterList(
      List<ParameterElement> params) {
    return SourceArguments(
        arguments: params
            .where((param) => !param.isNamed && !param.isOptional)
            .map((param) => SourceArgument(
                  name: param.displayName,
                  type: param.type.getDisplayString(withNullability: true),
                ))
            .toList(),
        namedArguments: Map<String, SourceArgument>.fromEntries(
          params.where((param) => param.isNamed).map((param) => MapEntry(
              param.name,
              SourceArgument(name: param.name, type: param.type.toString()))),
        ));
  }

  SourceClass analyzeClass(ClassDeclaration _class) {
    final controlGraphConverter = ControlGraphConverter();
    return SourceClass(
      name: _class.name.name,
      baseClasses: _class.declaredElement.allSupertypes
          .map((_type) => _type.displayName)
          .toList(),
      arguments: _sourceArgumentsFromParameterList(
          _class.getConstructor(null).parameters.parameterElements),
      methods: Map<String, SourceMethod>.fromEntries(
          _class.declaredElement.methods.map((element) => MapEntry(
              element.name,
              SourceMethod(
                name: element.name,
                returnType: element.type.returnType.toString(),
                arguments:
                    _sourceArgumentsFromParameterList(element.parameters),
                body:
                    controlGraphConverter.forClassMethod(_class, element.name),
              )))),
      members: {},
    );
  }
}
