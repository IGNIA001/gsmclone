import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get brand => text()();
  IntColumn get cpuScore => integer().withDefault(const Constant(0))();
  IntColumn get gpuScore => integer().withDefault(const Constant(0))();
  IntColumn get cameraScore => integer().withDefault(const Constant(0))();
  IntColumn get softwareScore => integer().withDefault(const Constant(0))();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Devices])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(DatabaseConnection connection) : super(connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.deleteTable('devices');
        await m.createTable(devices);
        await m.addColumn(devices, devices.cameraScore);
        await m.addColumn(devices, devices.softwareScore);
        await m.addColumn(devices, devices.price);
        await m.addColumn(devices, devices.imageUrl);
        await m.addColumn(devices, devices.gpuScore);
      }
    },
  );

  // ── Queries ──────────────────────────────────────────────────────────────

  Future<String> getFavoritesAsText() async {
    final list = await (select(devices)
      ..where((t) => t.isFavorite.equals(true)))
        .get();
    if (list.isEmpty) return 'No favorites saved yet.';
    return list
        .map((e) => '• ${e.brand} ${e.name} (₹${e.price.round()})')
        .join('\n');
  }

  Stream<List<Device>> watchFilteredDevices({
    required double minPrice,
    required double maxPrice,
    bool reqCamera = false,
    bool reqPerformance = false,
    bool reqSoftware = false,
  }) {
    return (select(devices)
      ..where((t) {
        Expression<bool> predicate =
        t.price.isBetweenValues(minPrice, maxPrice);
        if (reqCamera) predicate &= t.cameraScore.isBiggerThanValue(80);
        if (reqPerformance) predicate &= t.cpuScore.isBiggerThanValue(80);
        if (reqSoftware) predicate &= t.softwareScore.isBiggerThanValue(80);
        return predicate;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.cpuScore)]))
        .watch();
  }

  Future<void> upsertDevice(DevicesCompanion entity) async {
    await into(devices).insertOnConflictUpdate(entity);
  }

  Future toggleFavorite(int id, bool currentStatus) {
    return (update(devices)..where((t) => t.id.equals(id)))
        .write(DevicesCompanion(isFavorite: Value(!currentStatus)));
  }

  Stream<List<Device>> watchAllDevices() => (select(devices)
    ..orderBy([(t) => OrderingTerm.desc(t.cpuScore)]))
      .watch();

  // ── Seed ─────────────────────────────────────────────────────────────────

  Future<void> seedDatabase() async {
    final count = await select(devices).get();
    if (count.length >= 10) return;

    final seedData = [
      // ── Samsung ──────────────────────────────────────────────────────────
      _d('Samsung', 'Galaxy S24 Ultra',
          cpu: 95, gpu: 93, cam: 98, soft: 80, price: 134999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24-ultra-5g.jpg'),
      _d('Samsung', 'Galaxy S24+',
          cpu: 93, gpu: 91, cam: 90, soft: 80, price: 99999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24-plus-5g.jpg'),
      _d('Samsung', 'Galaxy S24',
          cpu: 91, gpu: 89, cam: 87, soft: 80, price: 79999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24-5g.jpg'),
      _d('Samsung', 'Galaxy A55 5G',
          cpu: 72, gpu: 68, cam: 78, soft: 82, price: 38999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a55.jpg'),
      _d('Samsung', 'Galaxy A35 5G',
          cpu: 68, gpu: 64, cam: 74, soft: 80, price: 26999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a35.jpg'),
      _d('Samsung', 'Galaxy M55 5G',
          cpu: 74, gpu: 70, cam: 76, soft: 78, price: 29999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-m55.jpg'),

      // ── Apple ─────────────────────────────────────────────────────────────
      _d('Apple', 'iPhone 16 Pro Max',
          cpu: 99, gpu: 98, cam: 97, soft: 95, price: 159900,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro-max.jpg'),
      _d('Apple', 'iPhone 16 Pro',
          cpu: 98, gpu: 97, cam: 96, soft: 94, price: 134900,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro.jpg'),
      _d('Apple', 'iPhone 16',
          cpu: 96, gpu: 94, cam: 90, soft: 93, price: 89900,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16.jpg'),
      _d('Apple', 'iPhone 15',
          cpu: 92, gpu: 90, cam: 88, soft: 92, price: 69900,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15.jpg'),
      _d('Apple', 'iPhone 14',
          cpu: 88, gpu: 86, cam: 84, soft: 91, price: 56900,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-14.jpg'),

      // ── OnePlus ───────────────────────────────────────────────────────────
      _d('OnePlus', '13',
          cpu: 94, gpu: 92, cam: 85, soft: 85, price: 69999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-13.jpg'),
      _d('OnePlus', '12',
          cpu: 91, gpu: 89, cam: 83, soft: 84, price: 64999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-12.jpg'),
      _d('OnePlus', 'Nord 4',
          cpu: 78, gpu: 75, cam: 74, soft: 83, price: 29999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-nord-4.jpg'),
      _d('OnePlus', 'Nord CE 4',
          cpu: 72, gpu: 68, cam: 70, soft: 82, price: 24999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-nord-ce4.jpg'),

      // ── Google ────────────────────────────────────────────────────────────
      _d('Google', 'Pixel 9 Pro XL',
          cpu: 93, gpu: 88, cam: 99, soft: 97, price: 109999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-9-pro-xl.jpg'),
      _d('Google', 'Pixel 9 Pro',
          cpu: 92, gpu: 87, cam: 98, soft: 97, price: 99999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-9-pro.jpg'),
      _d('Google', 'Pixel 9',
          cpu: 90, gpu: 85, cam: 95, soft: 96, price: 79999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-9.jpg'),
      _d('Google', 'Pixel 8a',
          cpu: 85, gpu: 80, cam: 90, soft: 95, price: 52999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8a.jpg'),

      // ── Xiaomi ────────────────────────────────────────────────────────────
      _d('Xiaomi', '14 Ultra',
          cpu: 95, gpu: 93, cam: 97, soft: 76, price: 99999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14-ultra.jpg'),
      _d('Xiaomi', '14',
          cpu: 94, gpu: 91, cam: 92, soft: 75, price: 69999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14.jpg'),
      _d('Xiaomi', 'Redmi Note 13 Pro+',
          cpu: 76, gpu: 72, cam: 80, soft: 74, price: 31999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-note-13-pro-plus.jpg'),
      _d('Xiaomi', 'Redmi Note 13 Pro',
          cpu: 73, gpu: 69, cam: 77, soft: 73, price: 23999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-note-13-pro.jpg'),
      _d('Xiaomi', 'Redmi 13C',
          cpu: 55, gpu: 50, cam: 58, soft: 70, price: 10999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-13c.jpg'),

      // ── Realme ────────────────────────────────────────────────────────────
      _d('Realme', 'GT 6',
          cpu: 90, gpu: 87, cam: 82, soft: 75, price: 47999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/realme-gt-6.jpg'),
      _d('Realme', 'Narzo 70 Pro',
          cpu: 70, gpu: 66, cam: 72, soft: 73, price: 19999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/realme-narzo-70-pro.jpg'),
      _d('Realme', 'C67',
          cpu: 58, gpu: 54, cam: 62, soft: 71, price: 13999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/realme-c67.jpg'),

      // ── iQOO ──────────────────────────────────────────────────────────────
      _d('iQOO', '12',
          cpu: 95, gpu: 94, cam: 84, soft: 77, price: 52999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/vivo-iqoo-12.jpg'),
      _d('iQOO', 'Neo 9 Pro',
          cpu: 88, gpu: 85, cam: 80, soft: 76, price: 36999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/vivo-iqoo-neo9-pro.jpg'),
      _d('iQOO', 'Z9',
          cpu: 75, gpu: 71, cam: 73, soft: 75, price: 22999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/vivo-iqoo-z9.jpg'),

      // ── Nothing ───────────────────────────────────────────────────────────
      _d('Nothing', 'Phone (2a)',
          cpu: 74, gpu: 70, cam: 75, soft: 88, price: 23999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2a.jpg'),
      _d('Nothing', 'Phone (2)',
          cpu: 82, gpu: 78, cam: 78, soft: 90, price: 44999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2.jpg'),

      // ── Motorola ──────────────────────────────────────────────────────────
      _d('Motorola', 'Edge 50 Pro',
          cpu: 80, gpu: 77, cam: 82, soft: 92, price: 31999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-pro.jpg'),
      _d('Motorola', 'G84',
          cpu: 68, gpu: 64, cam: 68, soft: 90, price: 17999,
          img: 'https://fdn2.gsmarena.com/vv/bigpic/motorola-moto-g84.jpg'),
    ];

    for (final entry in seedData) {
      await upsertDevice(entry);
    }
  }

  /// Helper to build a DevicesCompanion cleanly
  DevicesCompanion _d(
      String brand,
      String name, {
        required int cpu,
        required int gpu,
        required int cam,
        required int soft,
        required double price,
        String? img,
      }) {
    return DevicesCompanion.insert(
      brand: brand,
      name: name,
      cpuScore: Value(cpu),
      gpuScore: Value(gpu),
      cameraScore: Value(cam),
      softwareScore: Value(soft),
      price: Value(price),
      imageUrl: Value(img),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}