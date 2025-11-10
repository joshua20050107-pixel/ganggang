import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sale.dart';
import '../data/item_store.dart';
import '../data/member_store.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late Box<Sale> _saleBox;

  String? _selectedItem;
  String? _selectedSeller;

  @override
  void initState() {
    super.initState();
    _saleBox = Hive.box<Sale>('sales');
  }

  List<Sale> _thisMonthSales() {
    final now = DateTime.now();
    return _saleBox.values
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .toList();
  }

  int _total(List<Sale> sales) => sales.fold(0, (sum, s) => sum + s.total);

  Map<String, int> _sumByItem(List<Sale> sales) {
    final map = <String, int>{};
    for (final sale in sales) {
      map[sale.itemName] = (map[sale.itemName] ?? 0) + sale.total;
    }
    return map;
  }

  Map<String, int> _sumBySeller(List<Sale> sales) {
    final map = <String, int>{};
    for (final sale in sales) {
      map[sale.sellerName] = (map[sale.sellerName] ?? 0) + sale.total;
    }
    return map;
  }

  // ✅ 絞り込み選択UI（灰色 / 丸角 / カード風）
  Future<void> _showFilterSheet({
    required List<String> items,
    required ValueChanged<String?> onSelected,
    required String title,
  }) async {
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i in items)
                    ListTile(
                      title: Text(i),
                      onTap: () => Navigator.pop(context, i),
                    ),
                  const Divider(),
                  ListTile(
                    title: const Center(
                      child: Text(
                        "クリア",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    onTap: () => Navigator.pop(context, "_clear"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == null) return; // ← 外タップは何もしない（重要）

    if (result == "_clear") {
      onSelected(null);
    } else {
      onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _saleBox.listenable(),
      builder: (_, __, ___) {
        List<Sale> sales = _thisMonthSales();

        if (_selectedSeller != null) {
          sales = sales.where((s) => s.sellerName == _selectedSeller).toList();
        }
        if (_selectedItem != null) {
          sales = sales.where((s) => s.itemName == _selectedItem).toList();
        }

        final total = _total(sales);

        Map<String, int> grouped;
        if (_selectedItem != null && _selectedSeller == null) {
          grouped = _sumBySeller(sales);
        } else {
          grouped = _sumByItem(sales);
        }

        final entries = grouped.entries.toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F7),
          appBar: AppBar(
            title: const Text(
              "月の売上",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // 絞り込み UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _filterButton(
                      label: _selectedItem ?? "商品▼",
                      onTap: () => _showFilterSheet(
                        items: ItemStore.getActive(),
                        title: "商品で絞り込む",
                        onSelected: (v) => setState(() => _selectedItem = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _filterButton(
                      label: _selectedSeller ?? "人▼",
                      onTap: () => _showFilterSheet(
                        items: MemberStore.getActive(),
                        title: "人で絞り込む",
                        onSelected: (v) => setState(() => _selectedSeller = v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 総額
                Text(
                  "¥${NumberFormat('#,###').format(total)}",
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 26),

                if (entries.isEmpty)
                  const Expanded(child: Center(child: Text("データがありません")))
                else
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                              sections: [
                                for (int i = 0; i < entries.length; i++)
                                  PieChartSectionData(
                                    value: entries[i].value.toDouble(),
                                    color: Colors
                                        .primaries[i % Colors.primaries.length],
                                    title: entries[i].key,
                                    radius: 70,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: ListView(
                            children: entries.map((e) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      "¥${NumberFormat('#,###').format(e.value)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black26),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
