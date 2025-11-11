import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';
import '../widgets/sale_card.dart';
import 'sale_detail_sheet.dart';

class UnpaidScreen extends StatefulWidget {
  const UnpaidScreen({super.key});

  @override
  State<UnpaidScreen> createState() => _UnpaidScreenState();
}

class _UnpaidScreenState extends State<UnpaidScreen> {
  late Box<Sale> _saleBox;
  String? _deleteId; // ← sale.id で追跡（安全）

  @override
  void initState() {
    super.initState();
    _saleBox = Hive.box<Sale>('sales');
  }

  List<Sale> _unpaidSales() {
    final sales = _saleBox.values.toList();
    return sales.where((s) => !s.isPaid).toList();
  }

  void _openDetail(Sale sale) {
    showDialog(
      context: context,
      builder: (_) => SaleDetailSheet(sale: sale),
    );
  }

  /// ✅ 安全な削除（ID ベース）
  void _deleteSale(Sale sale) {
    sale.delete();
    setState(() => _deleteId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '未払いリスト',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => setState(() => _deleteId = null),
        child: ValueListenableBuilder(
          valueListenable: _saleBox.listenable(),
          builder: (context, Box<Sale> box, _) {
            final unpaid = _unpaidSales();

            if (unpaid.isEmpty) {
              return const Center(
                child: Text(
                  '未払いの売上はありません',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return GridView.count(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
              children: unpaid.map((sale) {
                final showDelete = _deleteId == sale.id;

                return SaleCard(
                  sale: sale,
                  onTap: () => _openDetail(sale),
                  showDelete: showDelete,
                  onDelete: () => _deleteSale(sale),
                  onLongPress: () => setState(() => _deleteId = sale.id),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
