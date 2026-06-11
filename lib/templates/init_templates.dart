/// Templates used by the `init` command to scaffold a Flutter project
/// with the clean GetX architecture structure.
class InitTemplates {
  // ─── pubspec.yaml ─────────────────────────────────────────────────────────

  static String pubspecYaml({
    required String name,
    required String description,
    required String version,
    required String sdkConstraint,
    required Map<String, String?> deps,
    required String rawDevDeps,
  }) {
    final depsBlock = deps.entries.map((e) {
      final v = e.value;
      return (v == null || v.isEmpty) ? '  ${e.key}:' : '  ${e.key}: $v';
    }).join('\n');

    return '''name: $name
description: "$description"
publish_to: 'none'
version: $version

environment:
  sdk: '$sdkConstraint'

dependencies:
  flutter:
    sdk: flutter
$depsBlock

$rawDevDeps

flutter:
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
''';
  }

  // ─── main.dart ────────────────────────────────────────────────────────────

  static String mainDart() => '''import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/configs/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
''';

  // ─── routes ───────────────────────────────────────────────────────────────

  static String appRoutes() => '''abstract class AppRoutes {
  static const splash = '/splash';
}
''';

  static String appPages() => '''import 'package:get/get.dart';

import '../features/splash/presentation/splash/bindings/splash_binding.dart';
import '../features/splash/presentation/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
  ];
}
''';

  // ─── core / configs / text_style ──────────────────────────────────────────

  static String appTextStyles() => '''import 'package:flutter/material.dart';

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
''';

  // ─── core / configs / theme ───────────────────────────────────────────────

  static String appColor() => '''import 'package:flutter/material.dart';

class AppColor {
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF03DAC6);
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFB00020);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFF000000);
  static const onBackground = Color(0xFF000000);
  static const onSurface = Color(0xFF000000);
  static const onError = Color(0xFFFFFFFF);

  // Dark theme
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
}
''';

  static String appColors() => '''import 'package:flutter/material.dart';

class AppColors {
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF6200EE,
    <int, Color>{
      50: Color(0xFFF3E5FF),
      100: Color(0xFFE1BEE7),
      200: Color(0xFFCE93D8),
      300: Color(0xFFBA68C8),
      400: Color(0xFFAB47BC),
      500: Color(0xFF9C27B0),
      600: Color(0xFF8E24AA),
      700: Color(0xFF7B1FA2),
      800: Color(0xFF6A1B9A),
      900: Color(0xFF4A148C),
    },
  );
}
''';

  static String appTheme() => '''import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        primarySwatch: AppColors.primarySwatch,
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: AppColor.background,
        colorScheme: const ColorScheme.light(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
          background: AppColor.background,
          surface: AppColor.surface,
          error: AppColor.error,
        ),
      );

  static ThemeData get dark => ThemeData.dark().copyWith(
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: AppColor.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
          background: AppColor.darkBackground,
          surface: AppColor.darkSurface,
        ),
      );
}
''';

  // ─── core / constants ─────────────────────────────────────────────────────

  static String appDecorations() => '''import 'package:flutter/material.dart';

import '../configs/theme/app_color.dart';

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColor.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static InputDecoration inputField({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );
}
''';

  static String gaps() => '''import 'package:flutter/material.dart';

class Gaps {
  // Vertical gaps
  static const h4 = SizedBox(height: 4);
  static const h8 = SizedBox(height: 8);
  static const h12 = SizedBox(height: 12);
  static const h16 = SizedBox(height: 16);
  static const h24 = SizedBox(height: 24);
  static const h32 = SizedBox(height: 32);
  static const h48 = SizedBox(height: 48);
  static const h64 = SizedBox(height: 64);

  // Horizontal gaps
  static const w4 = SizedBox(width: 4);
  static const w8 = SizedBox(width: 8);
  static const w12 = SizedBox(width: 12);
  static const w16 = SizedBox(width: 16);
  static const w24 = SizedBox(width: 24);
  static const w32 = SizedBox(width: 32);
  static const w48 = SizedBox(width: 48);
}
''';

