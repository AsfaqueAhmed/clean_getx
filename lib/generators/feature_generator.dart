import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:clean_getx/templates/feature_templates.dart';
import 'package:clean_getx/utils/exceptions.dart';

/// Generates a new feature with the V2 structure:
///
/// lib/features/<name>/
/// ├── data/
/// │   ├── models/<name>_model.dart (+ models_export.dart)
/// │   └── repositories/<name>_repository_impl.dart
/// ├── domain/
/// │   ├── entities/<name>_entity.dart
/// │   ├── repositories/<name>_repository.dart
/// │   └── usecases/
/// └── presentation/
///     └── <name>/
///         ├── binding/<name>_binding.dart
///         ├── controller/<name>_controller.dart
///         ├── view/<name>_view.dart
///         ├── widgets/
///         └── <name>_exports.dart
class FeatureGenerator {
  final String name;
  final String basePath;
  final bool withModel;
  final bool withRepository;

  late final String featurePath;
  final List<String> generatedFiles = [];

  FeatureGenerator({
    required this.name,
    required this.basePath,
    required this.withModel,
    required this.withRepository,
  }) {
    NameUtils.validateSnakeCase(name, 'Feature name');
  }

  Future<void> generate() async {
    featurePath = path.join(basePath, name);

    final featureDir = Directory(featurePath);
    if (featureDir.existsSync()) {
      throw FeatureGeneratorException(
        'Feature "$name" already exists at $featurePath. '
        'Choose a different name or remove the existing directory.',
      );
    }

    try {
      await _createDirectories();
      await _generateFiles();
    } catch (e) {
      if (e is FeatureGeneratorException) rethrow;
      throw FeatureGeneratorException('Failed to generate feature: $e');
    }
  }

  Future<void> _createDirectories() async {
    final dirs = [
      // Presentation - V2 grouped-by-page structure
      path.join(featurePath, 'presentation', name, 'binding'),
      path.join(featurePath, 'presentation', name, 'controller'),
      path.join(featurePath, 'presentation', name, 'view'),
      path.join(featurePath, 'presentation', name, 'widgets'),

      // Data layer
      path.join(featurePath, 'data', 'models'),
      path.join(featurePath, 'data', 'repositories'),

      // Domain layer
      path.join(featurePath, 'domain', 'entities'),
      path.join(featurePath, 'domain', 'repositories'),
      path.join(featurePath, 'domain', 'usecases'),
    ];

    for (final dir in dirs) {
      await Directory(dir).create(recursive: true);
    }

    // Add .gitkeep to empty dirs so they're tracked by git
    await _gitkeep(path.join(featurePath, 'presentation', name, 'widgets'));
    await _gitkeep(path.join(featurePath, 'domain', 'usecases'));
    if (!withRepository) {
      await _gitkeep(path.join(featurePath, 'data', 'repositories'));
      await _gitkeep(path.join(featurePath, 'domain', 'repositories'));
    }
  }

  Future<void> _gitkeep(String dirPath) async {
    final file = File(path.join(dirPath, '.gitkeep'));
    if (!file.existsSync()) {
      await file.writeAsString('');
    }
  }

  Future<void> _generateFiles() async {
    final pascalName = NameUtils.toPascalCase(name);
    final pres = path.join(featurePath, 'presentation', name);

    // Presentation layer (V2: grouped by page)
    await _createFile(
      path.join(pres, 'controller', '${name}_controller.dart'),
      FeatureTemplates.controller(name, pascalName),
    );
    await _createFile(
      path.join(pres, 'binding', '${name}_binding.dart'),
      FeatureTemplates.binding(name, pascalName),
    );
    await _createFile(
      path.join(pres, 'view', '${name}_view.dart'),
      FeatureTemplates.view(name, pascalName),
    );
    await _createFile(
      path.join(pres, '${name}_exports.dart'),
      FeatureTemplates.presentationExport(name, pascalName),
    );

    // Domain layer
    await _createFile(
      path.join(featurePath, 'domain', 'entities', '${name}_entity.dart'),
      FeatureTemplates.entity(name, pascalName),
    );

    // Data layer
    if (withModel) {
      await _createFile(
        path.join(featurePath, 'data', 'models', '${name}_model.dart'),
        FeatureTemplates.model(name, pascalName),
      );
      await _createFile(
        path.join(featurePath, 'data', 'models', 'models_export.dart'),
        FeatureTemplates.modelsExport(name),
      );
    }

    if (withRepository) {
      await _createFile(
        path.join(featurePath, 'domain', 'repositories', '${name}_repository.dart'),
        FeatureTemplates.domainRepository(name, pascalName),
      );
      await _createFile(
        path.join(featurePath, 'data', 'repositories', '${name}_repository_impl.dart'),
        FeatureTemplates.repositoryImpl(name, pascalName),
      );
    }
  }

  Future<void> _createFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
    generatedFiles.add(path.relative(filePath, from: basePath));
  }
}
