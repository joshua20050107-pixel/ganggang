import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 10)
class Item extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isActive;

  Item({required this.name, this.isActive = true});
}
