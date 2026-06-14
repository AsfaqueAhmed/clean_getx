import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:clean_getx/templates/page_templates.dart';
import 'package:clean_getx/utils/exceptions.dart';

/// Adds a new page/screen to an existing feature using the V2 structure:
///
/// lib/features/<feature>/presentation/<page_name>/
/// ├── binding/<page_name>_binding.dart
/// ├── controller/<page_name>_controller.dart
/// ├── view/<page_name>_view.dart
/// ├── widgets/
/// └── <page_name>_exports.dart
class PageGenerator {
  final String featureName;
  final String pageName;
  final String basePath;

  late final String featurePath;
  late final String pagePath;
  final List<String> generatedFiles = [];

  PageGenerator({
    required this.featureName,
    required this.pageName,
    required this.basePath,
  }) {
    NameUtils.validateSnakeCase(featureName, 'Feature name');
    NameUtils.validateSnakeCase(pageName, 'Page name');
  }

  Future<void> generate() async {
    featurePath = path.join(basePath, featureName);
    pagePath = path.join(featurePath, 'presentation', pageName);

    final featureDir = Directory(featurePath);
    if (!featureDir.existsSync()) {
      throw PageGeneratorException(
        'Feature "$featureName" not found at $featurePath. '
        'Generate the feature first with: '
        'dart run bin/clean_getx.dart generate -n $featureName',
      );
    }

    final pageDir = Directory(pagePath);
    if (pageDir.existsSync()) {
      throw PageGeneratorException(
        'Page "$pageName" already exists in feature "$featureName" '
        'at $pagePath. Choose a different name or remove the existing directory.',
      );
    }

    try {
      await _createDirectories();
      await _generateFiles();
      await _registerRoute();
    } catch (e) {
      if (e is PageGeneratorException) rethrow;
      throw PageGeneratorException('Failed to generate page: $e');
    }
  }

  Future<void> _createDirectories() async {
    await Directory(path.join(pagePath, 'binding')).create(recursive: true);
    await Directory(path.join(pagePath, 'controller')).create(recursive: true);
    await Directory(path.join(pagePath, 'view')).create(recursive: true);
    await Directory(path.join(pagePath, 'widgets')).create(recursive: true);

    final gitkeep = File(path.join(pagePath, 'widgets', '.gitkeep'));
    await gitkeep.writeAsString('');
  }

  Future<void> _generateFiles() async {
    final pascalPageName = NameUtils.toPascalCase(pageName);

    await _createFile(
      path.join(pagePath, 'controller', '${pageName}_controller.dart'),
      PageTemplates.controller(pageName, pascalPageName),
    );

    await _createFile(
      path.join(pagePath, 'binding', '${pageName}_binding.dart'),
      PageTemplates.binding(pageName, pascalPageName),
    );

    await _createFile(
      path.join(pagePath, 'view', '${pageName}_view.dart'),
      PageTemplates.view(pageName, pascalPageName),
    );

    await _createFile(
      path.join(pagePath, '${pageName}_exports.dart'),
      PageTemplates.pageExports(pageName),
    );
  }

  Future<void> _registerRoute() async {
    final routesDir = path.join(path.dirname(basePath), 'routes');
    final routesFile = File(path.join(routesDir, 'app_routes.dart'));
    final pagesFile = File(path.join(routesDir, 'app_pages.dart'));

    final routeConstant = _toCamelCase(pageName);
    final pascalPage = NameUtils.toPascalCase(pageName);

    if (routesFile.existsSync()) {
      var content = await routesFile.readAsString();
      if (!content.contains('static const $routeConstant')) {
        final entry = "  static const $routeConstant = '/$featureName/$pageName';\n";
        final insertAt = content.lastIndexOf('}');
        if (insertAt != -1) {
          content = content.substring(0, insertAt) + entry + content.substring(insertAt);
          await routesFile.writeAsString(content);
        }
      }
    }

    if (pagesFile.existsSync()) {
      var content = await pagesFile.readAsString();
      final bindingImport =
          "import '../features/$featureName/presentation/$pageName/binding/${pageName}_binding.dart';\n";
      final viewImport =
          "import '../features/$featureName/presentation/$pageName/view/${pageName}_view.dart';\n";

      if (!content.contains(bindingImport)) {
        final classIndex = content.indexOf('\nclass AppPages');
        if (classIndex != -1) {
          content = content.substring(0, classIndex) +
              '\n$bindingImport$viewImport' +
              content.substring(classIndex);
        }
      }

      if (!content.contains('AppRoutes.$routeConstant')) {
        final getPage = '    GetPage(\n'
            '      name: AppRoutes.$routeConstant,\n'
            '      page: () => const ${pascalPage}View(),\n'
            '      binding: ${pascalPage}Binding(),\n'
            '    ),\n';
        final closingAt = content.lastIndexOf('  ];');
        if (closingAt != -1) {
          content = content.substring(0, closingAt) + getPage + content.substring(closingAt);
        }
      }

      await pagesFile.writeAsString(content);
    }
  }

  String _toCamelCase(String snake) {
    final parts = snake.split('_').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return snake;
    return parts.first +
        parts.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
  }

  Future<void> _createFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
    generatedFiles.add(path.relative(filePath, from: basePath));
  }
}
