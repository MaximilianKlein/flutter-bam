import 'package:meta/meta.dart';

class PackageSpec {
  const PackageSpec({
    @required this.packageName,
    @required this.packagePath,
  });

  final String packageName;
  final String packagePath;
}
