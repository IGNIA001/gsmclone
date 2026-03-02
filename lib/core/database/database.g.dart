// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cpuScoreMeta =
      const VerificationMeta('cpuScore');
  @override
  late final GeneratedColumn<int> cpuScore = GeneratedColumn<int>(
      'cpu_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _gpuScoreMeta =
      const VerificationMeta('gpuScore');
  @override
  late final GeneratedColumn<int> gpuScore = GeneratedColumn<int>(
      'gpu_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _cameraScoreMeta =
      const VerificationMeta('cameraScore');
  @override
  late final GeneratedColumn<int> cameraScore = GeneratedColumn<int>(
      'camera_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _softwareScoreMeta =
      const VerificationMeta('softwareScore');
  @override
  late final GeneratedColumn<int> softwareScore = GeneratedColumn<int>(
      'software_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        brand,
        cpuScore,
        gpuScore,
        cameraScore,
        softwareScore,
        price,
        imageUrl,
        isFavorite
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('cpu_score')) {
      context.handle(_cpuScoreMeta,
          cpuScore.isAcceptableOrUnknown(data['cpu_score']!, _cpuScoreMeta));
    }
    if (data.containsKey('gpu_score')) {
      context.handle(_gpuScoreMeta,
          gpuScore.isAcceptableOrUnknown(data['gpu_score']!, _gpuScoreMeta));
    }
    if (data.containsKey('camera_score')) {
      context.handle(
          _cameraScoreMeta,
          cameraScore.isAcceptableOrUnknown(
              data['camera_score']!, _cameraScoreMeta));
    }
    if (data.containsKey('software_score')) {
      context.handle(
          _softwareScoreMeta,
          softwareScore.isAcceptableOrUnknown(
              data['software_score']!, _softwareScoreMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      cpuScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cpu_score'])!,
      gpuScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gpu_score'])!,
      cameraScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}camera_score'])!,
      softwareScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}software_score'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final int id;
  final String name;
  final String brand;
  final int cpuScore;
  final int gpuScore;
  final int cameraScore;
  final int softwareScore;
  final double price;
  final String? imageUrl;
  final bool isFavorite;
  const Device(
      {required this.id,
      required this.name,
      required this.brand,
      required this.cpuScore,
      required this.gpuScore,
      required this.cameraScore,
      required this.softwareScore,
      required this.price,
      this.imageUrl,
      required this.isFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['brand'] = Variable<String>(brand);
    map['cpu_score'] = Variable<int>(cpuScore);
    map['gpu_score'] = Variable<int>(gpuScore);
    map['camera_score'] = Variable<int>(cameraScore);
    map['software_score'] = Variable<int>(softwareScore);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      brand: Value(brand),
      cpuScore: Value(cpuScore),
      gpuScore: Value(gpuScore),
      cameraScore: Value(cameraScore),
      softwareScore: Value(softwareScore),
      price: Value(price),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      isFavorite: Value(isFavorite),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String>(json['brand']),
      cpuScore: serializer.fromJson<int>(json['cpuScore']),
      gpuScore: serializer.fromJson<int>(json['gpuScore']),
      cameraScore: serializer.fromJson<int>(json['cameraScore']),
      softwareScore: serializer.fromJson<int>(json['softwareScore']),
      price: serializer.fromJson<double>(json['price']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String>(brand),
      'cpuScore': serializer.toJson<int>(cpuScore),
      'gpuScore': serializer.toJson<int>(gpuScore),
      'cameraScore': serializer.toJson<int>(cameraScore),
      'softwareScore': serializer.toJson<int>(softwareScore),
      'price': serializer.toJson<double>(price),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  Device copyWith(
          {int? id,
          String? name,
          String? brand,
          int? cpuScore,
          int? gpuScore,
          int? cameraScore,
          int? softwareScore,
          double? price,
          Value<String?> imageUrl = const Value.absent(),
          bool? isFavorite}) =>
      Device(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        cpuScore: cpuScore ?? this.cpuScore,
        gpuScore: gpuScore ?? this.gpuScore,
        cameraScore: cameraScore ?? this.cameraScore,
        softwareScore: softwareScore ?? this.softwareScore,
        price: price ?? this.price,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        isFavorite: isFavorite ?? this.isFavorite,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      cpuScore: data.cpuScore.present ? data.cpuScore.value : this.cpuScore,
      gpuScore: data.gpuScore.present ? data.gpuScore.value : this.gpuScore,
      cameraScore:
          data.cameraScore.present ? data.cameraScore.value : this.cameraScore,
      softwareScore: data.softwareScore.present
          ? data.softwareScore.value
          : this.softwareScore,
      price: data.price.present ? data.price.value : this.price,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('cpuScore: $cpuScore, ')
          ..write('gpuScore: $gpuScore, ')
          ..write('cameraScore: $cameraScore, ')
          ..write('softwareScore: $softwareScore, ')
          ..write('price: $price, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, brand, cpuScore, gpuScore,
      cameraScore, softwareScore, price, imageUrl, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.cpuScore == this.cpuScore &&
          other.gpuScore == this.gpuScore &&
          other.cameraScore == this.cameraScore &&
          other.softwareScore == this.softwareScore &&
          other.price == this.price &&
          other.imageUrl == this.imageUrl &&
          other.isFavorite == this.isFavorite);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> brand;
  final Value<int> cpuScore;
  final Value<int> gpuScore;
  final Value<int> cameraScore;
  final Value<int> softwareScore;
  final Value<double> price;
  final Value<String?> imageUrl;
  final Value<bool> isFavorite;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.cpuScore = const Value.absent(),
    this.gpuScore = const Value.absent(),
    this.cameraScore = const Value.absent(),
    this.softwareScore = const Value.absent(),
    this.price = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String brand,
    this.cpuScore = const Value.absent(),
    this.gpuScore = const Value.absent(),
    this.cameraScore = const Value.absent(),
    this.softwareScore = const Value.absent(),
    this.price = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
  })  : name = Value(name),
        brand = Value(brand);
  static Insertable<Device> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<int>? cpuScore,
    Expression<int>? gpuScore,
    Expression<int>? cameraScore,
    Expression<int>? softwareScore,
    Expression<double>? price,
    Expression<String>? imageUrl,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (cpuScore != null) 'cpu_score': cpuScore,
      if (gpuScore != null) 'gpu_score': gpuScore,
      if (cameraScore != null) 'camera_score': cameraScore,
      if (softwareScore != null) 'software_score': softwareScore,
      if (price != null) 'price': price,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  DevicesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? brand,
      Value<int>? cpuScore,
      Value<int>? gpuScore,
      Value<int>? cameraScore,
      Value<int>? softwareScore,
      Value<double>? price,
      Value<String?>? imageUrl,
      Value<bool>? isFavorite}) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      cpuScore: cpuScore ?? this.cpuScore,
      gpuScore: gpuScore ?? this.gpuScore,
      cameraScore: cameraScore ?? this.cameraScore,
      softwareScore: softwareScore ?? this.softwareScore,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (cpuScore.present) {
      map['cpu_score'] = Variable<int>(cpuScore.value);
    }
    if (gpuScore.present) {
      map['gpu_score'] = Variable<int>(gpuScore.value);
    }
    if (cameraScore.present) {
      map['camera_score'] = Variable<int>(cameraScore.value);
    }
    if (softwareScore.present) {
      map['software_score'] = Variable<int>(softwareScore.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('cpuScore: $cpuScore, ')
          ..write('gpuScore: $gpuScore, ')
          ..write('cameraScore: $cameraScore, ')
          ..write('softwareScore: $softwareScore, ')
          ..write('price: $price, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [devices];
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  required String name,
  required String brand,
  Value<int> cpuScore,
  Value<int> gpuScore,
  Value<int> cameraScore,
  Value<int> softwareScore,
  Value<double> price,
  Value<String?> imageUrl,
  Value<bool> isFavorite,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> brand,
  Value<int> cpuScore,
  Value<int> gpuScore,
  Value<int> cameraScore,
  Value<int> softwareScore,
  Value<double> price,
  Value<String?> imageUrl,
  Value<bool> isFavorite,
});

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cpuScore => $composableBuilder(
      column: $table.cpuScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gpuScore => $composableBuilder(
      column: $table.gpuScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cameraScore => $composableBuilder(
      column: $table.cameraScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get softwareScore => $composableBuilder(
      column: $table.softwareScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cpuScore => $composableBuilder(
      column: $table.cpuScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gpuScore => $composableBuilder(
      column: $table.gpuScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cameraScore => $composableBuilder(
      column: $table.cameraScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get softwareScore => $composableBuilder(
      column: $table.softwareScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<int> get cpuScore =>
      $composableBuilder(column: $table.cpuScore, builder: (column) => column);

  GeneratedColumn<int> get gpuScore =>
      $composableBuilder(column: $table.gpuScore, builder: (column) => column);

  GeneratedColumn<int> get cameraScore => $composableBuilder(
      column: $table.cameraScore, builder: (column) => column);

  GeneratedColumn<int> get softwareScore => $composableBuilder(
      column: $table.softwareScore, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<int> cpuScore = const Value.absent(),
            Value<int> gpuScore = const Value.absent(),
            Value<int> cameraScore = const Value.absent(),
            Value<int> softwareScore = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            name: name,
            brand: brand,
            cpuScore: cpuScore,
            gpuScore: gpuScore,
            cameraScore: cameraScore,
            softwareScore: softwareScore,
            price: price,
            imageUrl: imageUrl,
            isFavorite: isFavorite,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String brand,
            Value<int> cpuScore = const Value.absent(),
            Value<int> gpuScore = const Value.absent(),
            Value<int> cameraScore = const Value.absent(),
            Value<int> softwareScore = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            name: name,
            brand: brand,
            cpuScore: cpuScore,
            gpuScore: gpuScore,
            cameraScore: cameraScore,
            softwareScore: softwareScore,
            price: price,
            imageUrl: imageUrl,
            isFavorite: isFavorite,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
}
