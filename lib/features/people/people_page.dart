import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/person_repository.dart';
import 'person_detail_page.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final _repository =
      PersonRepository(DatabaseProvider.instance);

  Future<void> _showPersonDialog({
    PeopleData? person,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _PersonDialog(
          person: person,
          repository: _repository,
        );
      },
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deactivatePerson(
    PeopleData person,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Desactivar persona'),
          content: Text(
            '¿Quieres desactivar a ${person.name}? '
            'Sus préstamos e historial no se eliminarán.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repository.deactivate(person.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${person.name} fue desactivada.',
          ),
        ),
      );

      setState(() {});
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo desactivar la persona: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPersonDialog(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Agregar'),
      ),
      body: StreamBuilder<List<PeopleData>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las personas.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final people = snapshot.data!;

          if (people.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: colorScheme.onSurface
                          .withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Todavía no tienes personas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega una persona para registrar '
                      'préstamos y llevar el control de lo que '
                      'te deben.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface
                            .withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              100,
            ),
            itemCount: people.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final person = people[index];

              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline,
                      color:
                          colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    person.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: person.phone != null &&
                          person.phone!.trim().isNotEmpty
                      ? Text(person.phone!)
                      : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PersonDetailPage(
                          person: person,
                        ),
                      ),
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showPersonDialog(
                          person: person,
                        );
                      }

                      if (value == 'deactivate') {
                        _deactivatePerson(person);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem(
                        value: 'deactivate',
                        child: Text('Desactivar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PersonDialog extends StatefulWidget {
  final PeopleData? person;
  final PersonRepository repository;

  const _PersonDialog({
    required this.person,
    required this.repository,
  });

  @override
  State<_PersonDialog> createState() =>
      _PersonDialogState();
}

class _PersonDialogState extends State<_PersonDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  final _formKey = GlobalKey<FormState>();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.person?.name ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.person?.phone ?? '',
    );

    _notesController = TextEditingController(
      text: widget.person?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final notes = _notesController.text.trim();

      if (widget.person == null) {
        final id =
            'person-${DateTime.now().microsecondsSinceEpoch}';

        await widget.repository.create(
          PeopleCompanion.insert(
            id: id,
            name: name,
            phone: Value(
              phone.isEmpty ? null : phone,
            ),
            notes: Value(
              notes.isEmpty ? null : notes,
            ),
          ),
        );
      } else {
        await widget.repository.update(
          PeopleCompanion(
            id: Value(widget.person!.id),
            name: Value(name),
            phone: Value(
              phone.isEmpty ? null : phone,
            ),
            notes: Value(
              notes.isEmpty ? null : notes,
            ),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar la persona: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.person != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? 'Editar persona'
            : 'Nueva persona',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_saving,
                autofocus: !isEditing,
                textCapitalization:
                    TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon:
                      Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Escribe el nombre.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                enabled: !_saving,
                keyboardType:
                    TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon:
                      Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                enabled: !_saving,
                maxLines: 3,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  prefixIcon:
                      Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}