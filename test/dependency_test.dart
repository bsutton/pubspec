import 'dart:io';

import 'package:pubspec/pubspec.dart';
import 'package:test/test.dart';

main() {
  test('external hosted dependency', () {
    var pubspecString = 'name: my_test_lib\n'
        'version: 0.1.0\n'
        'description: for testing\n'
        'dependencies:\n'
        '    meta: ^1.0.0\n'
        '    self_hosted_lib:\n'
        '        hosted:\n'
        '            name: custom_lib\n'
        '            url: https://pub.mycompany.org\n'
        '            version: ^0.1.0';
    var p = new PubSpec.fromYamlString(pubspecString);
    var dep = p.dependencies['self_hosted_lib'];
    expect(dep, TypeMatcher<ExternalHostedReference>());

    var exDep = dep as ExternalHostedReference;
    expect(exDep.name, 'custom_lib');
    expect(exDep.url, 'https://pub.mycompany.org');
    expect(exDep.versionConstraint.toString(), '^0.1.0');
  });

  /// According to https://www.dartlang.org/tools/pub/dependencies#version-constraints:
  ///
  /// The string any allows any version. This is equivalent to an empty
  /// version constraint, but is more explicit.
  test('dependency without the version constraint is "any" version', () {
    var pubspecString = 'name: my_test_lib\n'
        'version: 0.1.0\n'
        'description: for testing\n'
        'dependencies:\n'
        '    meta:\n';
    var p = new PubSpec.fromYamlString(pubspecString);
    var dep = p.dependencies['meta'];
    expect(dep, TypeMatcher<HostedReference>());

    var exDep = dep as HostedReference;
    expect(exDep.versionConstraint.toString(), 'any');
  });

  test('sdk dependency', () {
    var pubspecString = 'name: my_test_lib\n'
        'version: 0.1.0\n'
        'description: for testing\n'
        'dependencies:\n'
        '    flutter:\n'
        '        sdk: flutter\n';
    var p = new PubSpec.fromYamlString(pubspecString);
    var dep = p.dependencies['flutter'];
    expect(dep, TypeMatcher<SdkReference>());

    var sdkDep = dep as SdkReference;
    expect(sdkDep.sdk, 'flutter');
  });

  test('load from file', () async {
    final fromDir = await PubSpec.load(Directory('.'));
    final fromFile = await PubSpec.loadFile('./pubspec.yaml');
    expect(fromFile.toJson(), equals(fromDir.toJson()));
  });
}
