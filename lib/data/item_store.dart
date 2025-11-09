import 'package:hive_flutter/hive_flutter.dart';

class ItemStore {
  static late Box<String> _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>('items');

    // ✅ 初回のみデフォルト商品を追加
    if (_box.isEmpty) {
      await _box.addAll(["タバコ", "ライター", "お菓子", "水"]);
    }
  }

  static List<String> getAll() => _box.values.toList();

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
