import 'package:flutter_bam/src/specs/source_graph/block.dart';
import 'package:flutter_bam/src/specs/source_graph/expression.dart';
import 'package:meta/meta.dart';

import 'node.dart';

class SourceArgument {
  const SourceArgument({
    this.name,
    this.type,
    this.value,
  });

  final String type;
  final String name;
  final SourceExpression value;

  @override
  String toString() {
    if (value != null) {
      return '$value';
    } else {
      return '$name of $type';
    }
  }
}

class SourceArguments {
  const SourceArguments({
    this.arguments = const [],
    this.namedArguments = const {},
    this.optionalArguments = const [],
  });

  final List<SourceArgument> arguments;
  final Map<String, SourceArgument> namedArguments;
  final List<SourceArgument> optionalArguments;

  Iterable<SourceArgument> allArguments() => [
        ...arguments,
        ...namedArguments.values,
        ...optionalArguments,
      ];

  @override
  String toString() {
    final namedArgs = '{' +
        namedArguments.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join(', ') +
        '}';
    return arguments.join(', ') +
        optionalArguments.join(', ') +
        ((namedArguments.length == 0) ? '' : namedArgs);
  }
}

class SourceFunctionCall extends SourceExpression {
  const SourceFunctionCall({
    @required this.name,
    @required this.arguments,
  });

  final String name;
  final SourceArguments arguments;

  @override
  String toString() {
    return '$name(${arguments})';
  }
}
