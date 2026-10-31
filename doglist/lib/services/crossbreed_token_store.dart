import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/crossbreed_models.dart';

/// Holds the crossbreed installation credential. The token is a bearer secret: it lives only in
/// platform secure storage (iOS Keychain / Android Keystore-backed storage), never in
/// SharedPreferences, logs or image requests.
abstract class CrossbreedTokenStore {
  Future<CrossbreedInstallation?> read();
  Future<void> write(CrossbreedInstallation installation);
  Future<void> clear();
}

class SecureCrossbreedTokenStore implements CrossbreedTokenStore {
  SecureCrossbreedTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
            );

  static const _idKey = 'crossbreed.installationId';
  static const _tokenKey = 'crossbreed.installationToken';

  final FlutterSecureStorage _storage;

  @override
  Future<CrossbreedInstallation?> read() async {
    final id = await _storage.read(key: _idKey);
    final token = await _storage.read(key: _tokenKey);
    if (id == null || token == null || !isUuidV4(id)) return null;
    return CrossbreedInstallation(installationId: id, installationToken: token);
  }

  @override
  Future<void> write(CrossbreedInstallation installation) async {
    await _storage.write(key: _tokenKey, value: installation.installationToken);
    await _storage.write(key: _idKey, value: installation.installationId);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _idKey);
    await _storage.delete(key: _tokenKey);
  }
}

class InMemoryCrossbreedTokenStore implements CrossbreedTokenStore {
  CrossbreedInstallation? _value;

  @override
  Future<CrossbreedInstallation?> read() async => _value;

  @override
  Future<void> write(CrossbreedInstallation installation) async => _value = installation;

  @override
  Future<void> clear() async => _value = null;
}
