import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:clean_getx/commands/init_command.dart';
import 'package:clean_getx/commands/generate_feature_command.dart';
import 'package:clean_getx/commands/generate_page_command.dart';

void main(List<String> args) async {
  final runner = CommandRunner(
    'getx_cli',
    'GetX Feature & Page Generator CLI - Scaffold features and pages with clean architecture',
  )
    ..addCommand(InitCommand())
    ..addCommand(GenerateFeatureCommand())
    ..addCommand(GeneratePageCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(2);
  }
}
