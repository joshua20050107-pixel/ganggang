import 'package:flutter/material.dart';
import 'package:okami/data/member_store.dart';

class ManageMembersScreen extends StatefulWidget {
  const ManageMembersScreen({super.key});

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  final TextEditingController _ctrl = TextEditingController();

  void _add() async {
    await MemberStore.add(_ctrl.text);
    _ctrl.clear();
    setState(() {});
  }

  void _delete(String name) async {
    await MemberStore.deactivate(name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final members = MemberStore.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text('メンバー管理')),
      body: Column(
        children: [
          // 入力欄
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: "名前を追加",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _add(),
            ),
          ),

          // リスト
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, i) {
                final name = members[i];
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
    );
  }
}
