import 'package:basic/widget_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/spy.dart';

void main() {
  testWidgets('clicking button', (widgetTester) async {
    // given
    final spy = CallbackSpy();

    await widgetTester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Widget1(onTap: spy.callback, name: "<string value>"))));

    // when
    await widgetTester.tap(find.byType(RaisedButton));

    // then
    expect(spy, wasCalledOnce);
  });
}
