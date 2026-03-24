import 'dart:html' as html;

import 'local_store.dart';

class _WebStore implements LocalStore {
  @override
  Future<String?> getString(String key) async {
    return html.window.localStorage[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    html.window.localStorage[key] = value;
  }
}

LocalStore createStore() => _WebStore();
