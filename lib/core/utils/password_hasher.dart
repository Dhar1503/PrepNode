/// Password and token hashing for PrepNode's local-only account store.
///
/// PrepNode has no backend: accounts live entirely in the on-device Drift
/// database, so this device is the only thing that ever verifies a password.
/// That makes the hash the single line of defence if the database file is
/// ever extracted from the device.
///
/// The previous implementation used a djb2 string mix, which is a checksum,
/// not a password hash — it is trivially reversible by brute force and has
/// no salt, so identical passwords produced identical hashes. This replaces
/// it with salted SHA-256 while still being able to verify (and silently
/// upgrade) any account created under the old scheme.
library;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  /// Marker for the current scheme. Stored hashes look like
  /// `sha256$<saltHex>$<digestHex>` so the format is self-describing and a
  /// future scheme change can be detected the same way this one detects
  /// legacy djb2 hashes (which contain no `$`).
  static const String _scheme = 'sha256';
  static const int _saltBytes = 16;
  static const int _iterations = 10000;

  static final Random _random = Random.secure();

  /// Hash [password] with a freshly generated random salt.
  static String hash(String password) {
    final salt = _generateSalt();
    return '$_scheme\$$salt\$${_derive(password, salt)}';
  }

  /// Verify [password] against a [stored] hash produced by [hash], or by the
  /// legacy djb2 scheme. Returns false for an empty/absent stored hash — an
  /// account with no password (e.g. one that only ever existed remotely)
  /// cannot be logged into locally.
  static bool verify(String password, String stored) {
    if (stored.isEmpty) return false;

    final parts = stored.split(r'$');
    if (parts.length == 3 && parts[0] == _scheme) {
      return _constantTimeEquals(_derive(password, parts[1]), parts[2]);
    }

    // Legacy djb2 hash from before this class existed. Still verified so
    // existing accounts are not locked out by the upgrade; callers should
    // check [needsUpgrade] and re-hash after a successful login.
    return _constantTimeEquals(legacyHash(password), stored);
  }

  /// Whether [stored] was produced by the legacy scheme and should be
  /// re-hashed the next time the plaintext password is available.
  static bool needsUpgrade(String stored) {
    if (stored.isEmpty) return false;
    final parts = stored.split(r'$');
    return !(parts.length == 3 && parts[0] == _scheme);
  }

  /// Deterministic (unsalted) SHA-256, for values that must be *looked up*
  /// by their hash rather than verified against a known row — refresh
  /// tokens are queried with `WHERE token_hash = ?`, which a per-row random
  /// salt would make impossible. Tokens are already high-entropy UUIDs, so
  /// they do not need a salt the way a human-chosen password does.
  static String hashToken(String token) {
    return sha256.convert(utf8.encode('prepnode-token::$token')).toString();
  }

  /// The old djb2 mix, kept only so [verify] can recognise pre-existing
  /// accounts and so legacy token rows can still be matched.
  static String legacyHash(String value) {
    final bytes = utf8.encode('prepnode-local-salt::$value');
    int hash = 5381;
    for (final byte in bytes) {
      hash = ((hash << 5) + hash + byte) & 0x7FFFFFFF;
    }
    return hash.toRadixString(16);
  }

  static String _generateSalt() {
    final bytes = List<int>.generate(_saltBytes, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Iterated SHA-256. Not bcrypt/argon2 — those need a native dependency
  /// this offline-first project does not carry — but the iteration count
  /// turns a single guess from one hash into ten thousand, which is what
  /// makes an extracted database expensive to attack rather than instant.
  static String _derive(String password, String salt) {
    var digest = sha256.convert(utf8.encode('$salt::$password'));
    for (var i = 1; i < _iterations; i++) {
      digest = sha256.convert(digest.bytes);
    }
    return digest.toString();
  }

  /// Compares two hex digests without an early return, so verification time
  /// does not depend on how many leading characters happened to match.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
