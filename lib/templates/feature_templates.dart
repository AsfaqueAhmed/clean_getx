/// Templates for generating feature files in V2 structure
/// (presentation grouped by page: binding/, controller/, view/)
class FeatureTemplates {
  static String controller(String name, String pascalName) =>
      '''import 'package:get/get.dart';

class ${pascalName}Controller extends GetxController {
  // Observables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize controller
  }

  @override
  void onReady() {
    super.onReady();
    // Called after widget is rendered
  }

  @override
  void onClose() {
    super.onClose();
    // Cleanup resources
  }

  // Methods
  Future<void> fetch${pascalName}() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      // TODO: Implement business logic
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
''';

  static String binding(String name, String pascalName) =>
      '''import 'package:get/get.dart';
import '../controller/${name}_controller.dart';

class ${pascalName}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${pascalName}Controller>(
      () => ${pascalName}Controller(),
    );
  }
}
''';

  static String view(String name, String pascalName) =>
      '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/${name}_controller.dart';

class ${pascalName}View extends GetView<${pascalName}Controller> {
  const ${pascalName}View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${pascalName}'),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text(
                'Error: \${controller.errorMessage.value}',
                textAlign: TextAlign.center,
              ),
            );
          }

          return const Center(
            child: Text('${pascalName} View'),
          );
        },
      ),
    );
  }
}
''';

  static String presentationExport(String name, String pascalName) =>
      '''export 'binding/${name}_binding.dart';
export 'controller/${name}_controller.dart';
export 'view/${name}_view.dart';
''';

  static String entity(String name, String pascalName) =>
      '''import 'package:equatable/equatable.dart';

abstract class ${pascalName}Entity extends Equatable {
  final String id;
  final String title;
  final String description;

  const ${pascalName}Entity({
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [id, title, description];
}
''';

  static String model(String name, String pascalName) =>
      '''import '../../domain/entities/${name}_entity.dart';

class ${pascalName}Model extends ${pascalName}Entity{

  ${pascalName}Model({
    required super.id,
    required super.title,
    required super.description,
  }) : super();

  factory ${pascalName}Model.fromJson(Map<String, dynamic> json) =>
      ${pascalName}Model(
        id: json['id'],
        title: json['title'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
  };
}
''';

  static String modelsExport(String name) => '''export '${name}_model.dart';
''';

  static String domainRepository(String name, String pascalName) =>
      '''import '../entities/${name}_entity.dart';

abstract class ${pascalName}Repository {
  Future<List<${pascalName}Entity>> fetch${pascalName}List();
  Future<${pascalName}Entity> get${pascalName}ById(String id);
  Future<void> create${pascalName}(${pascalName}Entity entity);
  Future<void> update${pascalName}(${pascalName}Entity entity);
  Future<void> delete${pascalName}(String id);
}
''';

  static String repositoryImpl(String name, String pascalName) =>
      '''import '../../domain/repositories/${name}_repository.dart';
import '../../domain/entities/${name}_entity.dart';
import '../models/${name}_model.dart';

class ${pascalName}RepositoryImpl implements ${pascalName}Repository {

  ${pascalName}RepositoryImpl();

  @override
  Future<List<${pascalName}Entity>> fetch${pascalName}List() async {
    ///Need to implement
  }

  @override
  Future<${pascalName}Entity> get${pascalName}ById(String id) async {
    ///Need to implement
  }

  @override
  Future<void> create${pascalName}(${pascalName}Entity entity) async {
    ///Need to implement
  }

  @override
  Future<void> update${pascalName}(${pascalName}Entity entity) async {
    ///Need to implement
  }

  @override
  Future<void> delete${pascalName}(String id) async {
    ///Need to implement
  }
}
''';
}
