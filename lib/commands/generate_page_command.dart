import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:clean_getx/generators/page_generator.dart';
import 'package:clean_getx/utils/exceptions.dart';

class GeneratePageCommand extends Command {
  @override
  final name = 'page';

  @override
  final description =
      'Add a new page/screen to an existing feature '
      '(creates binding/, controller/, view/ for the page)';

  @override
  String get invocation =>
      'getx_cli page -f <feature_name> -n <page_name> [options]';

  GeneratePageCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'The existing feature (parent folder) to add the page to',
      mandatory: true,
    );
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Page name in snake_case (e.g. product_details, add_product)',
      mandatory: true,
    );
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the features directory',
      defaultsTo: 'lib/features',
    );
  }

  @override
  Future<void> run() async {
    final featureName = argResults!['feature'] as String;
    final pageName = argResults!['name'] as String;
    final basePath = argResults!['path'] as String;

    try {
      final generator = PageGenerator(
        featureName: featureName,
        pageName: pageName,
        basePath: basePath,
      );

      await generator.generate();

      print('\n✓ Page "$pageName" added to feature "$featureName"!');
      print('Location: ${generator.pagePath}');
      print('\nGenerated files:');
      for (final file in generator.generatedFiles) {
        print('  • $file');
      }

      final pascal = _toPascalCase(pageName);
      print('\n📝 Next steps:');
      print('  1. Register the route in your app routes file:');
      print('     GetPage(');
      print("       name: '/$featureName/${pageName.replaceAll('_', '-')}',");
      print('       page: () => const ${pascal}View(),');
      print('       binding: ${pascal}Binding(),');
      print('     ),');
      print(
        '  2. Implement controller logic in '
        '${generator.pagePath}/controller/${pageName}_controller.dart',
      );
      print(
        '  3. Design the UI in '
        '${generator.pagePath}/view/${pageName}_view.dart',
      );
    } on PageGeneratorException catch (e) {
      stderr.writeln('\n✗ Error: ${e.message}');
      exit(1);
    } catch (e) {
      stderr.writeln('\n✗ Unexpected error: $e');
      exit(1);
    }
  }

  String _toPascalCase(String input) {
    return input
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join();
  }
}
