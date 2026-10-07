import 'package:drift/drift.dart';

import '../app_database.dart';

class PersonRepository {
  final AppDatabase database;

  const PersonRepository(this.database);

  Stream<List<PeopleData>> watchAll() {
    return (database.select(database.people)
          ..where((person) => person.active.equals(true))
          ..orderBy([
            (person) => OrderingTerm(
                  expression: person.name,
                  mode: OrderingMode.asc,
                ),
          ]))
        .watch();
  }

  Future<List<PeopleData>> findAllActive() {
    return (database.select(database.people)
          ..where((person) => person.active.equals(true))
          ..orderBy([
            (person) => OrderingTerm(
                  expression: person.name,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Future<PeopleData?> findById(String id) {
    return (database.select(database.people)
          ..where((person) => person.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> create(PeopleCompanion person) {
    return database.into(database.people).insert(person);
  }

  Future<bool> update(PeopleCompanion person) async {
    final updatedRows =
        await database.update(database.people).write(person);

    return updatedRows > 0;
  }

  Future<bool> deactivate(String id) async {
    final updatedRows = await (database.update(database.people)
          ..where((person) => person.id.equals(id)))
        .write(
      const PeopleCompanion(
        active: Value(false),
      ),
    );

    return updatedRows > 0;
  }
}