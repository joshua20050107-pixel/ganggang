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
  String _filter = '総額';

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

  int _totalAmount(List<Sale> sales) =>
      sales.fold(0, (sum, s) => sum + s.total);

  int _paidCount(List<Sale> sales) => sales.where((s) => s.isPaid).length;

  int _unpaidCount(List<Sale> sales) => sales.where((s) => !s.isPaid).length;

  Map<String, int> _groupByItem(List<Sale> sales) {
    final map = <String, int>{};
    for (final sale in sales) {
      map[sale.itemName] = (map[sale.itemName] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> _groupBySeller(List<Sale> sales) {
    final map = <String, int>{};
    for (final sale in sales) {
      map[sale.sellerName] = (map[sale.sellerName] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '月の売上',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: _saleBox.listenable(),
        builder: (context, Box<Sale> box, _) {
          final sales = _thisMonthSales();
          if (sales.isEmpty) {
            return const Center(child: Text('今月の売上データがありません'));
          }

          final total = _totalAmount(sales);
          final paid = _paidCount(sales);
          final unpaid = _unpaidCount(sales);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  '¥${NumberFormat('#,###').format(total)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '完了: $paid件　未払い: $unpaid件',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: paid.toDouble(),
                          color: Colors.greenAccent,
                          title: '完了',
                          titleStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        PieChartSectionData(
                          value: unpaid.toDouble(),
                          color: Colors.redAccent,
                          title: '未払い',
                          titleStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filter,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: '総額', child: Text('総額で表示')),
                        DropdownMenuItem(value: '商品別', child: Text('商品別で表示')),
                        DropdownMenuItem(
                          value: '売った人別',
                          child: Text('売った人別で表示'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _filter = value!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_filter == '総額')
                  Text(
                    '今月の総売上は ¥${NumberFormat('#,###').format(total)} です。',
                    style: const TextStyle(fontSize: 16),
                  ),
                if (_filter == '商品別')
                  _buildGroupedList(_groupByItem(sales), '商品'),
                if (_filter == '売った人別')
                  _buildGroupedList(_groupBySeller(sales), '売った人'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupedList(Map<String, int> data, String label) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$labelごとの件数',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...entries.map((e) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${e.value}件',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
