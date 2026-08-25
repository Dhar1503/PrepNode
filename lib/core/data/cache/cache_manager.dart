import 'package:shared_preferences/shared_preferences.dart';
import '../failures.dart';
import '../result.dart';

/// Cache Manager for offline-first architecture
/// Handles cache expiration, invalidation, and metadata
class CacheManager {
  final SharedPreferences _prefs;

  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  static const String _cacheVersionKey = 'cache_version';
  static const int _currentCacheVersion = 1;

  CacheManager(this._prefs);

  /// Initialize cache manager
  static Future<CacheManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheManager(prefs);
  }

  /// Check if cache is valid (not expired)
  bool isCacheValid(String cacheKey, {Duration? maxAge}) {
    final timestamp = _prefs.getInt('$_cacheTimestampPrefix$cacheKey');
    if (timestamp == null) {
      return false;
    }

    if (maxAge != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final expiryTime = cacheTime.add(maxAge);
      return DateTime.now().isBefore(expiryTime);
    }

    return true;
  }

  /// Update cache timestamp
  Future<Result<void>> updateCacheTimestamp(String cacheKey) async {
    try {
      await _prefs.setInt('$_cacheTimestampPrefix$cacheKey', DateTime.now().millisecondsSinceEpoch);
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure.writeFailed(originalError: e));
    }
  }

  /// Clear cache timestamp for a specific key
  Future<Result<void>> clearCacheTimestamp(String cacheKey) async {
    try {
      await _prefs.remove('$_cacheTimestampPrefix$cacheKey');
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure.writeFailed(originalError: e));
    }
  }

  /// Clear all cache timestamps
  Future<Result<void>> clearAllCacheTimestamps() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_cacheTimestampPrefix));
      for (final key in keys) {
        await _prefs.remove(key);
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure.writeFailed(originalError: e));
    }
  }

  /// Get cache version
  int getCacheVersion() {
    return _prefs.getInt(_cacheVersionKey) ?? 0;
  }

  /// Update cache version (call when cache structure changes)
  Future<Result<void>> updateCacheVersion() async {
    try {
      await _prefs.setInt(_cacheVersionKey, _currentCacheVersion);
      // Clear all cache when version changes
      await clearAllCacheTimestamps();
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure.writeFailed(originalError: e));
    }
  }

  /// Check if cache needs migration
  bool needsCacheMigration() {
    return getCacheVersion() < _currentCacheVersion;
  }

  /// Get cache age for a specific key
  Duration? getCacheAge(String cacheKey) {
    final timestamp = _prefs.getInt('$_cacheTimestampPrefix$cacheKey');
    if (timestamp == null) {
      return null;
    }
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime);
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_cacheTimestampPrefix));
    final timestamps = keys.map((key) => _prefs.getInt(key)).whereType<int>();
    
    if (timestamps.isEmpty) {
      return {
        'totalCachedItems': 0,
        'oldestCacheAge': null,
        'newestCacheAge': null,
        'cacheVersion': getCacheVersion(),
      };
    }

    final now = DateTime.now();
    final ages = timestamps.map((ts) => now.difference(DateTime.fromMillisecondsSinceEpoch(ts)));
    final oldest = ages.reduce((a, b) => a > b ? a : b);
    final newest = ages.reduce((a, b) => a < b ? a : b);

    return {
      'totalCachedItems': keys.length,
      'oldestCacheAge': oldest,
      'newestCacheAge': newest,
      'cacheVersion': getCacheVersion(),
    };
  }
}
