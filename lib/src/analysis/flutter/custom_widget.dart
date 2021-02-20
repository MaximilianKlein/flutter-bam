import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_bam/src/analysis/flutter/processor.dart';
import 'package:flutter_bam/src/specs/argument.dart';
import 'package:flutter_bam/src/specs/flutter/custom_widget.dart';
import 'package:flutter_bam/src/utils/of.dart';

class CustomWidget {
  const CustomWidget({this.processors});

  final List<Processor> processors;

  Iterable<CustomWidgetSpec> analyseAllWidgets(ResolvedUnitResult unit) {
    return unit.unit.declarations.of<ClassDeclaration>().where((element) {
      return element.declaredElement.allSupertypes
          .any((element) => element.element.name == 'StatelessWidget');
    }).map((type) => analyseWidget(type));
  }

  CustomWidgetSpec analyseWidget(ClassDeclaration type) {
    return CustomWidgetSpec(
        className: type.name.name,
        namedArguments: type
            .getConstructor(null)
            .parameters
            .parameters
            .map((e) => Argument(
                name: e.identifier.name,
                type: e.declaredElement.type
                    .getDisplayString(withNullability: false)))
            .toList(),
        specs: processors
            .expand((proc) => proc.generateDescriptor(type))
            .toList());
  }
}
