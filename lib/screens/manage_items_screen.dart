import 'package:flutter/material.dart';
import 'package:okami/data/item_store.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  final TextEditingController _ctrl = TextEditingController();

  Future<void> _add() async {
    await ItemStore.add(_ctrl.text.trim());
    _ctrl.clear();
  }

  Future<void> _delete(String name) async {
    await ItemStore.deactivate(name);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('商品管理', style: TextStyle(color: Colors.black87)),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _ctrl,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: "商品名を追加",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            /// ✅ ここを ValueListenableBuilder に変更
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: ItemStore.box.listenable(),
                builder: (_, __, ___) {
                  final items = ItemStore.getAll(); // ← 常に最新を取得

                  return ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (_, i) {
                      final name = items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.black54,
                              ),
                              onPressed: () => _delete(name),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
