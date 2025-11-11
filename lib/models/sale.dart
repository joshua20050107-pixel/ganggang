import 'package:hive/hive.dart';
import 'buyer_status.dart';

part 'sale.g.dart';

@HiveType(typeId: 0)
class Sale extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String location;

  @HiveField(3)
  String itemName;

  @HiveField(4)
  int itemPrice;

  @HiveField(6)
  List<BuyerStatus> buyers;

  @HiveField(7)
  bool isPaid;

  @HiveField(8)
  String sellerName;

  @HiveField(9)
  String? note;

  Sale({
    required this.id,
    required this.date,
    required this.location,
    required this.itemName,
    required this.itemPrice,
    required this.buyers,
    required this.isPaid,
    required this.sellerName,
    this.note,
  });

  int get total => itemPrice;

  bool get allPaid => buyers.every((b) => b.isPaid);
}
