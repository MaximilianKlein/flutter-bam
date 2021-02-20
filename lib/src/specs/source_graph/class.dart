import 'package:meta/meta.dart';

import 'package:flutter_bam/src/specs/source_graph/function.dart';
import 'package:flutter_bam/src/specs/source_graph/graph.dart';

class SourceMethod {
  const SourceMethod({
    @required this.name,
    @required this.returnType,
    @required this.arguments,
    @required this.body,
  });

  final String name;
  final String returnType;
  final SourceArguments arguments;
  final SourceGraph body;

  @override
  String toString() {
    return '''
method: $name($arguments) : $returnType
$body

''';
  }
}

class SourceClass {
  const SourceClass({
    @required this.name,
    @required this.methods,
    @required this.members,
    @required this.baseClasses,
    @required this.arguments,
  });

  final String name;
  final Map<String, SourceMethod> methods;
  final Map<String, String> members;
  final List<String> baseClasses;
  final SourceArguments arguments;

  @override
  String toString() {
    return '''
class $name
members: [${members.entries.map((entry) => '${entry.key} of type ${entry.value}').join(', ')}]
methods:
${methods.values.join('\n')}
''';
  }
}
