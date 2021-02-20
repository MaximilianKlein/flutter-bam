import 'package:flutter_bam/src/specs/source_graph/expression.dart';
import 'package:flutter_bam/src/specs/source_graph/function.dart';
import 'package:meta/meta.dart';

class SourceStatement {
  const SourceStatement({@required this.text});

  final String text;

  @override
  String toString() {
    return text;
  }
}

/// special statement that indicates jumping out of the current function
/// this is necessary as we can jump out of functions early and
class SourceReturnStatement extends SourceStatement {
  SourceReturnStatement({@required this.expression})
      : super(text: expression.toString());

  final SourceExpression expression;
}
