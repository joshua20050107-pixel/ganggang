import 'package:hive_flutter/hive_flutter.dart';

class MemberStore {
  static late Box<String> _box; // 名前リスト
  static late Box<bool> _activeBox; // アクティブ状態

  static Future<void> init() async {
    _box = await Hive.openBox<String>('members');
    _activeBox = await Hive.openBox<bool>('members_active');

    // 初期値
    if (_box.isEmpty) {
      final names = ["じょしゅあ", "あんこ", "ちん", "えび"];
      await _box.addAll(names);
      for (int i = 0; i < names.length; i++) {
        await _activeBox.put(i, true);
      }
    }
  }

  static List<String> getAll() => _box.values.toList();

  /// ✅ 今後の入力に使う「アクティブな人だけ」
  static List<String> getActive() {
    final result = <String>[];
    for (int i = 0; i < _box.length; i++) {
      if (_activeBox.get(i, defaultValue: true) == true) {
        result.add(_box.getAt(i)!);
      }
    }
    return result;
  }

  static Future<void> add(String name) async {
    if (name.trim().isEmpty) return;
    final index = await _box.add(name.trim());
    await _activeBox.put(index, true);
  }

  /// ✅ 削除ではなく「今後非表示」
  static Future<void> deactivate(String name) async {
    final index = _box.values.toList().indexOf(name);
    if (index != -1) {
      await _activeBox.put(index, false);
    }
  }
}
