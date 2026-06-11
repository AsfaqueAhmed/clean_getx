import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'package:clean_getx/templates/init_templates.dart';
import 'package:clean_getx/utils/exceptions.dart';

/// Scaffolds the full clean-GetX project structure inside [basePath]/lib/:
///
/// lib/
///   main.dart
///   routes/
///     app_pages.dart  app_routes.dart
///   core/
///     configs/
///       text_style/app_text_styles.dart
///       theme/app_color.dart  app_colors.dart  app_theme.dart
///     constants/
///       app_decorations.dart  gaps.dart  margin.dart  padding.dart
///     database/                              ← only with --sqlite
///       database_service.dart  table_schemas.dart
///     extensions/
///       string_extensions.dart
///     services/
///       local_storage_service.dart           ← only with --storage
///     utils/
///       app_validators.dart  currency_formatter.dart
///     widgets/               (empty, .gitkeep)
///   features/
///     splash/presentation/splash/
///       bindings/splash_binding.dart
///       controllers/splash_controller.dart
///       views/splash_view.dart
class InitGenerator {
  final String basePath;
  final bool withSqlite;
  final bool withStorage;

  final List<String> generatedFiles = [];
  final List<String> skippedFiles = [];
  bool pubspecRewritten = false;

  InitGenerator({
    required this.basePath,
    this.withSqlite = false,
    this.withStorage = false,
  });

  String get libPath => path.join(basePath, 'lib');

  Future<void> generate() async {
    try {
      await _rewritePubspec();
      await _createFiles();
    } catch (e) {
      if (e is InitGeneratorException) rethrow;
      throw InitGeneratorException('Failed to scaffold project: $e');
    }
  }

  // ─── pubspec rewrite ────────────────────────────────────────────────────────

  Future<void> _rewritePubspec() async {
    final pubspecFile = File(path.join(basePath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    final content = await pubspecFile.readAsString();
    final doc = loadYaml(content) as YamlMap;

    final name = doc['name'] as String;
    final rawDesc = doc['description']?.toString() ?? 'A Flutter project.';
    final description = rawDesc.replaceAll('"', '').replaceAll("'", '');
    final version = doc['version']?.toString() ?? '1.0.0+1';

    final env = doc['environment'] as YamlMap?;
    final sdkConstraint = env?['sdk']?.toString() ?? '>=3.0.0 <4.0.0';

    // ── preserve existing dependencies (skip `flutter` — always in template) ──
    final deps = <String, String?>{};
    final existingDeps = doc['dependencies'] as YamlMap?;
    if (existingDeps != null) {
      for (final key in existingDeps.keys) {
        final k = key as String;
        if (k == 'flutter') continue; // rendered separately in template
        final val = existingDeps[k];
        // Skip nested sdk maps (e.g. flutter_test: {sdk: flutter})
        deps[k] = val is YamlMap ? null : val?.toString();
      }
    }

    // inject required packages (preserve version if already present)
    deps.putIfAbsent('get', () => null);
    deps.putIfAbsent('intl', () => null);
    if (withSqlite) {
      deps.putIfAbsent('sqflite', () => null);
      deps.putIfAbsent('path', () => null);
    }
    if (withStorage) {
      deps.putIfAbsent('get_storage', () => null);
    }

    // ── preserve dev_dependencies exactly as written (no modifications) ───────
    final rawDevDeps = _extractRawBlock(content, 'dev_dependencies');

    final newContent = InitTemplates.pubspecYaml(
      name: name,
      description: description,
      version: version,
      sdkConstraint: sdkConstraint,
      deps: deps,
      rawDevDeps: rawDevDeps,
    );

    await pubspecFile.writeAsString(newContent);
    pubspecRewritten = true;
  }

  // ─── file generation ────────────────────────────────────────────────────────

  Future<void> _createFiles() async {
    // main.dart
    await _write('main.dart', InitTemplates.mainDart());

    // routes/
    await _write('routes/app_routes.dart', InitTemplates.appRoutes());
    await _write('routes/app_pages.dart', InitTemplates.appPages());

    // core/configs/text_style/
    await _write(
      'core/configs/text_style/app_text_styles.dart',
      InitTemplates.appTextStyles(),
    );

    // core/configs/theme/
    await _write('core/configs/theme/app_color.dart', InitTemplates.appColor());
    await _write(
        'core/configs/theme/app_colors.dart', InitTemplates.appColors());
    await _write('core/configs/theme/app_theme.dart', InitTemplates.appTheme());

    // core/constants/
    await _write(
        'core/constants/app_decorations.dart', InitTemplates.appDecorations());
    await _write('core/constants/gaps.dart', InitTemplates.gaps());
    await _write('core/constants/margin.dart', InitTemplates.margin());
    await _write('core/constants/padding.dart', InitTemplates.padding());

    // core/database/ — only with --sqlite
    if (withSqlite) {
      await _write(
        'core/database/database_service.dart',
        InitTemplates.databaseService(),
      );
      await _write(
        'core/database/table_schemas.dart',
        InitTemplates.tableSchemas(),
      );
    }

    // core/extensions/
    await _write(
      'core/extensions/string_extensions.dart',
      InitTemplates.stringExtensions(),
    );

    // core/services/ — only with --storage
    if (withStorage) {
      await _write(
        'core/services/local_storage_service.dart',
        InitTemplates.localStorageService(),
      );
    }

    // core/utils/
    await _write(
        'core/utils/app_validators.dart', InitTemplates.appValidators());
    await _write(
        'core/utils/currency_formatter.dart', InitTemplates.currencyFormatter());

    // core/widgets/ — empty placeholder
    await _gitkeep('core/widgets');

    // features/splash/presentation/splash/
    await _write(
      'features/splash/presentation/splash/bindings/splash_binding.dart',
      InitTemplates.splashBinding(),
    );
    await _write(
      'features/splash/presentation/splash/controllers/splash_controller.dart',
      InitTemplates.splashController(),
    );
    await _write(
      'features/splash/presentation/splash/views/splash_view.dart',
      InitTemplates.splashView(),
    );
  }

  /// Writes [content] to lib/[relativePath].
  /// Skips silently if the file already exists.
  Future<void> _write(String relativePath, String content) async {
    final filePath = path.join(libPath, relativePath);
    final file = File(filePath);

    if (file.existsSync()) {
      skippedFiles.add(relativePath);
      return;
    }

    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    generatedFiles.add(relativePath);
  }

  Future<void> _gitkeep(String relativeDir) async {
    final dirPath = path.join(libPath, relativeDir);
    await Directory(dirPath).create(recursive: true);

    final keepFile = File(path.join(dirPath, '.gitkeep'));
    if (!keepFile.existsSync()) {
      await keepFile.writeAsString('');
    }
  }

  /// Extracts a top-level YAML block (e.g. `dev_dependencies:`) as raw text,
  /// preserving original formatting exactly.
  String _extractRawBlock(String content, String key) {
    final lines = content.split('\n');
    final buffer = StringBuffer();
    var inBlock = false;

    for (final line in lines) {
      if (line.startsWith('$key:')) {
        inBlock = true;
      } else if (inBlock &&
          line.isNotEmpty &&
          !line.startsWith(' ') &&
          !line.startsWith('\t') &&
          !line.startsWith('#')) {
        break; // reached next top-level key
      }
      if (inBlock) buffer.writeln(line);
    }

    return inBlock ? buffer.toString().trimRight() : '$key:';
  }
}
