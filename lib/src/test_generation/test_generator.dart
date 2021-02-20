import 'package:flutter_bam/src/button_test_descriptor.dart';
import 'package:flutter_bam/src/specs/source.dart';
import 'test_assertion.dart';
import '../utils/zip.dart';

class TestGenerator {
  String _assertionInit(TestAssertion assertion) {
    if (assertion is CallsFunctionAssertion) {
      return 'final spy = CallbackSpy();';
    }
    return '// not yet supported assertion';
  }

  String _assertionArgs(String name, TestAssertion assertion) {
    if (assertion is CallsFunctionAssertion) {
      return '$name: spy.callback';
    }
    return '/* not yet supported assertion */';
  }

  String _assertionThen(TestAssertion assertion) {
    if (assertion is CallsFunctionAssertion) {
      return 'expect(spy, wasCalledOnce);';
    }
    return '// not yet supported assertion';
  }

  String testFile(Iterable<String> testCases, SourceSpec spec) {
    return '''
import '${spec.packagePath}';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/spy.dart';

void main() {
  ${testCases.join('\n\n')}
}
    ''';
  }

  String testButton(String name, ButtonTestDescriptor descriptor) {
    // final widgetClass = _up<ClassDeclaration>(buttonIdentifier);
    final assertions = [CallsFunctionAssertion()];
    // final constructor = widgetClass.getConstructor(null);
    // final params =
    //     constructor.parameters.parameters.map((elem) => elem.identifier.name);
    final given = assertions.map(_assertionInit).join('\n');
    // in future handle more than one arg
    // final args = assertions
    //     .zip(params)
    //     .map((paramAssertion) =>
    //         _assertionArgs(paramAssertion.item2, paramAssertion.item1))
    //     .join(',\n');
    // final assignmentsByName = Map.fromEntries(descriptor.constructorAssignments
    //     .map((a) => MapEntry(a.variable.name, a)));
    final args = [
      _assertionArgs(descriptor.tapCallbackName, assertions.first),
      ...descriptor.arguments.namedArguments.values
          .where((element) => element.name != descriptor.tapCallbackName)
          .map((argument) {
        switch (argument.type) {
          case 'String':
          case 'String*':
            return '${argument.name}: "<string value>"';
          case 'bool':
          case 'bool*':
            final value =
                // assignmentsByName.containsKey(argument.name)
                //     ? assignmentsByName[argument.name].value
                //     :
                'false';
            return '${argument.name}: $value';
          default:
            return '${argument.name}: null';
        }
      })
    ];
    final then = assertions.map(_assertionThen).join('\n');
    return '''
testWidgets('clicking button', (widgetTester) async {
  // given
  ${given}
  
  await widgetTester.pumpWidget(MaterialApp(home: Scaffold(body: ${descriptor.basicClass}(
    ${args.join(',\n')}
  ))));

  // when
  await widgetTester.tap(find.byType(${descriptor.buttonClass}));

  // then
  ${then}
});
''';
  }
}
