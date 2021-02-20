import 'package:basic/basic_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/spy.dart';

void main() {
  testWidgets('clicking button', (widgetTester) async {
  // given
  final spy = CallbackSpy();
  
  await widgetTester.pumpWidget(MaterialApp(home: Scaffold(body: BasicWidget(
    onTap: spy.callback
  ))));

  // when
  await widgetTester.tap(find.byType(RaisedButton));

  // then
  expect(spy, wasCalledOnce);
});

}
    
