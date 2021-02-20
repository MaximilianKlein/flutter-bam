import 'package:flutter_bam/src/specs/argument.dart';
import 'package:flutter_bam/src/specs/source_graph/function.dart';
import 'package:flutter_bam/src/specs/source_graph/value.dart';
import 'package:meta/meta.dart';

class ButtonTestDescriptor {
  const ButtonTestDescriptor({
    @required this.basicClass,
    @required this.buttonClass,
    @required this.tapCallbackName,
    @required this.arguments,
    @required this.constructorAssignments,
  });

  final String basicClass;
  final String buttonClass;

  final String tapCallbackName;

  final SourceArguments arguments;
  final List<SourceAssignment> constructorAssignments;
}
