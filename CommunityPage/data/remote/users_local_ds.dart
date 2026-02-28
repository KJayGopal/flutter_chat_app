import 'package:hive_flutter/hive_flutter.dart';
import 'package:ui_demo/CommunityPage/data/local/users_entity.dart';

class UserLocalDataSource {
  final Box<UserEntity> box;
  UserLocalDataSource(this.box);

  UserEntity? getUser(String id) {
    return box.get(id);
  }

  Future<void> saveUsers(List<UserEntity> users) async {
    for (final u in users) {
      await box.put(u.id, u);
    }
  }
}
