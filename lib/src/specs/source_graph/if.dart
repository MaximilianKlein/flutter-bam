import 'package:flutter_bam/src/specs/source_graph/condition.dart';
import 'package:flutter_bam/src/specs/source_graph/context.dart';
import 'package:flutter_bam/src/specs/source_graph/graph.dart';
import 'package:flutter_bam/src/specs/source_graph/node.dart';
import 'package:flutter_bam/src/specs/source_graph/statement.dart';
import 'package:meta/meta.dart';

class SourceConditionalEdge extends SourceEdge {
  const SourceConditionalEdge({
    @required this.start,
    @required this.end,
    @required this.condition,
  });

  final SourceNode start;
  final SourceNode end;
  final SourceFormula condition;
}

class SourceCase {
  const SourceCase({
    @required this.condition,
    @required this.block,
  });

  final SourceStatement condition;
  final SourceNode block;

  @override
  String toString() {
    return 'when($condition)\n -> $block';
  }
}

/// special node that indicates that we have a control structure here
/// the cases are specified by the ordered list of edges with conditions
class SourceIf extends SourceNode {
  const SourceIf({@required String id}) : super(id);

  @override
  String toString() {
    return 'If()';
  }
  // final SourceNode if;
  // final List<SourceNode> elseIfCases;
  // final SourceNode elseBlock;

  // Iterable<SourceNode> next(SourceContext context) {
  //   // all cases in order
  //   return [
  //     ifCase,
  //     ...elseIfCases,
  //     SourceCase(condition: SourceStatement(/*true*/), block: elseBlock),
  //   ];
  //   // // drop all not fulfilled cases
  //   // .where((_case) => _case.isFulfilled(context) != IfDecision.NotFulfilled)
  //   // // stop until first fulfilled case (undecided ones need to be accounted)
  //   // // for but only if there was no prior Fulfilled decision
  //   // .takeWhile(
  //   //     (_case) => _case.isFulfilled(context) != IfDecision.Fulfilled)
  //   // .map((_case) => _case.block);
  // }
}
