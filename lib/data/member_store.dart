import 'package:hive_flutter/hive_flutter.dart';

class MemberStore {
  static late Box<String> _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>('members');

    // 初期値（必要なら）
    if (_box.isEmpty) {
      await _box.addAll(["じょしゅあ", "あんこ", "ちん", "えび"]);
    }
  }

  static List<String> getAll() {
    return _box.values.toList();
  }

  static Future<void> add(String name) async {
    if (name.trim().isEmpty) return;
    await _box.add(name.trim());
  }

  static Future<void> delete(String name) async {
    final index = _box.values.toList().indexOf(name);
    if (index != -1) {
      await _box.deleteAt(index);
    }
  }
}
