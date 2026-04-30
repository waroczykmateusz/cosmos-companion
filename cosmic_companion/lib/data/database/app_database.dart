import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ── Tables ────────────────────────────────────────────────────────────────────
// All tables share four sync-ready columns:
//   created_at / updated_at  — timestamps
//   deleted_at               — soft delete (null = alive)
//   user_id                  — nullable until cloud sync is wired up

@DataClassName('LocalProfileRow')
class LocalProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get nick => text()();
  BoolColumn get biometricEnabled =>
      boolean().named('biometric_enabled').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt =>
      dateTime().named('deleted_at').nullable()();
  TextColumn get userId => text().named('user_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionLogRow')
class SessionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().named('profile_id').references(LocalProfiles, #id)();
  DateTimeColumn get startedAt => dateTime().named('started_at')();
  DateTimeColumn get endedAt => dateTime().named('ended_at').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt =>
      dateTime().named('deleted_at').nullable()();
  TextColumn get userId => text().named('user_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EquipmentRow')
class Equipment extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt =>
      dateTime().named('deleted_at').nullable()();
  TextColumn get userId => text().named('user_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AstroEventCacheRow')
class AstroEventsCache extends Table {
  TextColumn get id => text()();
  TextColumn get bodyId => text().named('body_id')();
  TextColumn get eventType => text().named('event_type')();
  DateTimeColumn get eventTime => dateTime().named('event_time')();
  RealColumn get locationLat => real().named('location_lat')();
  RealColumn get locationLon => real().named('location_lon')();
  DateTimeColumn get cachedAt => dateTime().named('cached_at')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt =>
      dateTime().named('deleted_at').nullable()();
  TextColumn get userId => text().named('user_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NatalChartRow')
class NatalCharts extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().named('profile_id').references(LocalProfiles, #id)();
  TextColumn get label => text()();
  DateTimeColumn get birthTime => dateTime().named('birth_time')();
  RealColumn get birthLat => real().named('birth_lat')();
  RealColumn get birthLon => real().named('birth_lon')();
  TextColumn get birthLocationName =>
      text().named('birth_location_name').nullable()();
  TextColumn get chartDataJson => text().named('chart_data_json')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt =>
      dateTime().named('deleted_at').nullable()();
  TextColumn get userId => text().named('user_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    AstroEventsCache,
    Equipment,
    LocalProfiles,
    NatalCharts,
    SessionLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'cosmic_companion'));

  @override
  int get schemaVersion => 1;
}
