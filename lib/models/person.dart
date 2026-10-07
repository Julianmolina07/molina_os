class Person {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final bool active;

  const Person({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    this.active = true,
  });
}