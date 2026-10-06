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

@DriftDatabase(
  tables: [
    Accounts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
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