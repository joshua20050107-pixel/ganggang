import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../screens/sale_detail_sheet.dart';
import '../models/sale.dart';
import '../widgets/add_sale_modal.dart';
import '../widgets/sale_card.dart';
import '../data/sale_store.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<DateTime> selectedDate;
  const HomeScreen({super.key, required this.selectedDate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _showDeleteForId;

  List<Sale> _filteredSales(DateTime day) {
    final box = Hive.box<Sale>('sales');
    return box.values
        .where(
          (s) =>
              s.date.year == day.year &&
              s.date.month == day.month &&
              s.date.day == day.day,
        )
        .toList();
  }

  void _changeDay(int offset) {
    widget.selectedDate.value = widget.selectedDate.value.add(
      Duration(days: offset),
    );
  }

  int _totalSales(List<Sale> sales) {
    return sales.fold(0, (sum, s) => sum + s.total);
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('sales')) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ValueListenableBuilder(
      valueListenable: widget.selectedDate,
      builder: (_, DateTime selectedDay, __) {
        return ValueListenableBuilder(
          valueListenable: Hive.box<Sale>('sales').listenable(),
          builder: (_, __, ___) {
            final sales = _filteredSales(selectedDay);
            final total = _totalSales(sales);
            final formattedDate = DateFormat('yyyy/MM/dd').format(selectedDay);

            return Scaffold(
              backgroundColor: const Color(0xFFF6F6F7),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 40), // ← ここ好きな数値に
                child: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => AddSaleModal(selectedDate: selectedDay),
                    );
                  },
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),

              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: SafeArea(
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
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '¥${NumberFormat('#,###').format(total)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      height: 1,
                      color: Colors.black12,
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showDeleteForId = null),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (_) {
                            if (_showDeleteForId != null) {
                              setState(() => _showDeleteForId = null);
                            }
                            return false;
                          },
                          child: sales.isEmpty
                              ? const Center(child: Text('まだ売上はありません'))
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    4,
                                    14,
                                    80,
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
                                          setState(
                                            () => _showDeleteForId = null,
                                          );
                                          return;
                                        }
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) =>
                                              SaleDetailSheet(sale: sale),
                                        );
                                      },
                                      onLongPress: () => setState(
                                        () => _showDeleteForId = sale.id,
                                      ),
                                      onDelete: () async {
                                        await SaleStore.deleteSale(sale.id);
                                        if (!mounted) return;
                                        setState(() => _showDeleteForId = null);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
