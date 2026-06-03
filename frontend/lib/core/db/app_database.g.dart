// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehiclesCacheTable extends VehiclesCache
    with TableInfo<$VehiclesCacheTable, VehiclesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, lat, lng, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehiclesCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehiclesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehiclesCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $VehiclesCacheTable createAlias(String alias) {
    return $VehiclesCacheTable(attachedDatabase, alias);
  }
}

class VehiclesCacheData extends DataClass
    implements Insertable<VehiclesCacheData> {
  final String id;
  final String json;
  final double lat;
  final double lng;
  final int fetchedAt;
  const VehiclesCacheData({
    required this.id,
    required this.json,
    required this.lat,
    required this.lng,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  VehiclesCacheCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCacheCompanion(
      id: Value(id),
      json: Value(json),
      lat: Value(lat),
      lng: Value(lng),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory VehiclesCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehiclesCacheData(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  VehiclesCacheData copyWith({
    String? id,
    String? json,
    double? lat,
    double? lng,
    int? fetchedAt,
  }) => VehiclesCacheData(
    id: id ?? this.id,
    json: json ?? this.json,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  VehiclesCacheData copyWithCompanion(VehiclesCacheCompanion data) {
    return VehiclesCacheData(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCacheData(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, lat, lng, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehiclesCacheData &&
          other.id == this.id &&
          other.json == this.json &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.fetchedAt == this.fetchedAt);
}

class VehiclesCacheCompanion extends UpdateCompanion<VehiclesCacheData> {
  final Value<String> id;
  final Value<String> json;
  final Value<double> lat;
  final Value<double> lng;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const VehiclesCacheCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCacheCompanion.insert({
    required String id,
    required String json,
    required double lat,
    required double lng,
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json),
       lat = Value(lat),
       lng = Value(lng),
       fetchedAt = Value(fetchedAt);
  static Insertable<VehiclesCacheData> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<double>? lat,
    Value<double>? lng,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return VehiclesCacheCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCacheCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookingsCacheTable extends BookingsCache
    with TableInfo<$BookingsCacheTable, BookingsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, status, json, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookings_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookingsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingsCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $BookingsCacheTable createAlias(String alias) {
    return $BookingsCacheTable(attachedDatabase, alias);
  }
}

class BookingsCacheData extends DataClass
    implements Insertable<BookingsCacheData> {
  final String id;
  final String status;
  final String json;
  final int fetchedAt;
  const BookingsCacheData({
    required this.id,
    required this.status,
    required this.json,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['json'] = Variable<String>(json);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  BookingsCacheCompanion toCompanion(bool nullToAbsent) {
    return BookingsCacheCompanion(
      id: Value(id),
      status: Value(status),
      json: Value(json),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory BookingsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingsCacheData(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      json: serializer.fromJson<String>(json['json']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'json': serializer.toJson<String>(json),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  BookingsCacheData copyWith({
    String? id,
    String? status,
    String? json,
    int? fetchedAt,
  }) => BookingsCacheData(
    id: id ?? this.id,
    status: status ?? this.status,
    json: json ?? this.json,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  BookingsCacheData copyWithCompanion(BookingsCacheCompanion data) {
    return BookingsCacheData(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      json: data.json.present ? data.json.value : this.json,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingsCacheData(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, status, json, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingsCacheData &&
          other.id == this.id &&
          other.status == this.status &&
          other.json == this.json &&
          other.fetchedAt == this.fetchedAt);
}

class BookingsCacheCompanion extends UpdateCompanion<BookingsCacheData> {
  final Value<String> id;
  final Value<String> status;
  final Value<String> json;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const BookingsCacheCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.json = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingsCacheCompanion.insert({
    required String id,
    required String status,
    required String json,
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       json = Value(json),
       fetchedAt = Value(fetchedAt);
  static Insertable<BookingsCacheData> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? json,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (json != null) 'json': json,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? status,
    Value<String>? json,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return BookingsCacheCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      json: json ?? this.json,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingsCacheCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsCacheTable extends NotificationsCache
    with TableInfo<$NotificationsCacheTable, NotificationsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readLocalMeta = const VerificationMeta(
    'readLocal',
  );
  @override
  late final GeneratedColumn<bool> readLocal = GeneratedColumn<bool>(
    'read_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, readLocal, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('read_local')) {
      context.handle(
        _readLocalMeta,
        readLocal.isAcceptableOrUnknown(data['read_local']!, _readLocalMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationsCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      readLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read_local'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $NotificationsCacheTable createAlias(String alias) {
    return $NotificationsCacheTable(attachedDatabase, alias);
  }
}

class NotificationsCacheData extends DataClass
    implements Insertable<NotificationsCacheData> {
  final String id;
  final String type;
  final bool readLocal;
  final int fetchedAt;
  const NotificationsCacheData({
    required this.id,
    required this.type,
    required this.readLocal,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['read_local'] = Variable<bool>(readLocal);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  NotificationsCacheCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCacheCompanion(
      id: Value(id),
      type: Value(type),
      readLocal: Value(readLocal),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory NotificationsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationsCacheData(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      readLocal: serializer.fromJson<bool>(json['readLocal']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'readLocal': serializer.toJson<bool>(readLocal),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  NotificationsCacheData copyWith({
    String? id,
    String? type,
    bool? readLocal,
    int? fetchedAt,
  }) => NotificationsCacheData(
    id: id ?? this.id,
    type: type ?? this.type,
    readLocal: readLocal ?? this.readLocal,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  NotificationsCacheData copyWithCompanion(NotificationsCacheCompanion data) {
    return NotificationsCacheData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      readLocal: data.readLocal.present ? data.readLocal.value : this.readLocal,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCacheData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('readLocal: $readLocal, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, readLocal, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationsCacheData &&
          other.id == this.id &&
          other.type == this.type &&
          other.readLocal == this.readLocal &&
          other.fetchedAt == this.fetchedAt);
}

class NotificationsCacheCompanion
    extends UpdateCompanion<NotificationsCacheData> {
  final Value<String> id;
  final Value<String> type;
  final Value<bool> readLocal;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const NotificationsCacheCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.readLocal = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCacheCompanion.insert({
    required String id,
    required String type,
    this.readLocal = const Value.absent(),
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       fetchedAt = Value(fetchedAt);
  static Insertable<NotificationsCacheData> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<bool>? readLocal,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (readLocal != null) 'read_local': readLocal,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<bool>? readLocal,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return NotificationsCacheCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      readLocal: readLocal ?? this.readLocal,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (readLocal.present) {
      map['read_local'] = Variable<bool>(readLocal.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCacheCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('readLocal: $readLocal, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryTable extends SearchHistory
    with TableInfo<$SearchHistoryTable, SearchHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filtersMeta = const VerificationMeta(
    'filters',
  );
  @override
  late final GeneratedColumn<String> filters = GeneratedColumn<String>(
    'filters',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<int> searchedAt = GeneratedColumn<int>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, keyword, filters, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    if (data.containsKey('filters')) {
      context.handle(
        _filtersMeta,
        filters.isAcceptableOrUnknown(data['filters']!, _filtersMeta),
      );
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
      filters: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filters'],
      ),
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $SearchHistoryTable createAlias(String alias) {
    return $SearchHistoryTable(attachedDatabase, alias);
  }
}

class SearchHistoryData extends DataClass
    implements Insertable<SearchHistoryData> {
  final int id;
  final String keyword;
  final String? filters;
  final int searchedAt;
  const SearchHistoryData({
    required this.id,
    required this.keyword,
    this.filters,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['keyword'] = Variable<String>(keyword);
    if (!nullToAbsent || filters != null) {
      map['filters'] = Variable<String>(filters);
    }
    map['searched_at'] = Variable<int>(searchedAt);
    return map;
  }

  SearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryCompanion(
      id: Value(id),
      keyword: Value(keyword),
      filters: filters == null && nullToAbsent
          ? const Value.absent()
          : Value(filters),
      searchedAt: Value(searchedAt),
    );
  }

  factory SearchHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryData(
      id: serializer.fromJson<int>(json['id']),
      keyword: serializer.fromJson<String>(json['keyword']),
      filters: serializer.fromJson<String?>(json['filters']),
      searchedAt: serializer.fromJson<int>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'keyword': serializer.toJson<String>(keyword),
      'filters': serializer.toJson<String?>(filters),
      'searchedAt': serializer.toJson<int>(searchedAt),
    };
  }

  SearchHistoryData copyWith({
    int? id,
    String? keyword,
    Value<String?> filters = const Value.absent(),
    int? searchedAt,
  }) => SearchHistoryData(
    id: id ?? this.id,
    keyword: keyword ?? this.keyword,
    filters: filters.present ? filters.value : this.filters,
    searchedAt: searchedAt ?? this.searchedAt,
  );
  SearchHistoryData copyWithCompanion(SearchHistoryCompanion data) {
    return SearchHistoryData(
      id: data.id.present ? data.id.value : this.id,
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      filters: data.filters.present ? data.filters.value : this.filters,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryData(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('filters: $filters, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, keyword, filters, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryData &&
          other.id == this.id &&
          other.keyword == this.keyword &&
          other.filters == this.filters &&
          other.searchedAt == this.searchedAt);
}

class SearchHistoryCompanion extends UpdateCompanion<SearchHistoryData> {
  final Value<int> id;
  final Value<String> keyword;
  final Value<String?> filters;
  final Value<int> searchedAt;
  const SearchHistoryCompanion({
    this.id = const Value.absent(),
    this.keyword = const Value.absent(),
    this.filters = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  SearchHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String keyword,
    this.filters = const Value.absent(),
    required int searchedAt,
  }) : keyword = Value(keyword),
       searchedAt = Value(searchedAt);
  static Insertable<SearchHistoryData> custom({
    Expression<int>? id,
    Expression<String>? keyword,
    Expression<String>? filters,
    Expression<int>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keyword != null) 'keyword': keyword,
      if (filters != null) 'filters': filters,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  SearchHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? keyword,
    Value<String?>? filters,
    Value<int>? searchedAt,
  }) {
    return SearchHistoryCompanion(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      filters: filters ?? this.filters,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (filters.present) {
      map['filters'] = Variable<String>(filters.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<int>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryCompanion(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('filters: $filters, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

class $BookingDraftsTable extends BookingDrafts
    with TableInfo<$BookingDraftsTable, BookingDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryWantedMeta = const VerificationMeta(
    'deliveryWanted',
  );
  @override
  late final GeneratedColumn<bool> deliveryWanted = GeneratedColumn<bool>(
    'delivery_wanted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("delivery_wanted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    startTime,
    endTime,
    deliveryWanted,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'booking_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('delivery_wanted')) {
      context.handle(
        _deliveryWantedMeta,
        deliveryWanted.isAcceptableOrUnknown(
          data['delivery_wanted']!,
          _deliveryWantedMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookingDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time'],
      )!,
      deliveryWanted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}delivery_wanted'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $BookingDraftsTable createAlias(String alias) {
    return $BookingDraftsTable(attachedDatabase, alias);
  }
}

class BookingDraft extends DataClass implements Insertable<BookingDraft> {
  final int id;
  final String vehicleId;
  final int startTime;
  final int endTime;
  final bool deliveryWanted;
  final String syncState;
  const BookingDraft({
    required this.id,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.deliveryWanted,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['start_time'] = Variable<int>(startTime);
    map['end_time'] = Variable<int>(endTime);
    map['delivery_wanted'] = Variable<bool>(deliveryWanted);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  BookingDraftsCompanion toCompanion(bool nullToAbsent) {
    return BookingDraftsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      startTime: Value(startTime),
      endTime: Value(endTime),
      deliveryWanted: Value(deliveryWanted),
      syncState: Value(syncState),
    );
  }

  factory BookingDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingDraft(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int>(json['endTime']),
      deliveryWanted: serializer.fromJson<bool>(json['deliveryWanted']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int>(endTime),
      'deliveryWanted': serializer.toJson<bool>(deliveryWanted),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  BookingDraft copyWith({
    int? id,
    String? vehicleId,
    int? startTime,
    int? endTime,
    bool? deliveryWanted,
    String? syncState,
  }) => BookingDraft(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    deliveryWanted: deliveryWanted ?? this.deliveryWanted,
    syncState: syncState ?? this.syncState,
  );
  BookingDraft copyWithCompanion(BookingDraftsCompanion data) {
    return BookingDraft(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      deliveryWanted: data.deliveryWanted.present
          ? data.deliveryWanted.value
          : this.deliveryWanted,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingDraft(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('deliveryWanted: $deliveryWanted, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vehicleId, startTime, endTime, deliveryWanted, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingDraft &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.deliveryWanted == this.deliveryWanted &&
          other.syncState == this.syncState);
}

class BookingDraftsCompanion extends UpdateCompanion<BookingDraft> {
  final Value<int> id;
  final Value<String> vehicleId;
  final Value<int> startTime;
  final Value<int> endTime;
  final Value<bool> deliveryWanted;
  final Value<String> syncState;
  const BookingDraftsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.deliveryWanted = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  BookingDraftsCompanion.insert({
    this.id = const Value.absent(),
    required String vehicleId,
    required int startTime,
    required int endTime,
    this.deliveryWanted = const Value.absent(),
    this.syncState = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<BookingDraft> custom({
    Expression<int>? id,
    Expression<String>? vehicleId,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<bool>? deliveryWanted,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (deliveryWanted != null) 'delivery_wanted': deliveryWanted,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  BookingDraftsCompanion copyWith({
    Value<int>? id,
    Value<String>? vehicleId,
    Value<int>? startTime,
    Value<int>? endTime,
    Value<bool>? deliveryWanted,
    Value<String>? syncState,
  }) {
    return BookingDraftsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      deliveryWanted: deliveryWanted ?? this.deliveryWanted,
      syncState: syncState ?? this.syncState,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (deliveryWanted.present) {
      map['delivery_wanted'] = Variable<bool>(deliveryWanted.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingDraftsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('deliveryWanted: $deliveryWanted, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $ChatConvLocalTable extends ChatConvLocal
    with TableInfo<$ChatConvLocalTable, ChatConvLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatConvLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastBodyMeta = const VerificationMeta(
    'lastBody',
  );
  @override
  late final GeneratedColumn<String> lastBody = GeneratedColumn<String>(
    'last_body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAtMeta = const VerificationMeta('lastAt');
  @override
  late final GeneratedColumn<int> lastAt = GeneratedColumn<int>(
    'last_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastBody, lastAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_conv_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatConvLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_body')) {
      context.handle(
        _lastBodyMeta,
        lastBody.isAcceptableOrUnknown(data['last_body']!, _lastBodyMeta),
      );
    }
    if (data.containsKey('last_at')) {
      context.handle(
        _lastAtMeta,
        lastAt.isAcceptableOrUnknown(data['last_at']!, _lastAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatConvLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatConvLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lastBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_body'],
      ),
      lastAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_at'],
      ),
    );
  }

  @override
  $ChatConvLocalTable createAlias(String alias) {
    return $ChatConvLocalTable(attachedDatabase, alias);
  }
}

class ChatConvLocalData extends DataClass
    implements Insertable<ChatConvLocalData> {
  final String id;
  final String? lastBody;
  final int? lastAt;
  const ChatConvLocalData({required this.id, this.lastBody, this.lastAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || lastBody != null) {
      map['last_body'] = Variable<String>(lastBody);
    }
    if (!nullToAbsent || lastAt != null) {
      map['last_at'] = Variable<int>(lastAt);
    }
    return map;
  }

  ChatConvLocalCompanion toCompanion(bool nullToAbsent) {
    return ChatConvLocalCompanion(
      id: Value(id),
      lastBody: lastBody == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBody),
      lastAt: lastAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAt),
    );
  }

  factory ChatConvLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatConvLocalData(
      id: serializer.fromJson<String>(json['id']),
      lastBody: serializer.fromJson<String?>(json['lastBody']),
      lastAt: serializer.fromJson<int?>(json['lastAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastBody': serializer.toJson<String?>(lastBody),
      'lastAt': serializer.toJson<int?>(lastAt),
    };
  }

  ChatConvLocalData copyWith({
    String? id,
    Value<String?> lastBody = const Value.absent(),
    Value<int?> lastAt = const Value.absent(),
  }) => ChatConvLocalData(
    id: id ?? this.id,
    lastBody: lastBody.present ? lastBody.value : this.lastBody,
    lastAt: lastAt.present ? lastAt.value : this.lastAt,
  );
  ChatConvLocalData copyWithCompanion(ChatConvLocalCompanion data) {
    return ChatConvLocalData(
      id: data.id.present ? data.id.value : this.id,
      lastBody: data.lastBody.present ? data.lastBody.value : this.lastBody,
      lastAt: data.lastAt.present ? data.lastAt.value : this.lastAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatConvLocalData(')
          ..write('id: $id, ')
          ..write('lastBody: $lastBody, ')
          ..write('lastAt: $lastAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastBody, lastAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatConvLocalData &&
          other.id == this.id &&
          other.lastBody == this.lastBody &&
          other.lastAt == this.lastAt);
}

class ChatConvLocalCompanion extends UpdateCompanion<ChatConvLocalData> {
  final Value<String> id;
  final Value<String?> lastBody;
  final Value<int?> lastAt;
  final Value<int> rowid;
  const ChatConvLocalCompanion({
    this.id = const Value.absent(),
    this.lastBody = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatConvLocalCompanion.insert({
    required String id,
    this.lastBody = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ChatConvLocalData> custom({
    Expression<String>? id,
    Expression<String>? lastBody,
    Expression<int>? lastAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastBody != null) 'last_body': lastBody,
      if (lastAt != null) 'last_at': lastAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatConvLocalCompanion copyWith({
    Value<String>? id,
    Value<String?>? lastBody,
    Value<int?>? lastAt,
    Value<int>? rowid,
  }) {
    return ChatConvLocalCompanion(
      id: id ?? this.id,
      lastBody: lastBody ?? this.lastBody,
      lastAt: lastAt ?? this.lastAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lastBody.present) {
      map['last_body'] = Variable<String>(lastBody.value);
    }
    if (lastAt.present) {
      map['last_at'] = Variable<int>(lastAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatConvLocalCompanion(')
          ..write('id: $id, ')
          ..write('lastBody: $lastBody, ')
          ..write('lastAt: $lastAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesLocalTable extends ChatMessagesLocal
    with TableInfo<$ChatMessagesLocalTable, ChatMessagesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    conversationId,
    body,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessagesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ChatMessagesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessagesLocalData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $ChatMessagesLocalTable createAlias(String alias) {
    return $ChatMessagesLocalTable(attachedDatabase, alias);
  }
}

class ChatMessagesLocalData extends DataClass
    implements Insertable<ChatMessagesLocalData> {
  final int localId;
  final String? serverId;
  final String conversationId;
  final String body;
  final String syncState;
  const ChatMessagesLocalData({
    required this.localId,
    this.serverId,
    required this.conversationId,
    required this.body,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['conversation_id'] = Variable<String>(conversationId);
    map['body'] = Variable<String>(body);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  ChatMessagesLocalCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesLocalCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      conversationId: Value(conversationId),
      body: Value(body),
      syncState: Value(syncState),
    );
  }

  factory ChatMessagesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessagesLocalData(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      body: serializer.fromJson<String>(json['body']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'conversationId': serializer.toJson<String>(conversationId),
      'body': serializer.toJson<String>(body),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  ChatMessagesLocalData copyWith({
    int? localId,
    Value<String?> serverId = const Value.absent(),
    String? conversationId,
    String? body,
    String? syncState,
  }) => ChatMessagesLocalData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    conversationId: conversationId ?? this.conversationId,
    body: body ?? this.body,
    syncState: syncState ?? this.syncState,
  );
  ChatMessagesLocalData copyWithCompanion(ChatMessagesLocalCompanion data) {
    return ChatMessagesLocalData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      body: data.body.present ? data.body.value : this.body,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesLocalData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('conversationId: $conversationId, ')
          ..write('body: $body, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localId, serverId, conversationId, body, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessagesLocalData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.conversationId == this.conversationId &&
          other.body == this.body &&
          other.syncState == this.syncState);
}

class ChatMessagesLocalCompanion
    extends UpdateCompanion<ChatMessagesLocalData> {
  final Value<int> localId;
  final Value<String?> serverId;
  final Value<String> conversationId;
  final Value<String> body;
  final Value<String> syncState;
  const ChatMessagesLocalCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.body = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  ChatMessagesLocalCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    required String conversationId,
    required String body,
    this.syncState = const Value.absent(),
  }) : conversationId = Value(conversationId),
       body = Value(body);
  static Insertable<ChatMessagesLocalData> custom({
    Expression<int>? localId,
    Expression<String>? serverId,
    Expression<String>? conversationId,
    Expression<String>? body,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (body != null) 'body': body,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  ChatMessagesLocalCompanion copyWith({
    Value<int>? localId,
    Value<String?>? serverId,
    Value<String>? conversationId,
    Value<String>? body,
    Value<String>? syncState,
  }) {
    return ChatMessagesLocalCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      conversationId: conversationId ?? this.conversationId,
      body: body ?? this.body,
      syncState: syncState ?? this.syncState,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesLocalCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('conversationId: $conversationId, ')
          ..write('body: $body, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesCacheTable vehiclesCache = $VehiclesCacheTable(this);
  late final $BookingsCacheTable bookingsCache = $BookingsCacheTable(this);
  late final $NotificationsCacheTable notificationsCache =
      $NotificationsCacheTable(this);
  late final $SearchHistoryTable searchHistory = $SearchHistoryTable(this);
  late final $BookingDraftsTable bookingDrafts = $BookingDraftsTable(this);
  late final $ChatConvLocalTable chatConvLocal = $ChatConvLocalTable(this);
  late final $ChatMessagesLocalTable chatMessagesLocal =
      $ChatMessagesLocalTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehiclesCache,
    bookingsCache,
    notificationsCache,
    searchHistory,
    bookingDrafts,
    chatConvLocal,
    chatMessagesLocal,
  ];
}

typedef $$VehiclesCacheTableCreateCompanionBuilder =
    VehiclesCacheCompanion Function({
      required String id,
      required String json,
      required double lat,
      required double lng,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$VehiclesCacheTableUpdateCompanionBuilder =
    VehiclesCacheCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<double> lat,
      Value<double> lng,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$VehiclesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesCacheTable> {
  $$VehiclesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesCacheTable> {
  $$VehiclesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesCacheTable> {
  $$VehiclesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$VehiclesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesCacheTable,
          VehiclesCacheData,
          $$VehiclesCacheTableFilterComposer,
          $$VehiclesCacheTableOrderingComposer,
          $$VehiclesCacheTableAnnotationComposer,
          $$VehiclesCacheTableCreateCompanionBuilder,
          $$VehiclesCacheTableUpdateCompanionBuilder,
          (
            VehiclesCacheData,
            BaseReferences<
              _$AppDatabase,
              $VehiclesCacheTable,
              VehiclesCacheData
            >,
          ),
          VehiclesCacheData,
          PrefetchHooks Function()
        > {
  $$VehiclesCacheTableTableManager(_$AppDatabase db, $VehiclesCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCacheCompanion(
                id: id,
                json: json,
                lat: lat,
                lng: lng,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                required double lat,
                required double lng,
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCacheCompanion.insert(
                id: id,
                json: json,
                lat: lat,
                lng: lng,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehiclesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesCacheTable,
      VehiclesCacheData,
      $$VehiclesCacheTableFilterComposer,
      $$VehiclesCacheTableOrderingComposer,
      $$VehiclesCacheTableAnnotationComposer,
      $$VehiclesCacheTableCreateCompanionBuilder,
      $$VehiclesCacheTableUpdateCompanionBuilder,
      (
        VehiclesCacheData,
        BaseReferences<_$AppDatabase, $VehiclesCacheTable, VehiclesCacheData>,
      ),
      VehiclesCacheData,
      PrefetchHooks Function()
    >;
typedef $$BookingsCacheTableCreateCompanionBuilder =
    BookingsCacheCompanion Function({
      required String id,
      required String status,
      required String json,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$BookingsCacheTableUpdateCompanionBuilder =
    BookingsCacheCompanion Function({
      Value<String> id,
      Value<String> status,
      Value<String> json,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$BookingsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $BookingsCacheTable> {
  $$BookingsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingsCacheTable> {
  $$BookingsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingsCacheTable> {
  $$BookingsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$BookingsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingsCacheTable,
          BookingsCacheData,
          $$BookingsCacheTableFilterComposer,
          $$BookingsCacheTableOrderingComposer,
          $$BookingsCacheTableAnnotationComposer,
          $$BookingsCacheTableCreateCompanionBuilder,
          $$BookingsCacheTableUpdateCompanionBuilder,
          (
            BookingsCacheData,
            BaseReferences<
              _$AppDatabase,
              $BookingsCacheTable,
              BookingsCacheData
            >,
          ),
          BookingsCacheData,
          PrefetchHooks Function()
        > {
  $$BookingsCacheTableTableManager(_$AppDatabase db, $BookingsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingsCacheCompanion(
                id: id,
                status: status,
                json: json,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String status,
                required String json,
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => BookingsCacheCompanion.insert(
                id: id,
                status: status,
                json: json,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingsCacheTable,
      BookingsCacheData,
      $$BookingsCacheTableFilterComposer,
      $$BookingsCacheTableOrderingComposer,
      $$BookingsCacheTableAnnotationComposer,
      $$BookingsCacheTableCreateCompanionBuilder,
      $$BookingsCacheTableUpdateCompanionBuilder,
      (
        BookingsCacheData,
        BaseReferences<_$AppDatabase, $BookingsCacheTable, BookingsCacheData>,
      ),
      BookingsCacheData,
      PrefetchHooks Function()
    >;
typedef $$NotificationsCacheTableCreateCompanionBuilder =
    NotificationsCacheCompanion Function({
      required String id,
      required String type,
      Value<bool> readLocal,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$NotificationsCacheTableUpdateCompanionBuilder =
    NotificationsCacheCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<bool> readLocal,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$NotificationsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsCacheTable> {
  $$NotificationsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get readLocal => $composableBuilder(
    column: $table.readLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsCacheTable> {
  $$NotificationsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get readLocal => $composableBuilder(
    column: $table.readLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsCacheTable> {
  $$NotificationsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get readLocal =>
      $composableBuilder(column: $table.readLocal, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$NotificationsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsCacheTable,
          NotificationsCacheData,
          $$NotificationsCacheTableFilterComposer,
          $$NotificationsCacheTableOrderingComposer,
          $$NotificationsCacheTableAnnotationComposer,
          $$NotificationsCacheTableCreateCompanionBuilder,
          $$NotificationsCacheTableUpdateCompanionBuilder,
          (
            NotificationsCacheData,
            BaseReferences<
              _$AppDatabase,
              $NotificationsCacheTable,
              NotificationsCacheData
            >,
          ),
          NotificationsCacheData,
          PrefetchHooks Function()
        > {
  $$NotificationsCacheTableTableManager(
    _$AppDatabase db,
    $NotificationsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> readLocal = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCacheCompanion(
                id: id,
                type: type,
                readLocal: readLocal,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<bool> readLocal = const Value.absent(),
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCacheCompanion.insert(
                id: id,
                type: type,
                readLocal: readLocal,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsCacheTable,
      NotificationsCacheData,
      $$NotificationsCacheTableFilterComposer,
      $$NotificationsCacheTableOrderingComposer,
      $$NotificationsCacheTableAnnotationComposer,
      $$NotificationsCacheTableCreateCompanionBuilder,
      $$NotificationsCacheTableUpdateCompanionBuilder,
      (
        NotificationsCacheData,
        BaseReferences<
          _$AppDatabase,
          $NotificationsCacheTable,
          NotificationsCacheData
        >,
      ),
      NotificationsCacheData,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryTableCreateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<int> id,
      required String keyword,
      Value<String?> filters,
      required int searchedAt,
    });
typedef $$SearchHistoryTableUpdateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<int> id,
      Value<String> keyword,
      Value<String?> filters,
      Value<int> searchedAt,
    });

class $$SearchHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filters => $composableBuilder(
    column: $table.filters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filters => $composableBuilder(
    column: $table.filters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<String> get filters =>
      $composableBuilder(column: $table.filters, builder: (column) => column);

  GeneratedColumn<int> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$SearchHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryTable,
          SearchHistoryData,
          $$SearchHistoryTableFilterComposer,
          $$SearchHistoryTableOrderingComposer,
          $$SearchHistoryTableAnnotationComposer,
          $$SearchHistoryTableCreateCompanionBuilder,
          $$SearchHistoryTableUpdateCompanionBuilder,
          (
            SearchHistoryData,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryTable,
              SearchHistoryData
            >,
          ),
          SearchHistoryData,
          PrefetchHooks Function()
        > {
  $$SearchHistoryTableTableManager(_$AppDatabase db, $SearchHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> keyword = const Value.absent(),
                Value<String?> filters = const Value.absent(),
                Value<int> searchedAt = const Value.absent(),
              }) => SearchHistoryCompanion(
                id: id,
                keyword: keyword,
                filters: filters,
                searchedAt: searchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String keyword,
                Value<String?> filters = const Value.absent(),
                required int searchedAt,
              }) => SearchHistoryCompanion.insert(
                id: id,
                keyword: keyword,
                filters: filters,
                searchedAt: searchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryTable,
      SearchHistoryData,
      $$SearchHistoryTableFilterComposer,
      $$SearchHistoryTableOrderingComposer,
      $$SearchHistoryTableAnnotationComposer,
      $$SearchHistoryTableCreateCompanionBuilder,
      $$SearchHistoryTableUpdateCompanionBuilder,
      (
        SearchHistoryData,
        BaseReferences<_$AppDatabase, $SearchHistoryTable, SearchHistoryData>,
      ),
      SearchHistoryData,
      PrefetchHooks Function()
    >;
typedef $$BookingDraftsTableCreateCompanionBuilder =
    BookingDraftsCompanion Function({
      Value<int> id,
      required String vehicleId,
      required int startTime,
      required int endTime,
      Value<bool> deliveryWanted,
      Value<String> syncState,
    });
typedef $$BookingDraftsTableUpdateCompanionBuilder =
    BookingDraftsCompanion Function({
      Value<int> id,
      Value<String> vehicleId,
      Value<int> startTime,
      Value<int> endTime,
      Value<bool> deliveryWanted,
      Value<String> syncState,
    });

class $$BookingDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $BookingDraftsTable> {
  $$BookingDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deliveryWanted => $composableBuilder(
    column: $table.deliveryWanted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingDraftsTable> {
  $$BookingDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deliveryWanted => $composableBuilder(
    column: $table.deliveryWanted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingDraftsTable> {
  $$BookingDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get deliveryWanted => $composableBuilder(
    column: $table.deliveryWanted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$BookingDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingDraftsTable,
          BookingDraft,
          $$BookingDraftsTableFilterComposer,
          $$BookingDraftsTableOrderingComposer,
          $$BookingDraftsTableAnnotationComposer,
          $$BookingDraftsTableCreateCompanionBuilder,
          $$BookingDraftsTableUpdateCompanionBuilder,
          (
            BookingDraft,
            BaseReferences<_$AppDatabase, $BookingDraftsTable, BookingDraft>,
          ),
          BookingDraft,
          PrefetchHooks Function()
        > {
  $$BookingDraftsTableTableManager(_$AppDatabase db, $BookingDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                Value<int> endTime = const Value.absent(),
                Value<bool> deliveryWanted = const Value.absent(),
                Value<String> syncState = const Value.absent(),
              }) => BookingDraftsCompanion(
                id: id,
                vehicleId: vehicleId,
                startTime: startTime,
                endTime: endTime,
                deliveryWanted: deliveryWanted,
                syncState: syncState,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vehicleId,
                required int startTime,
                required int endTime,
                Value<bool> deliveryWanted = const Value.absent(),
                Value<String> syncState = const Value.absent(),
              }) => BookingDraftsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                startTime: startTime,
                endTime: endTime,
                deliveryWanted: deliveryWanted,
                syncState: syncState,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingDraftsTable,
      BookingDraft,
      $$BookingDraftsTableFilterComposer,
      $$BookingDraftsTableOrderingComposer,
      $$BookingDraftsTableAnnotationComposer,
      $$BookingDraftsTableCreateCompanionBuilder,
      $$BookingDraftsTableUpdateCompanionBuilder,
      (
        BookingDraft,
        BaseReferences<_$AppDatabase, $BookingDraftsTable, BookingDraft>,
      ),
      BookingDraft,
      PrefetchHooks Function()
    >;
typedef $$ChatConvLocalTableCreateCompanionBuilder =
    ChatConvLocalCompanion Function({
      required String id,
      Value<String?> lastBody,
      Value<int?> lastAt,
      Value<int> rowid,
    });
typedef $$ChatConvLocalTableUpdateCompanionBuilder =
    ChatConvLocalCompanion Function({
      Value<String> id,
      Value<String?> lastBody,
      Value<int?> lastAt,
      Value<int> rowid,
    });

class $$ChatConvLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ChatConvLocalTable> {
  $$ChatConvLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastBody => $composableBuilder(
    column: $table.lastBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatConvLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatConvLocalTable> {
  $$ChatConvLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastBody => $composableBuilder(
    column: $table.lastBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatConvLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatConvLocalTable> {
  $$ChatConvLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lastBody =>
      $composableBuilder(column: $table.lastBody, builder: (column) => column);

  GeneratedColumn<int> get lastAt =>
      $composableBuilder(column: $table.lastAt, builder: (column) => column);
}

class $$ChatConvLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatConvLocalTable,
          ChatConvLocalData,
          $$ChatConvLocalTableFilterComposer,
          $$ChatConvLocalTableOrderingComposer,
          $$ChatConvLocalTableAnnotationComposer,
          $$ChatConvLocalTableCreateCompanionBuilder,
          $$ChatConvLocalTableUpdateCompanionBuilder,
          (
            ChatConvLocalData,
            BaseReferences<
              _$AppDatabase,
              $ChatConvLocalTable,
              ChatConvLocalData
            >,
          ),
          ChatConvLocalData,
          PrefetchHooks Function()
        > {
  $$ChatConvLocalTableTableManager(_$AppDatabase db, $ChatConvLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatConvLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatConvLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatConvLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> lastBody = const Value.absent(),
                Value<int?> lastAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatConvLocalCompanion(
                id: id,
                lastBody: lastBody,
                lastAt: lastAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> lastBody = const Value.absent(),
                Value<int?> lastAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatConvLocalCompanion.insert(
                id: id,
                lastBody: lastBody,
                lastAt: lastAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatConvLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatConvLocalTable,
      ChatConvLocalData,
      $$ChatConvLocalTableFilterComposer,
      $$ChatConvLocalTableOrderingComposer,
      $$ChatConvLocalTableAnnotationComposer,
      $$ChatConvLocalTableCreateCompanionBuilder,
      $$ChatConvLocalTableUpdateCompanionBuilder,
      (
        ChatConvLocalData,
        BaseReferences<_$AppDatabase, $ChatConvLocalTable, ChatConvLocalData>,
      ),
      ChatConvLocalData,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesLocalTableCreateCompanionBuilder =
    ChatMessagesLocalCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      required String conversationId,
      required String body,
      Value<String> syncState,
    });
typedef $$ChatMessagesLocalTableUpdateCompanionBuilder =
    ChatMessagesLocalCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> conversationId,
      Value<String> body,
      Value<String> syncState,
    });

class $$ChatMessagesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesLocalTable> {
  $$ChatMessagesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesLocalTable> {
  $$ChatMessagesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesLocalTable> {
  $$ChatMessagesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$ChatMessagesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesLocalTable,
          ChatMessagesLocalData,
          $$ChatMessagesLocalTableFilterComposer,
          $$ChatMessagesLocalTableOrderingComposer,
          $$ChatMessagesLocalTableAnnotationComposer,
          $$ChatMessagesLocalTableCreateCompanionBuilder,
          $$ChatMessagesLocalTableUpdateCompanionBuilder,
          (
            ChatMessagesLocalData,
            BaseReferences<
              _$AppDatabase,
              $ChatMessagesLocalTable,
              ChatMessagesLocalData
            >,
          ),
          ChatMessagesLocalData,
          PrefetchHooks Function()
        > {
  $$ChatMessagesLocalTableTableManager(
    _$AppDatabase db,
    $ChatMessagesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> syncState = const Value.absent(),
              }) => ChatMessagesLocalCompanion(
                localId: localId,
                serverId: serverId,
                conversationId: conversationId,
                body: body,
                syncState: syncState,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String conversationId,
                required String body,
                Value<String> syncState = const Value.absent(),
              }) => ChatMessagesLocalCompanion.insert(
                localId: localId,
                serverId: serverId,
                conversationId: conversationId,
                body: body,
                syncState: syncState,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesLocalTable,
      ChatMessagesLocalData,
      $$ChatMessagesLocalTableFilterComposer,
      $$ChatMessagesLocalTableOrderingComposer,
      $$ChatMessagesLocalTableAnnotationComposer,
      $$ChatMessagesLocalTableCreateCompanionBuilder,
      $$ChatMessagesLocalTableUpdateCompanionBuilder,
      (
        ChatMessagesLocalData,
        BaseReferences<
          _$AppDatabase,
          $ChatMessagesLocalTable,
          ChatMessagesLocalData
        >,
      ),
      ChatMessagesLocalData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesCacheTableTableManager get vehiclesCache =>
      $$VehiclesCacheTableTableManager(_db, _db.vehiclesCache);
  $$BookingsCacheTableTableManager get bookingsCache =>
      $$BookingsCacheTableTableManager(_db, _db.bookingsCache);
  $$NotificationsCacheTableTableManager get notificationsCache =>
      $$NotificationsCacheTableTableManager(_db, _db.notificationsCache);
  $$SearchHistoryTableTableManager get searchHistory =>
      $$SearchHistoryTableTableManager(_db, _db.searchHistory);
  $$BookingDraftsTableTableManager get bookingDrafts =>
      $$BookingDraftsTableTableManager(_db, _db.bookingDrafts);
  $$ChatConvLocalTableTableManager get chatConvLocal =>
      $$ChatConvLocalTableTableManager(_db, _db.chatConvLocal);
  $$ChatMessagesLocalTableTableManager get chatMessagesLocal =>
      $$ChatMessagesLocalTableTableManager(_db, _db.chatMessagesLocal);
}
