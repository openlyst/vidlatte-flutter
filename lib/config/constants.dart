class AppConfig {
  static const String appName = 'Vidlatte';
  static const String appVersion = '0.1.0';

  static const Duration defaultCacheDuration = Duration(minutes: 5);
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  static const Duration searchDebounce = Duration(milliseconds: 300);
}

class ThemeConstants {
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);

  static const double elevationSmall = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationLarge = 8.0;
}

class ComfyConstants {
  static const int defaultSteps = 20;
  static const int maxSteps = 150;
  static const int minSteps = 1;
  static const int defaultMaxLoras = 5;
  static const double defaultLoraStrength = 0.8;
  static const int defaultWidth = 1024;
  static const int defaultHeight = 1024;
  static const int pollIntervalMs = 1000;
  static const int maxPollAttempts = 300;
  static const int healthCheckTimeoutMs = 5000;
  static const double hiresFixScale = 1.5;
  static const int hiresFixSteps = 10;
  static const int maxSeed = 2147483647;
  static const int maxPromptLength = 2000;
}

class StorageKeys {
  static const String servers = 'servers';
  static const String images = 'images';
  static const String collections = 'collections';
  static const String settings = 'settings';
  static const String themeMode = 'theme_mode';
}

class ErrorMessages {
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No connection. Please check your network and try again.';
  static const String serverError = 'Server error. Please try again later.';
  static const String notFound = 'Resource not found.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String comfyConnectionError = 'Could not connect to ComfyUI server. Check the URL and make sure it is running.';
  static const String comfyNoServer = 'No ComfyUI server configured. Add one in Settings.';
}
