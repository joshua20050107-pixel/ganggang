import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sale.dart';
import '../models/buyer_status.dart'; // ★ 追加

class SaleStore {
  static Box<Sale> get _box => Hive.box<Sale>('sales');

  /// 売上を追加
  static Future<void> addSale({
    required String location,
    required String itemName,
    required int itemPrice,
    required List<String> buyers, // 名前リストで受け取るのはこのままでOK
    required String sellerName,
    String? note,
  }) async {
    // ★ buyers を BuyerStatus に変換する
    final buyerStatuses = buyers
        .map((name) => BuyerStatus(name: name, isPaid: false))
        .toList();

    final sale = Sale(
      id: const Uuid().v4(),
      date: DateTime.now(),
      location: location,
      itemName: itemName,
      itemPrice: itemPrice,
      buyers: buyerStatuses, // ← 修正ここ
      isPaid: false,
      sellerName: sellerName,
      note: note,
    );

    await _box.add(sale);
  }
}
