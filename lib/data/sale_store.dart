import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sale.dart';
import '../models/buyer_status.dart';

class SaleStore {
  static Box<Sale> get _box => Hive.box<Sale>('sales');

  /// 売上を追加
  static Future<void> addSale({
    required DateTime date, // ★ 追加（← これ大事）
    required String location,
    required String itemName,
    required int itemPrice,
    required List<String> buyers,
    required String sellerName,
    String? note,
  }) async {
    // 買った人リスト → BuyerStatusへ変換
    final buyerStatuses = buyers
        .map((name) => BuyerStatus(name: name, isPaid: false))
        .toList();

    final sale = Sale(
      id: const Uuid().v4(),
      date: date, // ★ DateTime.now() をやめてこれを使う
      location: location,
      itemName: itemName,
      itemPrice: itemPrice,
      buyers: buyerStatuses,
      isPaid: false,
      sellerName: sellerName,
      note: note,
    );

    await _box.add(sale);
  }
}
