import 'package:meta/meta.dart';

// naming derived from predicate logic
// formulas are
// 1. predicates (not yet implemented, probably functions?)
// 2. Equality of two terms
// 3. Negation (of another formula)
// 4. Binary Connective (&&, ||)
// 5. Quantifiers (done by functions)

class SourceFormula {
  const SourceFormula();

  @override
  String toString() {
    return 'none';
  }
}

class SourceVariable {
  const SourceVariable({@required this.name, @required this.declaredIn});

  final String name;
  final String declaredIn;
}

class SourceVariableFormula<T> extends SourceFormula {
  const SourceVariableFormula({@required this.variable, this.value});

  final SourceVariable variable;
  final T value;

  SourceVariableFormula<T> withValue(T value) =>
      SourceVariableFormula(variable: variable, value: value);

  @override
  String toString() {
    return 'var(${variable.name} = $value from ${variable.declaredIn})';
  }
}

class SourceNotFormula extends SourceFormula {
  const SourceNotFormula(this.formula);

  final SourceFormula formula;

  @override
  String toString() {
    return 'Not($formula)';
  }
}

abstract class SourceTerm {
  const SourceTerm();
}

class SourceVariableTerm<T> extends SourceTerm {
  const SourceVariableTerm({@required this.variable, this.value});

  final SourceVariable variable;
  final T value;

  SourceVariableTerm<T> withValue(T value) =>
      SourceVariableTerm(variable: variable, value: value);

  @override
  String toString() {
    return 'var(${variable.name} = $value from ${variable.declaredIn})';
  }
}

class SourceValueTerm<T> extends SourceTerm {
  const SourceValueTerm({@required this.value});

  final T value;

  @override
  String toString() {
    return 'val($value)';
  }
}

class SourceBinaryFormula<T> extends SourceFormula {
  const SourceBinaryFormula({
    @required this.t1,
    @required this.t2,
    @required this.operator,
    this.value,
  });

  final SourceTerm t1;
  final SourceTerm t2;
  final String operator;
  final T value;

  SourceBinaryFormula<T> withValue(T value) =>
      SourceBinaryFormula(t1: t1, t2: t2, operator: operator, value: value);
}

class SourceConjunctionFormula<T> extends SourceFormula {
  const SourceConjunctionFormula(this.formulas);

  final List<T> formulas;

  @override
  String toString() {
    return 'And($formulas)';
  }
}

class SourceDisjunctionFormula<T> extends SourceFormula {
  const SourceDisjunctionFormula(this.formulas);

  final List<T> formulas;

  @override
  String toString() {
    return 'Or($formulas)';
  }
}
