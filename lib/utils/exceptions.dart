/// Exception thrown by feature generation
class FeatureGeneratorException implements Exception {
  final String message;
  FeatureGeneratorException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown by page generation
class PageGeneratorException implements Exception {
  final String message;
  PageGeneratorException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown by init scaffolding
class InitGeneratorException implements Exception {
  final String message;
  InitGeneratorException(this.message);

  @override
  String toString() => message;
}

/// Shared name validation & case conversion utilities
class NameUtils {
  static final _snakeCasePattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

  /// Validates that [name] is valid snake_case
  /// (lowercase letters, digits, underscores; must start with a letter)
  static void validateSnakeCase(String name, String label) {
    if (name.isEmpty) {
      throw FeatureGeneratorException('$label cannot be empty');
    }
    if (name != name.toLowerCase()) {
      throw FeatureGeneratorException('$label must be in snake_case (lowercase)');
    }
    if (!_snakeCasePattern.hasMatch(name)) {
      throw FeatureGeneratorException(
        '$label must contain only lowercase letters, digits, and underscores, '
        'and must start with a letter (e.g. "product_list")',
      );
    }
  }

  /// Converts snake_case to PascalCase
  /// e.g. product_list -> ProductList
  static String toPascalCase(String input) {
    return input
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join();
  }
}
