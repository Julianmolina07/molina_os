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

  /// Persona relacionada con el movimiento.
  ///
  /// Se utiliza principalmente para préstamos y cobros,
  /// pero puede reutilizarse para otros movimientos relacionados
  /// con una persona.
  TextColumn get personId => text().nullable()();

  TextColumn get debtId => text().nullable()();

  IntColumn get context => integer().nullable()();

  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class People extends Table {
  TextColumn get id => text()();

  /// Nombre completo o nombre identificador de la persona.
  TextColumn get name => text()();

  /// Teléfono opcional.
  TextColumn get phone => text().nullable()();

  /// Notas generales sobre la persona.
  TextColumn get notes => text().nullable()();

  /// Permite conservar el historial sin eliminar físicamente
  /// a la persona.
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Loans extends Table {
  TextColumn get id => text()();

  /// Persona que recibió el dinero.
  TextColumn get personId => text()();

  /// Movimiento financiero original de tipo lending.
  ///
  /// Este movimiento representa la salida real del dinero.
  TextColumn get initialTransactionId => text()();

  /// Valor original prestado.
  IntColumn get originalAmount => integer()();

  /// Saldo que la persona todavía debe.
  IntColumn get remainingBalance => integer()();

  DateTimeColumn get startDate => dateTime()();

  /// Fecha prevista de pago, si existe.
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Estado:
  /// 0 = active
  /// 1 = paid
  /// 2 = cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LoanPayments extends Table {
  TextColumn get id => text()();

  /// Préstamo al que pertenece este cobro.
  TextColumn get loanId => text()();

  /// Movimiento financiero de tipo repayment.
  ///
  /// Este movimiento representa la entrada real del dinero.
  TextColumn get transactionId => text()();

  /// Valor recibido.
  IntColumn get amount => integer()();

  DateTimeColumn get date => dateTime()();

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
  RealColumn get interestRate => real().withDefault(const Constant(0.0))();

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
  IntColumn get frequency => integer().withDefault(const Constant(3))();

  DateTimeColumn get nextDueDate => dateTime().nullable()();

  /// DebtStatus:
  /// 0 = active
  /// 1 = paid
  /// 2 = overdue
  /// 3 = cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DebtPayments extends Table {
  TextColumn get id => text()();

  /// Deuda a la que pertenece este pago.
  TextColumn get debtId => text()();

  /// Movimiento financiero que representa la salida
  /// total de dinero de la cuenta.
  TextColumn get transactionId => text()();

  /// Valor total que salió de la cuenta.
  IntColumn get totalAmount => integer()();

  /// Parte del pago que reduce el capital de la deuda.
  IntColumn get principalAmount => integer()();

  /// Parte del pago correspondiente a intereses.
  IntColumn get interestAmount => integer().withDefault(const Constant(0))();

  /// Comisiones, seguros u otros cargos asociados al pago.
  IntColumn get feeAmount => integer().withDefault(const Constant(0))();

  DateTimeColumn get date => dateTime()();

  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Accounts,
    Transactions,
    People,
    Loans,
    LoanPayments,
    Debts,
    DebtPayments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

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

          if (from < 4) {
            await m.createTable(debtPayments);
          }

          if (from < 5) {
            await m.createTable(people);
            await m.createTable(loans);
            await m.createTable(loanPayments);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return openDatabaseConnection();
}