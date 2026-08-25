/// PrepGraph Environment Configuration
/// Manages environment-specific settings
class AppConfig {
  AppConfig._();

  // Environment
  static const Environment currentEnvironment = Environment.development;

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const int apiTimeoutSeconds = 30;

  // Feature Flags
  static const bool enableMockTests = true;
  static const bool enableAIAssistant = true;
  static const bool enableKnowledgeGraph = true;
  static const bool enableCutoffIntelligence = true;

  // Analytics
  static const bool enableAnalytics = true;

  // Debug Mode
  static const bool isDebugMode = currentEnvironment == Environment.development;
}

enum Environment {
  development,
  staging,
  production,
}
