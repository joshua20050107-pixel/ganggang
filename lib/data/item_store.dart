import 'package:hive_flutter/hive_flutter.dart';

class ItemStore {
  static late Box<String> _box;
  static late Box<bool> _activeBox;

  static Future<void> init() async {
    _box = await Hive.openBox<String>('items');
    _activeBox = await Hive.openBox<bool>('items_active');

    if (_box.isEmpty) {
      final items = ["タバコ", "ライター", "お菓子", "水"];
      await _box.addAll(items);
      for (int i = 0; i < items.length; i++) {
        await _activeBox.put(i, true);
      }
    }
  }

  static List<String> getAll() => _box.values.toList();

  /// ✅ 今後の追加に使う「アクティブな商品」
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

  /// ✅ 非表示化（削除しない）
  static Future<void> deactivate(String name) async {
    final index = _box.values.toList().indexOf(name);
    if (index != -1) {
      await _activeBox.put(index, false);
    }
  }
}
