import 'dart:io';

import 'package:flutter_bam/src/specs/package.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

@Deprecated('probably not needed anymore since we get this from the analyzer')
class Package {
  /// returns the package specification for a dart sourcee file if possible
  /// if not it will return null
  static PackageSpec sourcePackage(String path) {
    final pubspecLocation = _findPubspec(path);
    final parsedPubspec = loadYaml(File(pubspecLocation).readAsStringSync());
    final packagePath =
        relative(path, from: join(dirname(pubspecLocation), 'lib'));
    return PackageSpec(
      packageName: parsedPubspec['name'],
      packagePath: packagePath,
    );
  }

  static String _findPubspec(String filePath) {
    String last = dirname(filePath);
    while (rootPrefix(last) != last) {
      final pubspecLocation = join(last, 'pubspec.yaml');
      if (File(pubspecLocation).existsSync()) {
        return pubspecLocation;
      }
      last = dirname(last);
    }
    return null;
  }
}
