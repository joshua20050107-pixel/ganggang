import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'team_ref.dart';

class ItemStore {
  static Box<String>? _itemsBox;
  static Box<bool>? _activeBox;
  static StreamSubscription? _listener;

  static Future<void> init() async {
    await dispose();

    _itemsBox = await Hive.openBox<String>('items');
    _activeBox = await Hive.openBox<bool>('items_active');

    _startListener();
  }

  static Box<String> get box => Hive.box<String>('items');

  static void _startListener() {
    _listener?.cancel();

    _listener = TeamRef.items.snapshots().listen((snapshot) async {
      final itemsBox = _itemsBox;
      final activeBox = _activeBox;
      if (itemsBox == null || !itemsBox.isOpen) return;
      if (activeBox == null || !activeBox.isOpen) return;

      await itemsBox.clear();
      await activeBox.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final isActive = (data['active'] ?? true) as bool;
        final itemName = doc.id;

        await itemsBox.add(itemName);
        await activeBox.put(itemName, isActive);
      }
    });
  }

  static Future<void> add(String name) async {
    name = name.trim();
    if (name.isEmpty) return;
    await TeamRef.items.doc(name).set({'active': true});
  }

  static Future<void> deactivate(String name) async {
    await TeamRef.items.doc(name.trim()).delete();
  }

  static List<String> getAll() {
    final items = _itemsBox?.values.toList() ?? const [];
    final active = _activeBox;

    if (active == null) return items;

    return items
        .where((name) => active.get(name, defaultValue: true) == true)
        .toList();
  }

  static Future<void> dispose() async {
    _listener?.cancel();
    _listener = null;

    if (Hive.isBoxOpen('items')) {
      await Hive.box<String>('items').close();
    }
    if (Hive.isBoxOpen('items_active')) {
      await Hive.box<bool>('items_active').close();
    }
  }
}
