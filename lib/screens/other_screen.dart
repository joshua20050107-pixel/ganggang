import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/sale_store.dart';
import '../data/member_store.dart';
import '../data/item_store.dart';

import 'manage_members_screen.dart';
import 'manage_items_screen.dart';
import 'team_login_screen.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await SaleStore.dispose();
    await MemberStore.dispose();
    await ItemStore.dispose();
    await Hive.box<String>('app_config').delete('team');

    const boxes = [
      'members',
      'members_active',
      'items',
      'items_active',
      'sales',
    ];

    for (final name in boxes) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).close();
      }
      await Hive.deleteBoxFromDisk(name);
    }

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TeamLoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7), // ✅ ホームと統一
      appBar: AppBar(
        backgroundColor: Colors.white, // ✅ フラット
        elevation: 0, // ✅ 影を消して上質に
        title: const Text(
          'その他',
          style: TextStyle(
            color: Colors.black87, // ✅ 黒を統一
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavCard(
            title: 'メンバー管理',
            subtitle: 'メンバーを追加・削除',
            icon: Icons.group_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageMembersScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _NavCard(
            title: '商品管理',
            subtitle: '販売で使う商品名を追加・削除',
            icon: Icons.shopping_bag_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageItemsScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _NavCard(
            title: 'ログアウト',
            subtitle: 'チームを切り替える',
            icon: Icons.logout,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF2F2F2), // ✅ ホームで使う淡いグレーと統一
                ),
                child: Icon(icon, size: 24, color: Colors.black87),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
