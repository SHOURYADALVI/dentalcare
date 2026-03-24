import 'local_store.dart';

class _MemoryStore implements LocalStore {
  final Map<String, String> _storage = {};

  @override
  Future<String?> getString(String key) async => _storage[key];

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }
}

LocalStore createStore() => _MemoryStore();
