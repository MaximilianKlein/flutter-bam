import 'package:flutter_bam/src/specs/flutter/custom_widget.dart';
import 'package:flutter_bam/src/specs/source_graph/class.dart';
import 'package:meta/meta.dart';

class SourceSpec {
  const SourceSpec({
    @required this.package,
    @required this.packagePath,
    @required this.filePath,
    @required this.classes,
    // @required this.widgets,
  });

  final String filePath;
  final String package;
  final String packagePath;
  final List<SourceClass> classes;
  // final List<CustomWidgetSpec> widgets;
}
