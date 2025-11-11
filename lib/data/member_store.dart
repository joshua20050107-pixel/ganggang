import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'team_ref.dart';

class MemberStore {
  static Box<String>? _box;
  static Box<bool>? _activeBox;
  static StreamSubscription? _listener;

  static Box<String> get box => Hive.box<String>('members');

  static Future<void> init() async {
    await dispose();
    _box = await Hive.openBox<String>('members');
    _activeBox = await Hive.openBox<bool>('members_active');
    _startListener();
  }

  static void _startListener() {
    _listener?.cancel();

    _listener = TeamRef.members.snapshots().listen((snapshot) async {
      final box = _box;
      final active = _activeBox;
      if (box == null || active == null || !box.isOpen || !active.isOpen)
        return;

      await box.clear();
      await active.clear();

      for (var doc in snapshot.docs) {
        final name = doc.id;
        final isActive = (doc.data()['active'] ?? true) as bool;

        final index = await box.add(name);
        await active.put(index, isActive);
      }
    });
  }

  static Future<void> add(String name) async {
    name = name.trim();
    if (name.isEmpty) return;
    await TeamRef.members.doc(name).set({'active': true});
  }

  static Future<void> deactivate(String name) async {
    await TeamRef.members.doc(name.trim()).update({'active': false});
  }

  static List<String> getActive() {
    final box = _box;
    final active = _activeBox;
    if (box == null || active == null) return const [];

    final list = <String>[];
    for (int i = 0; i < box.length; i++) {
      if (active.get(i, defaultValue: true) == true) {
        list.add(box.getAt(i)!.trim());
      }
    }
    return list;
  }

  static Future<void> dispose() async {
    _listener?.cancel();
    _listener = null;

    if (Hive.isBoxOpen('members')) {
      await Hive.box<String>('members').close();
    }
    if (Hive.isBoxOpen('members_active')) {
      await Hive.box<bool>('members_active').close();
    }
  }
}
