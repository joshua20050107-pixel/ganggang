import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/buyer_status.dart';
import '../data/sale_store.dart';

class SaleDetailSheet extends StatefulWidget {
  final Sale sale;
  const SaleDetailSheet({super.key, required this.sale});

  @override
  State<SaleDetailSheet> createState() => _SaleDetailSheetState();
}

class _SaleDetailSheetState extends State<SaleDetailSheet> {
  void _toggleBuyer(BuyerStatus buyer) async {
    setState(() {
      buyer.isPaid = !buyer.isPaid;
      widget.sale.isPaid = widget.sale.buyers.every((b) => b.isPaid);
    });
    await SaleStore.updateSale(widget.sale);
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    final formattedDate = DateFormat('yyyy/MM/dd').format(sale.date);

    return Dialog(
      backgroundColor: Colors.white, // ← 追加
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 160),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル & 閉じる
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "販売詳細",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.black38),
            ),
            const SizedBox(height: 20),

            Text(
              sale.sellerName.isEmpty ? '—' : sale.sellerName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),

            const Text(
              "商品名",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              sale.itemName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            const Text(
              "値段",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              "¥${sale.total}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            const Text(
              "場所",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              sale.location.isEmpty ? "—" : sale.location,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 22),

            const Divider(height: 1, thickness: 1.2),
            const SizedBox(height: 18),

            const Text(
              "買った人",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            Column(
              children: sale.buyers.map((buyer) {
                final paid = buyer.isPaid;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        buyer.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _toggleBuyer(buyer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: paid
                                ? Colors.greenAccent.shade100
                                : Colors.redAccent.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            paid ? "完了 ✅" : "未払い",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: paid
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