  static String margin() => '''import 'package:flutter/material.dart';

class AppMargin {
  static const all4 = EdgeInsets.all(4);
  static const all8 = EdgeInsets.all(8);
  static const all12 = EdgeInsets.all(12);
  static const all16 = EdgeInsets.all(16);
  static const all24 = EdgeInsets.all(24);
  static const all32 = EdgeInsets.all(32);

  static const h8 = EdgeInsets.symmetric(horizontal: 8);
  static const h16 = EdgeInsets.symmetric(horizontal: 16);
  static const h24 = EdgeInsets.symmetric(horizontal: 24);

  static const v8 = EdgeInsets.symmetric(vertical: 8);
  static const v16 = EdgeInsets.symmetric(vertical: 16);

  static const page = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
}
''';

  static String padding() => '''import 'package:flutter/material.dart';

class AppPadding {
  static const all4 = EdgeInsets.all(4);
  static const all8 = EdgeInsets.all(8);
  static const all12 = EdgeInsets.all(12);
  static const all16 = EdgeInsets.all(16);
  static const all24 = EdgeInsets.all(24);
  static const all32 = EdgeInsets.all(32);

  static const h8 = EdgeInsets.symmetric(horizontal: 8);
  static const h16 = EdgeInsets.symmetric(horizontal: 16);
  static const h24 = EdgeInsets.symmetric(horizontal: 24);

  static const v8 = EdgeInsets.symmetric(vertical: 8);
  static const v16 = EdgeInsets.symmetric(vertical: 16);

  static const button = EdgeInsets.symmetric(horizontal: 24, vertical: 14);
  static const card = EdgeInsets.all(16);
  static const page = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
}
''';

  // ─── core / database ──────────────────────────────────────────────────────

  static String databaseService() => '''// Required package: sqflite, path
// Add to pubspec.yaml:
//   sqflite: ^2.3.0
//   path: ^1.9.0

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'table_schemas.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    for (final schema in TableSchemas.all) {
      await db.execute(schema);
    }
  }
}
''';

  static String tableSchemas() => '''class TableSchemas {
  // Example table — replace or extend as needed
  static const String example = \'''
    CREATE TABLE IF NOT EXISTS example (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  \''';

  static const List<String> all = [
    example,
  ];
}
''';

  // ─── core / extensions ────────────────────────────────────────────────────

  static String stringExtensions() => '''extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '\${this[0].toUpperCase()}\${substring(1)}';

  String get titleCase =>
      split(' ').map((word) => word.capitalize).join(' ');

  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\$')
          .hasMatch(this);

  bool get isValidPhone =>
      RegExp(r'^\\+?[0-9]{10,15}\$').hasMatch(this);

  String get removeWhitespace => replaceAll(RegExp(r'\\s+'), '');

  bool get isNullOrEmpty => trim().isEmpty;
}
''';

  // ─── core / services ──────────────────────────────────────────────────────

  static String localStorageService() => '''// Required package: get_storage
// Add to pubspec.yaml:
//   get_storage: ^2.1.1
// Call GetStorage().initStorage in main() before runApp.

import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  static final _box = GetStorage();

  static void write<T>(String key, T value) => _box.write(key, value);

  static T? read<T>(String key) => _box.read<T>(key);

  static void remove(String key) => _box.remove(key);

  static void erase() => _box.erase();

  static bool hasData(String key) => _box.hasData(key);
}
''';

  // ─── core / utils ─────────────────────────────────────────────────────────

  static String appValidators() => '''class AppValidators {
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return "\${fieldName ?? 'This field'} is required";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final regex = RegExp(r'^\\+?[0-9]{10,15}\$');
    if (!regex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.length < min) {
      return "\${fieldName ?? 'This field'} must be at least \$min characters";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }
}
''';

  static String currencyFormatter() => '''// Required package: intl
// Add to pubspec.yaml:
//   intl: ^0.19.0

import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(
    num amount, {
    String symbol = '\\\$',
    int decimalDigits = 2,
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  static String compact(num amount, {String symbol = '\\\$'}) {
    final formatter = NumberFormat.compactCurrency(symbol: symbol);
    return formatter.format(amount);
  }
}
''';

  // ─── features / splash ────────────────────────────────────────────────────

  static String splashBinding() => '''import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
''';

  static String splashController() => '''import 'package:get/get.dart';

// import your next route here, e.g.:
// import '../../../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    // TODO: navigate to your home screen
    // Get.offAllNamed(AppRoutes.home);
  }
}
''';

  static String splashView() => '''import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FlutterLogo(size: 100),
      ),
    );
  }
}
''';
}