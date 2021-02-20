import 'package:flutter_bam/src/specs/source_graph/block.dart';
import 'package:flutter_bam/src/specs/source_graph/if.dart';
import 'package:flutter_bam/src/specs/source_graph/statement.dart';
import 'package:meta/meta.dart';

import 'package:flutter_bam/src/specs/source_graph/context.dart';

int _idCounter = 0;

abstract class SourceNode {
  const SourceNode(String id) : _id = id;

  final String _id;

  String id() => _id;

  static SourceNode Noop() => SourceNoop(id: '${_idCounter++}');
  static SourceNode Block(List<SourceStatement> statements,
          {bool hasReturn = false}) =>
      SourceBlock(
          id: '${_idCounter++}', statements: statements, hasReturn: hasReturn);
  static SourceNode If() => SourceIf(id: '${_idCounter++}');
}

class SourceNoop extends SourceNode {
  const SourceNoop({@required String id}) : super(id);

  @override
  String toString() {
    return 'Noop()';
  }
}
