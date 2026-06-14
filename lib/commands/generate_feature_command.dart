import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:clean_getx/generators/feature_generator.dart';
import 'package:clean_getx/utils/exceptions.dart';

class GenerateFeatureCommand extends Command {
  @override
  final name = 'feature';

  @override
  final description =
      'Generate a new feature with GetX clean architecture '
      '(presentation grouped by page: binding/, controller/, view/)';

  @override
  String get invocation => 'getx_cli feature -n <feature_name> [options]';

  GenerateFeatureCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Feature name in snake_case (e.g. product_list)',
      mandatory: true,
    );
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the features directory',
      defaultsTo: 'lib/features',
    );
    argParser.addFlag(
      'no-model',
      help: 'Generate a data model with JSON serialization',
      defaultsTo: false,
    );
    argParser.addFlag(
      'no-repository',
      help: 'Generate abstract repository + Dio-based implementation',
      defaultsTo: false,
    );
  }

  @override
  Future<void> run() async {
    final name = argResults!['name'] as String;
    final basePath = argResults!['path'] as String;
    final withModel = !argResults!['no-model'];
    final withRepository = !argResults!['no-repository'];

    try {
      final generator = FeatureGenerator(
        name: name,
        basePath: basePath,
        withModel: withModel,
        withRepository: withRepository,
      );

      await generator.generate();

      print('\n✓ Feature "$name" generated successfully!');
      print('Location: ${generator.featurePath}');
      print('\nGenerated files:');
      for (final file in generator.generatedFiles) {
        print('  • $file');
      }

      print('\n📝 Next steps:');
      print('  1. Add a route + binding entry in your app routes file');
      print(
        '  2. Implement the controller logic in '
        '${generator.featurePath}/presentation/$name/controller/${name}_controller.dart',
      );
      if (withModel) {
        print('  3. Run build_runner to generate JSON serialization code:');
        print(
          '     flutter pub run build_runner build --delete-conflicting-outputs',
        );
      }
      print('\n💡 Add more pages to this feature with:');
      print('     dart run bin/clean_getx.dart page -f $name -n <page_name>');
    } on FeatureGeneratorException catch (e) {
      stderr.writeln('\n✗ Error: ${e.message}');
      exit(1);
    } catch (e) {
      stderr.writeln('\n✗ Unexpected error: $e');
      exit(1);
    }
  }
}
