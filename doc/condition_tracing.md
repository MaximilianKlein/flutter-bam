# Condition Tracing

One important part in generating tests is the tracing of variables to
determine if and how they can be set to the designated values. Consider the
following example

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({this.onTap});

  final VoidCallback onTap;

  @override
  State<StatefulWidget> createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  bool loading = true;

  void finishLoading() {
      setState(() {
          loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Column(children: [
        RaisedButton(onPressed: finishLoading),
        CircularProgressIndicator(),
      ]);
    } else {
      return RaisedButton(
        onPressed: widget.onTap,
      );
    }
  }
}
```

Now lets say we want to generate a test that the onTap button works. It is only accessible if we click the other button first that calls `finishLoading` and shows the other Button. For that we need to start tracing the conditions that lead to the widget creation. We call something like this:

```dart
traceCondition(
  in(method("build"), of("MyWidget")), // at best finds build method in state of stateful widget
  statement(
    widgetCreation("RaisedButton"),
    where(valueOfArgument("onPressed"), isConstructorArgOf("MyWidget"))));
```