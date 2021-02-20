import 'package:flutter/material.dart';

class Widget1 extends StatelessWidget {
  const Widget1({@required this.name, @required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text(name), RaisedButton(onPressed: onTap)],
    );
  }
}
