abstract class SourceExpression {
  const SourceExpression();
}

class SourceVariableExpression extends SourceExpression {
  const SourceVariableExpression({this.name, this.type});

  final String type;
  final String name;

  @override
  String toString() {
    return 'var($name of $type)';
  }
}

class SourceValueExpression extends SourceExpression {
  const SourceValueExpression({this.value, this.type});

  final String type;
  final String value;

  @override
  String toString() {
    return 'value($value of $type)';
  }
}

class SourceListExpression extends SourceExpression {
  const SourceListExpression({this.expressionList});

  final List<SourceExpression> expressionList;

  @override
  String toString() {
    return '[' + expressionList.join(', ') + ']';
  }
}
