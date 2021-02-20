import 'package:flutter/material.dart';

class BasicWidget extends StatelessWidget {
  const BasicWidget({@required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [RaisedButton(onPressed: onTap)],
    );
  }
}
