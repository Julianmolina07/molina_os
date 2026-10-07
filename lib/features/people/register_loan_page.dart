import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/account_repository.dart';
import '../../services/loan_service.dart';

class RegisterLoanPage extends StatefulWidget {
  final PeopleData person;

  const RegisterLoanPage({
    super.key,
    required this.person,
  });

  @override
  State<RegisterLoanPage> createState() =>
      _RegisterLoanPageState();
}

class _RegisterLoanPageState extends State<RegisterLoanPage> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _accountRepository = AccountRepository(
    DatabaseProvider.instance,
  );

  final _loanService = LoanService(
    DatabaseProvider.instance,
  );

  String? _selectedAccountId;
  DateTime _startDate = DateTime.now();
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _parseAmount(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return 0;
    }

    return int.tryParse(digits) ?? 0;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _startDate = selected;
    });
  }

  Future<void> _selectDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _dueDate = selected;
    });
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona la cuenta desde la que prestarás el dinero.',
          ),
        ),
      );
      return;
    }

    final amount = _parseAmount(_amountController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El valor del préstamo debe ser mayor que cero.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _loanService.registerLoan(
        personId: widget.person.id,
        accountId: _selectedAccountId!,
        amount: amount,
        startDate: _startDate,
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

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
            'No se pudo registrar el préstamo: $error',
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
        title: const Text('Prestar dinero'),
      ),
      body: StreamBuilder<List<Account>>(
        stream: _accountRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las cuentas.\n\n'
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

          final accounts = snapshot.data!
              .where((account) => account.type != 2)
              .toList();

          if (_selectedAccountId != null &&
              !accounts.any(
                (account) =>
                    account.id == _selectedAccountId,
              )) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedAccountId = null;
                });
              }
            });
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                32,
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_outline,
                          color:
                              colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prestar a',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.60),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.person.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Valor del préstamo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: _amountController,
                  enabled: !_saving,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    labelText: 'Monto',
                    hintText: '100.000',
                    prefixIcon:
                        Icon(Icons.attach_money_outlined),
                  ),
                  validator: (value) {
                    final amount = _parseAmount(value ?? '');

                    if (amount <= 0) {
                      return 'Escribe un monto válido.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 22),

                Text(
                  'Cuenta de salida',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 10),

                if (accounts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'No tienes cuentas disponibles para realizar '
                      'el préstamo.',
                      style: TextStyle(
                        color:
                            colorScheme.onErrorContainer,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Cuenta',
                      prefixIcon:
                          Icon(Icons.account_balance_outlined),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedAccountId = value;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona una cuenta.';
                      }

                      return null;
                    },
                  ),

                const SizedBox(height: 22),

                Text(
                  'Fechas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                    ),
                    title: const Text('Fecha del préstamo'),
                    subtitle: Text(
                      _formatDate(_startDate),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: _saving
                        ? null
                        : _selectStartDate,
                  ),
                ),

                const SizedBox(height: 8),

                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(
                      Icons.event_outlined,
                    ),
                    title: const Text('Fecha límite'),
                    subtitle: Text(
                      _dueDate == null
                          ? 'Sin fecha límite'
                          : _formatDate(_dueDate!),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: _saving
                        ? null
                        : _selectDueDate,
                  ),
                ),

                if (_dueDate != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _saving
                          ? null
                          : () {
                              setState(() {
                                _dueDate = null;
                              });
                            },
                      child: const Text(
                        'Quitar fecha límite',
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                Text(
                  'Notas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: _notesController,
                  enabled: !_saving,
                  maxLines: 4,
                  textCapitalization:
                      TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Nota opcional',
                      hintText:
                          'Ej. Préstamo para reparación del carro',
                      prefixIcon:
                          const Icon(Icons.notes_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed:
                        _saving || accounts.isEmpty
                            ? null
                            : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons
                                .account_balance_wallet_outlined,
                          ),
                    label: Text(
                      _saving
                          ? 'Registrando...'
                          : 'Registrar préstamo',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
