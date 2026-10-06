import 'package:drift/drift.dart';

import 'database/shared.dart';

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

class Debts extends Table {
  TextColumn get id => text()();

  /// Persona, banco, entidad o empresa a la que se debe.
  TextColumn get creditor => text()();

  /// Nombre identificador de la deuda.
  TextColumn get name => text()();

  /// Valor original de la deuda.
  IntColumn get originalAmount => integer()();

  /// Capital pendiente actualmente.
  IntColumn get remainingBalance => integer()();

  /// Tasa de interés anual en porcentaje.
  /// Ejemplo: 24.5 representa 24.5% E.A.
  RealColumn get interestRate =>
      real().withDefault(const Constant(0.0))();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Valor habitual de la cuota.
  IntColumn get installmentAmount => integer().nullable()();

  /// DebtFrequency:
  /// 0 = oneTime
  /// 1 = weekly
  /// 2 = biweekly
  /// 3 = monthly
  /// 4 = quarterly
  /// 5 = yearly
  IntColumn get frequency =>
      integer().withDefault(const Constant(3))();

  DateTimeColumn get nextDueDate => dateTime().nullable()();

  /// DebtStatus:
  /// 0 = active
  /// 1 = paid
  /// 2 = overdue
  /// 3 = cancelled
  IntColumn get status =>
      integer().withDefault(const Constant(0))();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Accounts,
    Transactions,
    Debts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(transactions);
          }

          if (from < 3) {
            await m.createTable(debts);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return openDatabaseConnection();
}