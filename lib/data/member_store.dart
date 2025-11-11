import 'package:hive_flutter/hive_flutter.dart';

class MemberStore {
  static late Box<String> _box;
  static late Box<bool> _activeBox;

  static Future<void> init() async {
    _box = await Hive.openBox<String>('members');
    _activeBox = await Hive.openBox<bool>('members_active');

    if (_box.isEmpty) {
      final names = ["じょしゅあ", "あんこ", "ちん", "えび"];
      await _box.addAll(names);
      for (int i = 0; i < names.length; i++) {
        await _activeBox.put(i, true);
      }
    }
  }

  static List<String> getAll() => _box.values.toList();

  static List<String> getActive() {
    final result = <String>[];
    for (int i = 0; i < _box.length; i++) {
      if (_activeBox.get(i, defaultValue: true) == true) {
        result.add(_box.getAt(i)!.trim());
      }
    }
    return result;
  }

  static Future<void> add(String name) async {
    name = name.trim();
    if (name.isEmpty) return;
    final index = await _box.add(name);
    await _activeBox.put(index, true);
  }

  /// ✅ 同じ名前は全部非表示にする（← ここだけ修正）
  static Future<void> deactivate(String name) async {
    name = name.trim();
    final list = _box.values.toList();

    for (int i = 0; i < list.length; i++) {
      if (list[i].trim() == name) {
        await _activeBox.put(i, false); // break しない
      }
    }
  }
}
