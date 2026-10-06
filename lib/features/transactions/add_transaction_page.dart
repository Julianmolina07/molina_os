import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/transaction_repository.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final _accountRepository =
      AccountRepository(DatabaseProvider.instance);

  final _transactionRepository =
      TransactionRepository(DatabaseProvider.instance);

  int _type = 0;
  int _category = 0;
  String? _accountId;
  String? _destinationAccountId;
  int _context = 0;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _date = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una cuenta.'),
        ),
      );
      return;
    }

    if (_type == 2 &&
        (_destinationAccountId == null ||
            _destinationAccountId == _accountId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona una cuenta de destino diferente.',
          ),
        ),
      );
      return;
    }

    final amount = int.tryParse(
      _amountController.text
          .replaceAll('.', '')
          .replaceAll(',', ''),
    );

    if (amount == null || amount <= 0) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final id =
          DateTime.now().microsecondsSinceEpoch.toString();

      await _transactionRepository.create(
        TransactionsCompanion.insert(
          id: id,
          type: _type,
          amount: amount,
          accountId: _accountId!,
          category: _category,
          date: _date,
          destinationAccountId:
              _type == 2
                  ? Value(_destinationAccountId)
                  : const Value(null),
          context: Value(_context),
          note: Value(
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar el movimiento: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar movimiento'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Account>>(
          stream: _accountRepository.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar las cuentas:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final accounts = snapshot.data!;

            if (accounts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Primero debes crear una cuenta para '
                    'registrar un movimiento.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            _accountId ??= accounts.first.id;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Nuevo movimiento',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra ingresos, gastos o transferencias '
                    'para mantener actualizado tu dinero.',
                    style:
                        Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),

                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        icon: Icon(
                          Icons.arrow_downward_rounded,
                        ),
                        label: Text('Ingreso'),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                        ),
                        label: Text('Gasto'),
                      ),
                      ButtonSegment(
                        value: 2,
                        icon: Icon(
                          Icons.swap_horiz_rounded,
                        ),
                        label: Text('Transferencia'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _type = selection.first;

                        if (_type != 2) {
                          _destinationAccountId = null;
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      hintText: '\$50.000',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = int.tryParse(
                        (value ?? '')
                            .replaceAll('.', '')
                            .replaceAll(',', ''),
                      );

                      if (amount == null || amount <= 0) {
                        return 'Ingresa un monto válido.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    initialValue: _accountId,
                    decoration: const InputDecoration(
                      labelText: 'Cuenta de origen',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _accountId = value;

                        if (_destinationAccountId == value) {
                          _destinationAccountId = null;
                        }
                      });
                    },
                  ),

                  if (_type == 2) ...[
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      initialValue: _destinationAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Cuenta de destino',
                        border: OutlineInputBorder(),
                      ),
                      items: accounts
                          .where(
                            (account) =>
                                account.id != _accountId,
                          )
                          .map((account) {
                        return DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _destinationAccountId = value;
                        });
                      },
                      validator: (value) {
                        if (_type == 2 && value == null) {
                          return 'Selecciona una cuenta de destino.';
                        }

                        return null;
                      },
                    ),
                  ],

                  if (_type != 2) ...[
                    const SizedBox(height: 20),

                    DropdownButtonFormField<int>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Alimentación'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Gasolina'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Entretenimiento'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Salida'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('Viaje'),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('Vehículo'),
                        ),
                        DropdownMenuItem(
                          value: 6,
                          child: Text('Facturas'),
                        ),
                        DropdownMenuItem(
                          value: 7,
                          child: Text('Compras'),
                        ),
                        DropdownMenuItem(
                          value: 8,
                          child: Text('Salud'),
                        ),
                        DropdownMenuItem(
                          value: 9,
                          child: Text('Educación'),
                        ),
                        DropdownMenuItem(
                          value: 10,
                          child: Text('Familia'),
                        ),
                        DropdownMenuItem(
                          value: 11,
                          child: Text('Trabajo'),
                        ),
                        DropdownMenuItem(
                          value: 12,
                          child: Text('Deuda'),
                        ),
                        DropdownMenuItem(
                          value: 13,
                          child: Text('Otro'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _category = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<int>(
                      initialValue: _context,
                      decoration: const InputDecoration(
                        labelText: 'Contexto',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Solo'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Pareja'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Amigos'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Familia'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('Trabajo'),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('Otro'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _context = value;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today_rounded,
                    ),
                    title: const Text('Fecha'),
                    subtitle: Text(
                      '${_date.day.toString().padLeft(2, '0')}/'
                      '${_date.month.toString().padLeft(2, '0')}/'
                      '${_date.year}',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                    onTap: _selectDate,
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nota',
                      hintText: 'Opcional',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed:
                          _saving ? null : _saveTransaction,
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar movimiento',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}