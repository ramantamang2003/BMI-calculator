import 'package:shared_preferences/shared_preferences.dart';

import '../models/bmi_record.dart';

class BmiHistoryService {
  static const String _storageKey = 'bmi_history_records_v1';

  Future<List<BmiRecord>> getRecords() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encoded = prefs.getStringList(_storageKey) ?? <String>[];

    return encoded.map(BmiRecord.fromJson).toList(growable: false);
  }

  Future<void> saveRecord(BmiRecord record) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encoded = prefs.getStringList(_storageKey) ?? <String>[];

    encoded.insert(0, record.toJson());
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> deleteRecord(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encoded = prefs.getStringList(_storageKey) ?? <String>[];
    encoded.removeWhere((item) => BmiRecord.fromJson(item).id == id);
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
