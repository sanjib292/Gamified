/// Application-wide configuration constants.
///
/// In production, sensitive values should be injected via --dart-define or
/// a CI secret manager rather than being committed to source.
library app_config;

/// Deployment environment.
enum Environment { dev, staging, prod }

abstract final class AppConfig {
  // ---------------------------------------------------------------------------
  // Environment
  // ---------------------------------------------------------------------------

  /// Active environment — override via `--dart-define=ENVIRONMENT=prod`.
  static const String _envString =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');

  static Environment get environment => switch (_envString) {
        'prod' => Environment.prod,
        'staging' => Environment.staging,
        _ => Environment.dev,
      };

  static bool get isProduction => environment == Environment.prod;
  static bool get isDev => environment == Environment.dev;
  static bool get isStaging => environment == Environment.staging;

  // ---------------------------------------------------------------------------
  // Supabase
  // ---------------------------------------------------------------------------

  /// Supabase project URL.
  /// Override: `--dart-define=SUPABASE_URL=https://xxx.supabase.co`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );

  /// Supabase anonymous (public) key.
  /// Override: `--dart-define=SUPABASE_ANON_KEY=eyJ...`
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  // ---------------------------------------------------------------------------
  // OpenAI
  // ---------------------------------------------------------------------------

  /// OpenAI API key — used only for direct client calls (prefer Edge Functions).
  /// Override: `--dart-define=OPENAI_API_KEY=sk-...`
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'placeholder-openai-key',
  );

  // ---------------------------------------------------------------------------
  // Feature flags
  // ---------------------------------------------------------------------------

  static const bool enableAiCoach =
      bool.fromEnvironment('ENABLE_AI_COACH', defaultValue: true);

  static const bool enableSocialFeatures =
      bool.fromEnvironment('ENABLE_SOCIAL', defaultValue: true);

  static const bool enableAnalytics =
      bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: true);

  // ---------------------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------------------

  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
}
