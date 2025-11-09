import 'package:hive/hive.dart';

part 'buyer_status.g.dart';

@HiveType(typeId: 1) // ← Sale と被らなければOK
class BuyerStatus {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isPaid;

  BuyerStatus({required this.name, this.isPaid = false});
}
