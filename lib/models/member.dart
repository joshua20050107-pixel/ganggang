import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 11)
class Member extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isActive;

  Member({required this.name, this.isActive = true});
}
