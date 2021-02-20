import 'package:flutter/material.dart';

class Widget1 extends StatelessWidget {
  const Widget1(
      {@required this.loading, @required this.name, @required this.onTap});

  final bool loading;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    print('building');
    print('...');
    if (loading == false) {
      return CircularProgressIndicator();
    } else {
      return Column(
        children: [Text('Hello'), RaisedButton(onPressed: onTap)],
      );
    }
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({this.onTap});

  final VoidCallback onTap;

  @override
  State<StatefulWidget> createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Column(children: [
        RaisedButton(onPressed: () {
          this.setState(() {
            loading = false;
          });
        }),
        CircularProgressIndicator(),
      ]);
    } else {
      return RaisedButton(
        onPressed: widget.onTap,
      );
    }
  }
}
