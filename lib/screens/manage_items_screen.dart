import 'package:flutter/material.dart';
import 'package:okami/data/item_store.dart';

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
    setState(() {});
  }

  Future<void> _delete(String name) async {
    await ItemStore.deactivate(name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = ItemStore.getActive();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 👈 外タップでフォーカス解除
      child: Scaffold(
        appBar: AppBar(title: const Text('商品管理')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: "商品名を追加",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, i) {
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
