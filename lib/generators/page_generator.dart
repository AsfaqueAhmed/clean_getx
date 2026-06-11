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

  Future<void> _createFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
    generatedFiles.add(path.relative(filePath, from: basePath));
  }
}
