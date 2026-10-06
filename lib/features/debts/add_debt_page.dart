import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/debt_repository.dart';

class AddDebtPage extends StatefulWidget {
  const AddDebtPage({super.key});

  @override
  State<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  final _formKey = GlobalKey<FormState>();

  final _creditorController = TextEditingController();
  final _nameController = TextEditingController();
  final _originalAmountController = TextEditingController();
  final _remainingBalanceController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _installmentAmountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _dueDate;
  DateTime? _nextDueDate;

  int _frequency = 3;

  bool _isSaving = false;

  @override
  void dispose() {
    _creditorController.dispose();
    _nameController.dispose();
    _originalAmountController.dispose();
    _remainingBalanceController.dispose();
    _interestRateController.dispose();
    _installmentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Nueva deuda',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información de la deuda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _creditorController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Acreedor',
                    hintText: 'Ej. Banco, persona o entidad',
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Ingresa el acreedor';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la deuda',
                    hintText: 'Ej. Tarjeta de crédito',
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.description_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Ingresa el nombre de la deuda';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 26),
                Text(
                  'Valores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _originalAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor original',
                    hintText: 'Ej. 8000000',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateAmount,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _remainingBalanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Saldo pendiente',
                    hintText: 'Ej. 5400000',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateRemainingBalance,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _installmentAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor de la cuota',
                    hintText: 'Ej. 450000',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateOptionalAmount,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _interestRateController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Interés anual',
                    hintText: 'Ej. 25.5',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateInterestRate,
                ),
                const SizedBox(height: 26),
                Text(
                  'Fechas y frecuencia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                _DateField(
                  label: 'Fecha de inicio',
                  value: _formatDate(_startDate),
                  onTap: () => _selectDate(
                    initialDate: _startDate,
                    onSelected: (date) {
                      setState(() {
                        _startDate = date;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _DateField(
                  label: 'Fecha de vencimiento',
                  value: _dueDate == null
                      ? 'No definida'
                      : _formatDate(_dueDate!),
                  onTap: () => _selectDate(
                    initialDate:
                        _dueDate ?? _startDate,
                    onSelected: (date) {
                      setState(() {
                        _dueDate = date;
                      });
                    },
                  ),
                  trailing: _dueDate == null
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _dueDate = null;
                            });
                          },
                          icon: const Icon(
                            Icons.clear_rounded,
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                _DateField(
                  label: 'Próximo pago',
                  value: _nextDueDate == null
                      ? 'No definido'
                      : _formatDate(_nextDueDate!),
                  onTap: () => _selectDate(
                    initialDate:
                        _nextDueDate ?? _startDate,
                    onSelected: (date) {
                      setState(() {
                        _nextDueDate = date;
                      });
                    },
                  ),
                  trailing: _nextDueDate == null
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _nextDueDate = null;
                            });
                          },
                          icon: const Icon(
                            Icons.clear_rounded,
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia',
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.repeat_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Una sola vez'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Semanal'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Quincenal'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('Mensual'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('Trimestral'),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text('Anual'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _frequency = value;
                    });
                  },
                ),
                const SizedBox(height: 26),
                Text(
                  'Notas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _notesController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notas adicionales',
                    hintText:
                        'Información importante sobre esta deuda...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSaving ? null : _saveDebt,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.save_rounded,
                          ),
                    label: Text(
                      _isSaving
                          ? 'Guardando...'
                          : 'Guardar deuda',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDebt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final originalAmount = _parseInteger(
      _originalAmountController.text,
    );

    final remainingBalance = _parseInteger(
      _remainingBalanceController.text,
    );

    if (remainingBalance > originalAmount) {
      _showError(
        'El saldo pendiente no puede ser mayor '
        'que el valor original.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final debtRepository =
          DebtRepository(DatabaseProvider.instance);

      final interestRate =
          double.tryParse(
                _interestRateController.text
                    .trim()
                    .replaceAll(',', '.'),
              ) ??
              0;

      final installmentText =
          _installmentAmountController.text.trim();

      final installmentAmount =
          installmentText.isEmpty
              ? null
              : _parseInteger(installmentText);

      final notes = _notesController.text.trim();

      await debtRepository.create(
        DebtsCompanion.insert(
          id: DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
          creditor: _creditorController.text.trim(),
          name: _nameController.text.trim(),
          originalAmount: originalAmount,
          remainingBalance: remainingBalance,
          interestRate: Value(interestRate),
          startDate: _startDate,
          dueDate: Value(_dueDate),
          installmentAmount:
              Value(installmentAmount),
          frequency: Value(_frequency),
          nextDueDate: Value(_nextDueDate),
          status: const Value(0),
          notes: Value(
            notes.isEmpty ? null : notes,
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

      _showError(
        'No se pudo guardar la deuda.\n$error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa un valor';
    }

    final amount = _parseInteger(value);

    if (amount <= 0) {
      return 'Debe ser mayor que \$0';
    }

    return null;
  }

  String? _validateRemainingBalance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el saldo pendiente';
    }

    final amount = _parseInteger(value);

    if (amount < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  String? _validateOptionalAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final amount = _parseInteger(value);

    if (amount <= 0) {
      return 'Debe ser mayor que \$0';
    }

    return null;
  }

  String? _validateInterestRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final rate = double.tryParse(
      value.trim().replaceAll(',', '.'),
    );

    if (rate == null || rate < 0) {
      return 'Ingresa una tasa válida';
    }

    return null;
  }

  int _parseInteger(String value) {
    return int.tryParse(
          value
              .trim()
              .replaceAll('.', '')
              .replaceAll(',', ''),
        ) ??
        0;
  }

  Future<void> _selectDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();

    final firstDate = DateTime(
      now.year - 20,
      1,
      1,
    );

    final lastDate = DateTime(
      now.year + 30,
      12,
      31,
    );

    final safeInitialDate = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate.isAfter(lastDate)
            ? lastDate
            : initialDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      onSelected(selectedDate);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(
            Icons.calendar_today_rounded,
          ),
          suffixIcon: trailing,
        ),
        child: Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}