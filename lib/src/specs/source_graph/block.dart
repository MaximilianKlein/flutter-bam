import 'package:meta/meta.dart';

import 'package:flutter_bam/src/specs/source_graph/node.dart';
import 'package:flutter_bam/src/specs/source_graph/statement.dart';

class SourceBlock extends SourceNode {
  const SourceBlock(
      {@required String id, @required this.statements, this.hasReturn = false})
      : super(id);

  final List<SourceStatement> statements;
  final bool hasReturn;

  @override
  String toString() {
    return 'Block($statements)${hasReturn ? ', return!' : ''}';
  }
}
