import 'package:hive_flutter/hive_flutter.dart';

part 'users_entity.g.dart';

@HiveType(typeId: 3)
class UserEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  UserEntity({required this.id, required this.name});
}
