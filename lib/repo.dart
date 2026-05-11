import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

late ContactsRepo repo;

class ContactsRepo extends ChangeNotifier {
  static const _key = 'dossier.contacts.v1';

  final SharedPreferences _prefs;
  final List<Contact> _contacts;

  ContactsRepo._(this._prefs, this._contacts);

  static Future<ContactsRepo> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final list = <Contact>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        for (final e in decoded) {
          list.add(Contact.fromJson(Map<String, dynamic>.from(e as Map)));
        }
      } catch (e) {
        debugPrint('Failed to load contacts: $e');
      }
    }
    return ContactsRepo._(prefs, list);
  }

  List<Contact> get contacts => List.unmodifiable(_contacts);

  Contact? byId(String id) {
    for (final c in _contacts) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> upsert(Contact c) async {
    final i = _contacts.indexWhere((x) => x.id == c.id);
    if (i >= 0) {
      _contacts[i] = c;
    } else {
      _contacts.add(c);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_contacts.map((c) => c.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  String exportJson() {
    return const JsonEncoder.withIndent('  ')
        .convert(_contacts.map((c) => c.toJson()).toList());
  }

  Future<int> importJson(String json, {bool merge = true}) async {
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array of contacts');
    }
    final incoming = decoded
        .map((e) => Contact.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (!merge) _contacts.clear();
    for (final c in incoming) {
      final i = _contacts.indexWhere((x) => x.id == c.id);
      if (i >= 0) {
        _contacts[i] = c;
      } else {
        _contacts.add(c);
      }
    }
    await _persist();
    notifyListeners();
    return incoming.length;
  }
}
