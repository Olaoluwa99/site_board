import 'package:hive/hive.dart';

part 'sync_status.g.dart';

@HiveType(typeId: 20) // Ensure this ID is unique
enum SyncStatus {
  @HiveField(0)
  synced,
  @HiveField(1)
  created,
  @HiveField(2)
  updated,
  @HiveField(3)
  deleted,
}
