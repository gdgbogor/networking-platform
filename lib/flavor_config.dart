/// Environment.
enum Environment {
  /// Development.
  development,

  /// Staging.
  staging,

  /// Production.
  production,
}

/// {@template flavor_config}
/// Dart package which manages the project flavors.
/// {@endtemplate}
class FlavorConfig {
  /// {@macro flavor_config}
  factory FlavorConfig({
    required Environment environment,
  }) {
    _instance ??= FlavorConfig._internal(environment);
    return _instance!;
  }

  FlavorConfig._internal(this.environment);

  /// Flavor environment.
  final Environment environment;

  static FlavorConfig? _instance;

  /// Get current flavor config.
  static FlavorConfig? get instance => _instance;

  /// Check if current flavor environment is development.
  static bool get isDevelopment {
    return _instance?.environment == Environment.development;
  }

  /// Check if current flavor environment is staging.
  static bool get isStaging {
    return _instance?.environment == Environment.staging;
  }

  /// Check if current flavor environment is production.
  static bool get isProduction {
    return _instance?.environment == Environment.production;
  }
}
