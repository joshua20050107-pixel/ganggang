import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/buyer_status.dart';

class SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onTap;
  final bool showDelete;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  const SaleCard({
    super.key,
    required this.sale,
    required this.onTap,
    required this.showDelete,
    required this.onDelete,
    required this.onLongPress,
  });

  void _markPaid() {
    for (BuyerStatus b in sale.buyers) {
      b.isPaid = true;
    }
    sale.isPaid = true;
    sale.save();
  }

  void _undo() {
    for (BuyerStatus b in sale.buyers) {
      b.isPaid = false;
    }
    sale.isPaid = false;
    sale.save();
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = sale.isPaid;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // カード本体
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.itemName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                Text(
                  '¥${sale.total}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  sale.sellerName,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPaid ? "完了 ✅" : "未払い",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isPaid
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                      ),
                    ),

                    // ✅ 状態に応じてボタン切り替え
                    GestureDetector(
                      onTap: isPaid ? _undo : _markPaid,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.grey.shade300 : Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPaid ? "取消" : "完了",
                          style: TextStyle(
                            color: isPaid ? Colors.black87 : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🗑️ 削除ボタン
          if (showDelete)
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
