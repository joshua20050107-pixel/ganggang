import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../screens/sale_detail_sheet.dart';

import '../models/sale.dart';
import '../widgets/add_sale_modal.dart';
import '../widgets/sale_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Sale> _saleBox;
  DateTime _selectedDay = DateTime.now();

  String? _showDeleteForId; // ← 今×が出ているカードのID

  @override
  void initState() {
    super.initState();
    _saleBox = Hive.box<Sale>('sales');
  }

  List<Sale> _filteredSales() {
    final sales = _saleBox.values.toList();
    return sales
        .where(
          (s) =>
              s.date.year == _selectedDay.year &&
              s.date.month == _selectedDay.month &&
              s.date.day == _selectedDay.day,
        )
        .toList();
  }

  void _changeDay(int offset) {
    setState(() {
      _selectedDay = _selectedDay.add(Duration(days: offset));
    });
  }

  int _totalSales(List<Sale> sales) {
    return sales.fold(0, (sum, s) => sum + s.total);
  }

  @override
  Widget build(BuildContext context) {
    final sales = _filteredSales();
    final total = _totalSales(sales);
    final formattedDate = DateFormat('yyyy/MM/dd').format(_selectedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const AddSaleModal(),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_showDeleteForId != null) {
            setState(() => _showDeleteForId = null);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 26),
                    onPressed: () => _changeDay(-1),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 26),
                    onPressed: () => _changeDay(1),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                '今日の売上',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              Column(
                children: [
                  Text(
                    '¥${NumberFormat('#,###').format(total)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 60),
                    height: 1,
                    color: Colors.black12,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _saleBox.listenable(),
                  builder: (context, Box<Sale> box, _) {
                    final sales = _filteredSales();
                    if (sales.isEmpty) {
                      return const Center(child: Text('まだ売上はありません'));
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (_showDeleteForId != null) {
                          setState(() => _showDeleteForId = null);
                        }
                        return false; // ← スクロール自体はそのまま通す
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 80,
                          left: 14,
                          right: 14,
                          top: 4,
                        ),
                        itemCount: sales.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.824,
                            ),
                        itemBuilder: (context, index) {
                          final sale = sales[index];
                          return SaleCard(
                            sale: sale,
                            showDelete: _showDeleteForId == sale.id,
                            onTap: () {
                              if (_showDeleteForId != null) {
                                setState(() => _showDeleteForId = null);
                                return;
                              }
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (_) => SaleDetailSheet(sale: sale),
                              );
                            },
                            onLongPress: () {
                              setState(() => _showDeleteForId = sale.id);
                            },
                            onDelete: () {
                              sale.delete();
                              setState(() => _showDeleteForId = null);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
