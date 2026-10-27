/// API Constants
/// Base URL, endpoints, and configuration constants
library;

class ApiConstants {
  /// Base URL for the API
  static const String baseUrl = 'https://api.prepnode.app/api/v1';

  /// Legacy endpoint aliases used by existing data-layer code
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleAuth = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String mockTests = '/mock-test';

  /// Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Token expiration time (15 minutes as per API docs)
  static const Duration accessTokenExpiration = Duration(minutes: 15);

  /// Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  /// Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authGoogle = '/auth/google';
  static const String authRefresh = '/auth/refresh';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authLogout = '/auth/logout';

  static const String usersProfile = '/users';
  static const String usersPreferences = '/preferences';
  static const String usersAvatar = '/avatar';
  static const String usersAchievements = '/achievements';
  static const String usersRecommendedResources = '/recommended-resources';
  static const String usersBookmarks = '/bookmarks';

  static const String exams = '/exams';
  static const String subjects = '/subjects';
  static const String topics = '/topics';
  static const String topicGraph = '/graph';
  static const String graph = topicGraph;
  static const String searchTopics = '/search';
  static const String learningPath = '/learning-path';
  static const String topicResources = '/resources';

  static const String pyq = '/pyq';
  static const String pyqQuestion = '/question';
  static const String pyqAttempt = '/attempt';
  static const String pyqAttempts = '/attempts';

  static const String mockTest = '/mock-test';
  static const String mockTestConfig = '/config';
  static const String mockTestStart = '/start';
  static const String mockTestSubmit = '/submit';
  static const String mockTestResult = '/result';
  static const String mockTestReview = '/review';

  static const String planner = '/planner';
  static const String plannerGenerate = '/generate';
  static const String plannerTask = '/task';
  static const String plannerReschedule = '/reschedule';

  static const String analytics = '/analytics';
  static const String analyticsStrengthMap = '/strength-map';
  static const String analyticsTimeInvested = '/time-invested';
  static const String analyticsConfidenceTrend = '/confidence-trend';
  static const String analyticsConfidenceCheckin = '/confidence-checkin';

  static const String cutoff = '/cutoff';
  static const String cutoffTrend = '/trend';

  static const String resources = '/resources';
  static const String resourceRate = '/rate';

  static const String bookmarks = '/bookmarks';

  static const String achievements = '/achievements';
  static const String achievementSeen = '/seen';
}
