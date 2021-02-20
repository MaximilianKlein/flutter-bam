import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_bam/src/analysis/class.dart';
import 'package:flutter_bam/src/analysis/flutter/custom_widget.dart';
import 'package:flutter_bam/src/analysis/flutter/processors/build_method_buttons.dart';
import 'package:flutter_bam/src/analysis/flutter/processors/build_return_widgets.dart';
import 'package:flutter_bam/src/specs/source.dart';
import 'package:path/path.dart';
import 'package:flutter_bam/src/utils/of.dart';

class Source {
  static Future<SourceSpec> analyse(String path) async {
    final context = AnalysisContextCollection(includedPaths: [path]);
    // final analyser = CustomWidget(processors: [
    //   BuildMethodButtons(widgets: ['RaisedButton'])
    // ]);
    final resolvedUnit =
        await context.contexts.first.currentSession.getResolvedUnit(path);
    final classAnalyzer = ClassAnalyzer();
    // final widgetsSpec = analyser.analyseAllWidgets(resolvedUnit).toList();
    return SourceSpec(
      filePath: path,
      package: split(resolvedUnit.libraryElement.librarySource.uri.path).first,
      packagePath: resolvedUnit.libraryElement.librarySource.uri.toString(),
      classes: resolvedUnit.unit.declarations
          .of<ClassDeclaration>()
          .map((decl) => classAnalyzer.analyzeClass(decl))
          .toList(),
      // widgets: widgetsSpec, //widgets.toList(),
    );
  }
}
