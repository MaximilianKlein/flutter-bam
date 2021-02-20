import 'package:flutter_bam/src/specs/argument.dart';
import 'package:meta/meta.dart';

class CustomWidgetSpec {
  const CustomWidgetSpec({
    @required this.className,
    @required this.namedArguments,
    @required this.specs,
  });

  final String className;
  final List<Argument> namedArguments;
  final List specs;
}
