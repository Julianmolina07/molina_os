import 'package:drift/drift.dart';

import '../app_database.dart';

class DebtRepository {
  final AppDatabase database;

  const DebtRepository(this.database);

  /// Observa todas las deudas registradas.
  Stream<List<Debt>> watchAll() {
    return (database.select(database.debts)
          ..orderBy([
            (debt) => OrderingTerm(
                  expression: debt.nextDueDate,
                  mode: OrderingMode.asc,
                ),
          ]))
        .watch();
  }

  /// Busca una deuda por su ID.
  Future<Debt?> findById(String id) {
    return (database.select(database.debts)
          ..where((debt) => debt.id.equals(id)))
        .getSingleOrNull();
  }

  /// Crea una nueva deuda.
  Future<void> create(DebtsCompanion debt) {
    return database.into(database.debts).insert(debt);
  }

  /// Actualiza una deuda existente.
  Future<bool> updateDebt(DebtsCompanion debt) async {
    final updatedRows =
        await database.update(database.debts).write(debt);

    return updatedRows > 0;
  }

  /// Elimina una deuda.
  Future<void> delete(String id) {
    return (database.delete(database.debts)
          ..where((debt) => debt.id.equals(id)))
        .go();
  }
}