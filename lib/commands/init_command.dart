import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:clean_getx/generators/init_generator.dart';
import 'package:clean_getx/utils/exceptions.dart';

class InitCommand extends Command {
  @override
  final name = 'init';

  @override
  final description =
      'Scaffold a clean GetX project structure inside lib/ of the target Flutter project.\n'
      'Also rewrites pubspec.yaml: cleans comments and injects required dependencies.';

  @override
  String get invocation =>
      'getx_cli init [--path <project_root>] [--sqlite] [--storage]';

  InitCommand() {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Root of the Flutter project (defaults to current directory)',
      defaultsTo: '.',
    );
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing lib/ files without asking',
      defaultsTo: false,
      negatable: false,
    );
    argParser.addFlag(
      'sqlite',
      help: 'Add SQLite support: generates database_service.dart & '
          'table_schemas.dart, and adds sqflite + path to pubspec',
      defaultsTo: false,
      negatable: false,
    );
    argParser.addFlag(
      'storage',
      help: 'Add local-storage support: generates local_storage_service.dart '
          'and adds get_storage to pubspec',
      defaultsTo: false,
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final rawPath = argResults!['path'] as String;
    final projectPath =
        rawPath == '.' ? Directory.current.path : rawPath;

    final force = argResults!['force'] as bool;
    final withSqlite = argResults!['sqlite'] as bool;
    final withStorage = argResults!['storage'] as bool;

    // ── sanity check ──────────────────────────────────────────────────────────
    final pubspec = File('$projectPath/pubspec.yaml');
    if (!pubspec.existsSync()) {
      stderr.writeln(
        '\n✗ No pubspec.yaml found at "$projectPath".\n'
        '  Run this command from the root of a Flutter project, or use '
        '  --path <project_root>.',
      );
      exit(1);
    }

    // ── confirmation when lib/ already has files ──────────────────────────────
    final libDir = Directory('$projectPath/lib');
    final hasExistingFiles = libDir.existsSync() &&
        libDir.listSync(recursive: true).whereType<File>().isNotEmpty;

    if (hasExistingFiles && !force) {
      stdout.write(
        '\n⚠  lib/ already contains files.\n'
        '   Existing files will be SKIPPED (not overwritten).\n'
        '   Use --force to overwrite them.\n'
        '\n'
        '   pubspec.yaml WILL be rewritten. Continue? (y/N): ',
      );

      final answer = stdin.readLineSync()?.trim().toLowerCase();
      if (answer != 'y' && answer != 'yes') {
        print('\nAborted.');
        exit(0);
      }
    }

    // ── summary of what will be done ─────────────────────────────────────────
    print('\n🚀 Scaffolding clean GetX structure in "$projectPath/lib/"...');
    if (withSqlite) print('   + SQLite support (sqflite)');
    if (withStorage) print('   + Local storage support (get_storage)');
    print('');

    try {
      final generator = InitGenerator(
        basePath: projectPath,
        withSqlite: withSqlite,
        withStorage: withStorage,
      );

      await generator.generate();

      // ── results ─────────────────────────────────────────────────────────────
      if (generator.pubspecRewritten) {
        print('✓ pubspec.yaml rewritten');
      }

      if (generator.generatedFiles.isNotEmpty) {
        print('\n✓ Generated files:');
        for (final f in generator.generatedFiles) {
          print('  + lib/$f');
        }
      }

      if (generator.skippedFiles.isNotEmpty) {
        print('\n⚠  Skipped (already exist):');
        for (final f in generator.skippedFiles) {
          print('  ~ lib/$f');
        }
        print('\n  Tip: run with --force to overwrite skipped files.');
      }

      print('\n✅ Done! Next steps:');
      print('  1. Run:  flutter pub get');
      print('  2. Review and customise the generated files.');
      print('  3. Add more features:  getx_cli generate -n <feature_name>');
    } on InitGeneratorException catch (e) {
      stderr.writeln('\n✗ Error: ${e.message}');
      exit(1);
    } catch (e) {
      stderr.writeln('\n✗ Unexpected error: $e');
      exit(1);
    }
  }
}
