import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sale.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late Box<Sale> _saleBox;

  String? _selectedItem;
  String? _selectedSeller;

  // 今見ている月
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _saleBox = Hive.box<Sale>('sales');
  }

  // 指定月のデータ
  List<Sale> _salesOfMonth(DateTime month) {
    return _saleBox.values
        .where((s) => s.date.year == month.year && s.date.month == month.month)
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

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
      );
      // 月を変えた時、存在しない選択はクリア
      final sales = _salesOfMonth(_currentMonth);
      final itemsInMonth = sales.map((s) => s.itemName).toSet();
      final sellersInMonth = sales.map((s) => s.sellerName).toSet();
      if (_selectedItem != null && !itemsInMonth.contains(_selectedItem)) {
        _selectedItem = null;
      }
      if (_selectedSeller != null &&
          !sellersInMonth.contains(_selectedSeller)) {
        _selectedSeller = null;
      }
    });
  }

  Future<void> _pickMonth() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale("ja", "JP"),
      helpText: "月を選択",
    );

    if (result != null) {
      setState(() {
        _currentMonth = DateTime(result.year, result.month);
        // 月変更時の整合
        final sales = _salesOfMonth(_currentMonth);
        final itemsInMonth = sales.map((s) => s.itemName).toSet();
        final sellersInMonth = sales.map((s) => s.sellerName).toSet();
        if (_selectedItem != null && !itemsInMonth.contains(_selectedItem)) {
          _selectedItem = null;
        }
        if (_selectedSeller != null &&
            !sellersInMonth.contains(_selectedSeller)) {
          _selectedSeller = null;
        }
      });
    }
  }

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
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12),
                ],
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

    if (result == null) return;
    onSelected(result == "_clear" ? null : result);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _saleBox.listenable(),
      builder: (_, __, ___) {
        // まず当月売上を取得
        List<Sale> sales = _salesOfMonth(_currentMonth);

        // フィルター候補は「当月に登場したもののみ」
        final itemsInMonth = sales.map((s) => s.itemName).toSet().toList()
          ..sort();
        final sellersInMonth = sales.map((s) => s.sellerName).toSet().toList()
          ..sort();

        // 選択されたフィルターを適用
        if (_selectedSeller != null) {
          sales = sales.where((s) => s.sellerName == _selectedSeller).toList();
        }
        if (_selectedItem != null) {
          sales = sales.where((s) => s.itemName == _selectedItem).toList();
        }

        final total = _total(sales);

        // グラフのグルーピング：
        // ・商品を選んでいる → 売った人別
        // ・それ以外 → 商品別
        final Map<String, int> grouped =
            (_selectedItem != null && _selectedSeller == null)
            ? _sumBySeller(sales)
            : _sumByItem(sales);

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
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // 月の切り替え
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 26),
                      onPressed: () => _changeMonth(-1),
                    ),
                    GestureDetector(
                      onTap: _pickMonth,
                      child: Text(
                        "${_currentMonth.year}/${_currentMonth.month.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 26),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _filterButton(
                      label: _selectedItem ?? "商品▼",
                      onTap: () => _showFilterSheet(
                        items: itemsInMonth,
                        title: "商品で絞り込む",
                        onSelected: (v) => setState(() => _selectedItem = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _filterButton(
                      label: _selectedSeller ?? "人▼",
                      onTap: () => _showFilterSheet(
                        items: sellersInMonth,
                        title: "人で絞り込む",
                        onSelected: (v) => setState(() => _selectedSeller = v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

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
                            children: entries
                                .map(
                                  (e) => Padding(
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
                                  ),
                                )
                                .toList(),
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
