import 'package:meta/meta.dart';

class WidgetBuildSpec {
  const WidgetBuildSpec({
    @required this.widgetName,
    @required this.namedArguments,
  });

  final String widgetName;
  final Map<String, String> namedArguments;
}
