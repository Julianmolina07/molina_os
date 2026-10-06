import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Accounts extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  IntColumn get type => integer()();

  TextColumn get currency => text().withDefault(const Constant('COP'))();

  IntColumn get legalOwner => integer()();

  IntColumn get economicResponsible => integer()();

  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();

  IntColumn get type => integer()();

  IntColumn get amount => integer()();

  TextColumn get accountId => text()();

  IntColumn get category => integer()();

  DateTimeColumn get date => dateTime()();

  TextColumn get destinationAccountId => text().nullable()();

  TextColumn get personId => text().nullable()();

  TextColumn get debtId => text().nullable()();

  IntColumn get context => integer().nullable()();

  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Accounts,
    Transactions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(transactions);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      p.join(directory.path, 'molina_os.sqlite'),
    );

    return NativeDatabase.createInBackground(file);
  });
}