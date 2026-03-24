import 'dart:convert';
import 'dart:io';

import 'local_store.dart';

class _IoStore implements LocalStore {
  final File _file = File('${Directory.current.path}${Platform.pathSeparator}dentlink_local_store.json');

  Future<Map<String, dynamic>> _readAll() async {
    if (!await _file.exists()) {
      return {};
    }

    final text = await _file.readAsString();
    if (text.trim().isEmpty) return {};

    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeAll(Map<String, dynamic> data) async {
    await _file.writeAsString(jsonEncode(data));
  }

  @override
  Future<String?> getString(String key) async {
    final data = await _readAll();
    final value = data[key];
    return value is String ? value : null;
  }

  @override
  Future<void> setString(String key, String value) async {
    final data = await _readAll();
    data[key] = value;
    await _writeAll(data);
  }
}

LocalStore createStore() => _IoStore();
