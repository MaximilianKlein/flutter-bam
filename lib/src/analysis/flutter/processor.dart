import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

abstract class Processor {
  generateDescriptor(ClassDeclaration decl);
}
