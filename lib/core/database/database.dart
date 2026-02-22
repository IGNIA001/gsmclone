import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

// 1. Table definition
class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get brand => text()();
  IntColumn get cpuScore => integer()();
  IntColumn get gpuScore => integer()();
  // We use this to allow users to save items without a login
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Devices])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- HELPER METHODS ---

  // Stream for the UI: This makes the app "Live" (updates instantly)
  Stream<List<Device>> watchAllDevices() => select(devices).watch();

  // Toggle Favorite logic
  Future toggleFavorite(Device device) {
    return update(devices).replace(
      device.copyWith(isFavorite: !device.isFavorite),
    );
  }

  // EXPORT LOGIC: Converts local favorites to a text string for sharing
  Future<String> getFavoritesAsText() async {
    final list = await (select(devices)..where((t) => t.isFavorite.equals(true))).get();
    if (list.isEmpty) return "No favorites saved yet.";
    return list.map((e) => "• ${e.brand} ${e.name} (CPU: ${e.cpuScore}, GPU: ${e.gpuScore})").join("\n");
  }

  // MOCK DATA SEEDER: Adds initial phones so the app isn't blank
  Future<void> seedDatabase() async {
    final count = await select(devices).get();
    if (count.isEmpty) {
      await into(devices).insert(DevicesCompanion.insert(
        name: 'Galaxy S24 Ultra',
        brand: 'Samsung',
        cpuScore: 95,
        gpuScore: 92,
      ));
      await into(devices).insert(DevicesCompanion.insert(
        name: 'iPhone 15 Pro Max',
        brand: 'Apple',
        cpuScore: 98,
        gpuScore: 94,
      ));
      await into(devices).insert(DevicesCompanion.insert(
        name: 'Pixel 8 Pro',
        brand: 'Google',
        cpuScore: 88,
        gpuScore: 85,
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}