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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(devices, devices.cameraScore);
        await m.addColumn(devices, devices.softwareScore);
        await m.addColumn(devices, devices.price);
        await m.addColumn(devices, devices.imageUrl);
        await m.addColumn(devices, devices.gpuScore);
      }
      if (from < 4) {
        await m.deleteTable('devices');
        await m.createTable(devices);
      }
    },
  );

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
    await into(devices).insert(
      entity,
      onConflict: DoUpdate(
            (old) => entity,
        target: [devices.name],
      ),
    );
  }

  Future toggleFavorite(int id, bool currentStatus) {
    return (update(devices)..where((t) => t.id.equals(id)))
        .write(DevicesCompanion(isFavorite: Value(!currentStatus)));
  }

  Stream<List<Device>> watchAllDevices() =>
      (select(devices)
        ..orderBy([(t) => OrderingTerm.desc(t.cpuScore)]))
          .watch();

  Future<void> seedDatabase() async {
    final results = await select(devices).get();
    if (results.length >= 10) return;

    for (final d in _seed2025()) {
      await upsertDevice(d);
    }
  }

  List<DevicesCompanion> _seed2025() => [
    _d('Samsung', 'Galaxy S25 Ultra',
        cpu: 97, gpu: 96, cam: 99, soft: 82, price: 134999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s25-ultra.jpg'),
    _d('Samsung', 'Galaxy S25+',
        cpu: 95, gpu: 93, cam: 92, soft: 82, price: 99999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s25-plus.jpg'),
    _d('Samsung', 'Galaxy S25',
        cpu: 94, gpu: 91, cam: 89, soft: 82, price: 79999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s25.jpg'),
    _d('Samsung', 'Galaxy S25 Edge',
        cpu: 96, gpu: 94, cam: 91, soft: 82, price: 109999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s25-edge.jpg'),
    _d('Samsung', 'Galaxy A56 5G',
        cpu: 74, gpu: 70, cam: 80, soft: 83, price: 39999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a55.jpg'),
    _d('Samsung', 'Galaxy A36 5G',
        cpu: 70, gpu: 66, cam: 76, soft: 82, price: 27999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a35.jpg'),
    _d('Samsung', 'Galaxy M56 5G',
        cpu: 76, gpu: 72, cam: 78, soft: 80, price: 31999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-m55.jpg'),
    _d('Samsung', 'Galaxy Z Fold 7',
        cpu: 98, gpu: 96, cam: 93, soft: 83, price: 189999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-z-fold7.jpg'),
    _d('Samsung', 'Galaxy Z Flip 7',
        cpu: 96, gpu: 93, cam: 85, soft: 83, price: 109999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-z-flip7.jpg'),
    _d('Apple', 'iPhone 17 Pro Max',
        cpu: 99, gpu: 99, cam: 98, soft: 97, price: 169900,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-17-pro-max.jpg'),
    _d('Apple', 'iPhone 17 Pro',
        cpu: 99, gpu: 98, cam: 97, soft: 97, price: 144900,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-17-pro.jpg'),
    _d('Apple', 'iPhone 17',
        cpu: 97, gpu: 95, cam: 92, soft: 96, price: 89900,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-17.jpg'),
    _d('Apple', 'iPhone 17e',
        cpu: 91, gpu: 88, cam: 85, soft: 95, price: 59900,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16.jpg'),
    _d('Apple', 'iPhone 16 Pro Max',
        cpu: 96, gpu: 95, cam: 96, soft: 95, price: 134900,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro-max.jpg'),
    _d('Apple', 'iPhone 16 Pro',
        cpu: 95, gpu: 94, cam: 95, soft: 94, price: 114900,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro.jpg'),
    _d('Apple', 'iPhone 16',
        cpu: 93, gpu: 91, cam: 88, soft: 93, price: 74900,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16.jpg'),
    _d('Apple', 'iPhone 15',
        cpu: 89, gpu: 87, cam: 86, soft: 92, price: 59900,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15.jpg'),
    _d('OnePlus', '13T',
        cpu: 97, gpu: 95, cam: 87, soft: 86, price: 64999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-13.jpg'),
    _d('OnePlus', '13',
        cpu: 95, gpu: 93, cam: 86, soft: 86, price: 69999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-13.jpg'),
    _d('OnePlus', 'Nord 5',
        cpu: 80, gpu: 77, cam: 76, soft: 85, price: 32999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-nord-4.jpg'),
    _d('OnePlus', 'Nord CE 4 Lite',
        cpu: 68, gpu: 64, cam: 70, soft: 83, price: 19999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-nord-ce4.jpg'),
    _d('Google', 'Pixel 9 Pro XL',
        cpu: 94, gpu: 89, cam: 99, soft: 98, price: 109999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-9-pro-xl.jpg'),
    _d('Google', 'Pixel 9 Pro',
        cpu: 93, gpu: 88, cam: 98, soft: 98, price: 99999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-9-pro.jpg'),
    _d('Google', 'Pixel 9',
        cpu: 91, gpu: 86, cam: 96, soft: 97, price: 79999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-9.jpg'),
    _d('Google', 'Pixel 9a',
        cpu: 87, gpu: 82, cam: 92, soft: 97, price: 52999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8a.jpg'),
    _d('Xiaomi', '15 Ultra',
        cpu: 97, gpu: 96, cam: 99, soft: 77, price: 109999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14-ultra.jpg'),
    _d('Xiaomi', '15 Pro',
        cpu: 96, gpu: 94, cam: 95, soft: 77, price: 84999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14-ultra.jpg'),
    _d('Xiaomi', '15',
        cpu: 95, gpu: 92, cam: 93, soft: 76, price: 69999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14.jpg'),
    _d('Xiaomi', 'Redmi Note 14 Pro+',
        cpu: 78, gpu: 74, cam: 82, soft: 75, price: 33999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-note-13-pro-plus.jpg'),
    _d('Xiaomi', 'Redmi Note 14 Pro',
        cpu: 75, gpu: 71, cam: 79, soft: 74, price: 25999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-note-13-pro.jpg'),
    _d('Xiaomi', 'Redmi 14C',
        cpu: 57, gpu: 52, cam: 60, soft: 71, price: 11999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-13c.jpg'),
    _d('Xiaomi', 'POCO X7 Pro',
        cpu: 90, gpu: 88, cam: 82, soft: 74, price: 29999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14.jpg'),
    _d('Motorola', 'Signature',
        cpu: 97, gpu: 95, cam: 90, soft: 93, price: 89999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-ultra.jpg'),
    _d('Motorola', 'Edge 60 Pro',
        cpu: 86, gpu: 83, cam: 88, soft: 93, price: 44999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-pro.jpg'),
    _d('Motorola', 'Edge 60 Fusion',
        cpu: 79, gpu: 75, cam: 82, soft: 92, price: 29999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-pro.jpg'),
    _d('Motorola', 'G85 5G',
        cpu: 70, gpu: 66, cam: 70, soft: 91, price: 19999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/motorola-moto-g84.jpg'),
    _d('Motorola', 'G45 5G',
        cpu: 60, gpu: 56, cam: 62, soft: 90, price: 13999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/motorola-moto-g84.jpg'),
    _d('Realme', 'GT 7 Pro',
        cpu: 97, gpu: 95, cam: 87, soft: 77, price: 54999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/realme-gt-6.jpg'),
    _d('Realme', 'GT 7',
        cpu: 91, gpu: 88, cam: 83, soft: 76, price: 39999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/realme-gt-6.jpg'),
    _d('Realme', 'Narzo 80 Pro',
        cpu: 72, gpu: 68, cam: 74, soft: 74, price: 21999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/realme-narzo-70-pro.jpg'),
    _d('iQOO', '13',
        cpu: 97, gpu: 96, cam: 86, soft: 78, price: 59999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/vivo-iqoo-12.jpg'),
    _d('iQOO', 'Neo 10 Pro',
        cpu: 90, gpu: 88, cam: 82, soft: 78, price: 38999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/vivo-iqoo-neo9-pro.jpg'),
    _d('iQOO', 'Z9 Turbo+',
        cpu: 88, gpu: 85, cam: 76, soft: 76, price: 27999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/vivo-iqoo-z9.jpg'),
    _d('iQOO', 'Z9x',
        cpu: 70, gpu: 66, cam: 68, soft: 75, price: 17999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/vivo-iqoo-z9.jpg'),
    _d('Nothing', 'Phone (3)',
        cpu: 84, gpu: 80, cam: 80, soft: 92, price: 49999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2.jpg'),
    _d('Nothing', 'Phone (2a) Plus',
        cpu: 76, gpu: 72, cam: 77, soft: 90, price: 27999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2a.jpg'),
    _d('OPPO', 'Find X8 Pro',
        cpu: 97, gpu: 95, cam: 96, soft: 78, price: 99999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14-ultra.jpg'),
    _d('Vivo', 'X200 Pro',
        cpu: 97, gpu: 95, cam: 97, soft: 79, price: 94999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14-ultra.jpg'),
    _d('Infinix', 'Note 40 Pro+',
        cpu: 65, gpu: 61, cam: 68, soft: 72, price: 16999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/realme-c67.jpg'),
    _d('Tecno', 'Pova 6 Pro 5G',
        cpu: 62, gpu: 58, cam: 65, soft: 70, price: 14999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/realme-c67.jpg'),
    _d('Lava', 'Blaze Curve 5G',
        cpu: 58, gpu: 54, cam: 60, soft: 70, price: 12999,
        img: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-13c.jpg'),
  ];

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