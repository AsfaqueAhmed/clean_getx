/// Templates for generating additional pages within an existing feature
/// Uses the same V2 structure: binding/, controller/, view/
class PageTemplates {
  static String controller(String pageName, String pascalPageName) =>
      '''import 'package:get/get.dart';

class ${pascalPageName}Controller extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize ${pascalPageName}
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetch${pascalPageName}() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      // TODO: Implement your logic here
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
''';

  static String binding(String pageName, String pascalPageName) =>
      '''import 'package:get/get.dart';
import '../controller/${pageName}_controller.dart';

class ${pascalPageName}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${pascalPageName}Controller>(
      () => ${pascalPageName}Controller(),
    );
  }
}
''';

  static String view(String pageName, String pascalPageName) =>
      '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/${pageName}_controller.dart';

class ${pascalPageName}View extends GetView<${pascalPageName}Controller> {
  const ${pascalPageName}View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${pascalPageName}'),
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
            child: Text('${pascalPageName} View'),
          );
        },
      ),
    );
  }
}
''';

  static String pageExports(String pageName) =>
      '''export 'binding/${pageName}_binding.dart';
export 'controller/${pageName}_controller.dart';
export 'view/${pageName}_view.dart';
''';
}
