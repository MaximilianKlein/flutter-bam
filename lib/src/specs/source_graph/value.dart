import 'package:flutter_bam/src/specs/source_graph/condition.dart';

abstract class SourceValue {
  const SourceValue(this.variable);

  final String variable;
}

class SourceBoolValue extends SourceValue {
  const SourceBoolValue({this.value, String variable}) : super(variable);

  final bool value;

  @override
  String toString() {
    return 'bool($value)';
  }
}

class SourceAssignment {
  const SourceAssignment();
}

class SourceVariableAssignment extends SourceAssignment {
  const SourceVariableAssignment({this.value, this.variable});

  final bool value;
  final SourceTerm variable;

  @override
  String toString() {
    return 'assignment($variable ≡ $value';
  }
}

class SourceEqualityAssignment extends SourceAssignment {
  const SourceEqualityAssignment({this.left, this.right, this.value});

  final bool value;
  final SourceTerm left;
  final SourceTerm right;

  @override
  String toString() {
    return 'assignment($left == $right ≡ $value)';
  }
}
