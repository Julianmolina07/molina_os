// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COP'),
  );
  static const VerificationMeta _legalOwnerMeta = const VerificationMeta(
    'legalOwner',
  );
  @override
  late final GeneratedColumn<int> legalOwner = GeneratedColumn<int>(
    'legal_owner',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _economicResponsibleMeta =
      const VerificationMeta('economicResponsible');
  @override
  late final GeneratedColumn<int> economicResponsible = GeneratedColumn<int>(
    'economic_responsible',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    currency,
    legalOwner,
    economicResponsible,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('legal_owner')) {
      context.handle(
        _legalOwnerMeta,
        legalOwner.isAcceptableOrUnknown(data['legal_owner']!, _legalOwnerMeta),
      );
    } else if (isInserting) {
      context.missing(_legalOwnerMeta);
    }
    if (data.containsKey('economic_responsible')) {
      context.handle(
        _economicResponsibleMeta,
        economicResponsible.isAcceptableOrUnknown(
          data['economic_responsible']!,
          _economicResponsibleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_economicResponsibleMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      legalOwner: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}legal_owner'],
      )!,
      economicResponsible: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}economic_responsible'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final int type;
  final String currency;
  final int legalOwner;
  final int economicResponsible;
  final bool active;
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.legalOwner,
    required this.economicResponsible,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<int>(type);
    map['currency'] = Variable<String>(currency);
    map['legal_owner'] = Variable<int>(legalOwner);
    map['economic_responsible'] = Variable<int>(economicResponsible);
    map['active'] = Variable<bool>(active);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      legalOwner: Value(legalOwner),
      economicResponsible: Value(economicResponsible),
      active: Value(active),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<int>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      legalOwner: serializer.fromJson<int>(json['legalOwner']),
      economicResponsible: serializer.fromJson<int>(
        json['economicResponsible'],
      ),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(type),
      'currency': serializer.toJson<String>(currency),
      'legalOwner': serializer.toJson<int>(legalOwner),
      'economicResponsible': serializer.toJson<int>(economicResponsible),
      'active': serializer.toJson<bool>(active),
    };
  }

  Account copyWith({
    String? id,
    String? name,
    int? type,
    String? currency,
    int? legalOwner,
    int? economicResponsible,
    bool? active,
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    legalOwner: legalOwner ?? this.legalOwner,
    economicResponsible: economicResponsible ?? this.economicResponsible,
    active: active ?? this.active,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      legalOwner: data.legalOwner.present
          ? data.legalOwner.value
          : this.legalOwner,
      economicResponsible: data.economicResponsible.present
          ? data.economicResponsible.value
          : this.economicResponsible,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('legalOwner: $legalOwner, ')
          ..write('economicResponsible: $economicResponsible, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    currency,
    legalOwner,
    economicResponsible,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.legalOwner == this.legalOwner &&
          other.economicResponsible == this.economicResponsible &&
          other.active == this.active);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> type;
  final Value<String> currency;
  final Value<int> legalOwner;
  final Value<int> economicResponsible;
  final Value<bool> active;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.legalOwner = const Value.absent(),
    this.economicResponsible = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required int type,
    this.currency = const Value.absent(),
    required int legalOwner,
    required int economicResponsible,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       legalOwner = Value(legalOwner),
       economicResponsible = Value(economicResponsible);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<String>? currency,
    Expression<int>? legalOwner,
    Expression<int>? economicResponsible,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (legalOwner != null) 'legal_owner': legalOwner,
      if (economicResponsible != null)
        'economic_responsible': economicResponsible,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? type,
    Value<String>? currency,
    Value<int>? legalOwner,
    Value<int>? economicResponsible,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      legalOwner: legalOwner ?? this.legalOwner,
      economicResponsible: economicResponsible ?? this.economicResponsible,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (legalOwner.present) {
      map['legal_owner'] = Variable<int>(legalOwner.value);
    }
    if (economicResponsible.present) {
      map['economic_responsible'] = Variable<int>(economicResponsible.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('legalOwner: $legalOwner, ')
          ..write('economicResponsible: $economicResponsible, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<int> context = GeneratedColumn<int>(
    'context',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    accountId,
    category,
    date,
    destinationAccountId,
    personId,
    debtId,
    context,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      ),
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}context'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final int type;
  final int amount;
  final String accountId;
  final int category;
  final DateTime date;
  final String? destinationAccountId;
  final String? personId;
  final String? debtId;
  final int? context;
  final String? note;
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.category,
    required this.date,
    this.destinationAccountId,
    this.personId,
    this.debtId,
    this.context,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<int>(type);
    map['amount'] = Variable<int>(amount);
    map['account_id'] = Variable<String>(accountId);
    map['category'] = Variable<int>(category);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    if (!nullToAbsent || debtId != null) {
      map['debt_id'] = Variable<String>(debtId);
    }
    if (!nullToAbsent || context != null) {
      map['context'] = Variable<int>(context);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      accountId: Value(accountId),
      category: Value(category),
      date: Value(date),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      debtId: debtId == null && nullToAbsent
          ? const Value.absent()
          : Value(debtId),
      context: context == null && nullToAbsent
          ? const Value.absent()
          : Value(context),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      accountId: serializer.fromJson<String>(json['accountId']),
      category: serializer.fromJson<int>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      personId: serializer.fromJson<String?>(json['personId']),
      debtId: serializer.fromJson<String?>(json['debtId']),
      context: serializer.fromJson<int?>(json['context']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<int>(type),
      'amount': serializer.toJson<int>(amount),
      'accountId': serializer.toJson<String>(accountId),
      'category': serializer.toJson<int>(category),
      'date': serializer.toJson<DateTime>(date),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'personId': serializer.toJson<String?>(personId),
      'debtId': serializer.toJson<String?>(debtId),
      'context': serializer.toJson<int?>(context),
      'note': serializer.toJson<String?>(note),
    };
  }

  Transaction copyWith({
    String? id,
    int? type,
    int? amount,
    String? accountId,
    int? category,
    DateTime? date,
    Value<String?> destinationAccountId = const Value.absent(),
    Value<String?> personId = const Value.absent(),
    Value<String?> debtId = const Value.absent(),
    Value<int?> context = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    accountId: accountId ?? this.accountId,
    category: category ?? this.category,
    date: date ?? this.date,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    personId: personId.present ? personId.value : this.personId,
    debtId: debtId.present ? debtId.value : this.debtId,
    context: context.present ? context.value : this.context,
    note: note.present ? note.value : this.note,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      personId: data.personId.present ? data.personId.value : this.personId,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      context: data.context.present ? data.context.value : this.context,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('personId: $personId, ')
          ..write('debtId: $debtId, ')
          ..write('context: $context, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    accountId,
    category,
    date,
    destinationAccountId,
    personId,
    debtId,
    context,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.category == this.category &&
          other.date == this.date &&
          other.destinationAccountId == this.destinationAccountId &&
          other.personId == this.personId &&
          other.debtId == this.debtId &&
          other.context == this.context &&
          other.note == this.note);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<int> type;
  final Value<int> amount;
  final Value<String> accountId;
  final Value<int> category;
  final Value<DateTime> date;
  final Value<String?> destinationAccountId;
  final Value<String?> personId;
  final Value<String?> debtId;
  final Value<int?> context;
  final Value<String?> note;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.personId = const Value.absent(),
    this.debtId = const Value.absent(),
    this.context = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required int type,
    required int amount,
    required String accountId,
    required int category,
    required DateTime date,
    this.destinationAccountId = const Value.absent(),
    this.personId = const Value.absent(),
    this.debtId = const Value.absent(),
    this.context = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amount = Value(amount),
       accountId = Value(accountId),
       category = Value(category),
       date = Value(date);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<int>? type,
    Expression<int>? amount,
    Expression<String>? accountId,
    Expression<int>? category,
    Expression<DateTime>? date,
    Expression<String>? destinationAccountId,
    Expression<String>? personId,
    Expression<String>? debtId,
    Expression<int>? context,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (personId != null) 'person_id': personId,
      if (debtId != null) 'debt_id': debtId,
      if (context != null) 'context': context,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? type,
    Value<int>? amount,
    Value<String>? accountId,
    Value<int>? category,
    Value<DateTime>? date,
    Value<String?>? destinationAccountId,
    Value<String?>? personId,
    Value<String?>? debtId,
    Value<int?>? context,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      date: date ?? this.date,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      personId: personId ?? this.personId,
      debtId: debtId ?? this.debtId,
      context: context ?? this.context,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (context.present) {
      map['context'] = Variable<int>(context.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('personId: $personId, ')
          ..write('debtId: $debtId, ')
          ..write('context: $context, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditorMeta = const VerificationMeta(
    'creditor',
  );
  @override
  late final GeneratedColumn<String> creditor = GeneratedColumn<String>(
    'creditor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalAmountMeta = const VerificationMeta(
    'originalAmount',
  );
  @override
  late final GeneratedColumn<int> originalAmount = GeneratedColumn<int>(
    'original_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingBalanceMeta = const VerificationMeta(
    'remainingBalance',
  );
  @override
  late final GeneratedColumn<int> remainingBalance = GeneratedColumn<int>(
    'remaining_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestRateMeta = const VerificationMeta(
    'interestRate',
  );
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
    'interest_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentAmountMeta = const VerificationMeta(
    'installmentAmount',
  );
  @override
  late final GeneratedColumn<int> installmentAmount = GeneratedColumn<int>(
    'installment_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    creditor,
    name,
    originalAmount,
    remainingBalance,
    interestRate,
    startDate,
    dueDate,
    installmentAmount,
    frequency,
    nextDueDate,
    status,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Debt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('creditor')) {
      context.handle(
        _creditorMeta,
        creditor.isAcceptableOrUnknown(data['creditor']!, _creditorMeta),
      );
    } else if (isInserting) {
      context.missing(_creditorMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('original_amount')) {
      context.handle(
        _originalAmountMeta,
        originalAmount.isAcceptableOrUnknown(
          data['original_amount']!,
          _originalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalAmountMeta);
    }
    if (data.containsKey('remaining_balance')) {
      context.handle(
        _remainingBalanceMeta,
        remainingBalance.isAcceptableOrUnknown(
          data['remaining_balance']!,
          _remainingBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingBalanceMeta);
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
        _interestRateMeta,
        interestRate.isAcceptableOrUnknown(
          data['interest_rate']!,
          _interestRateMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('installment_amount')) {
      context.handle(
        _installmentAmountMeta,
        installmentAmount.isAcceptableOrUnknown(
          data['installment_amount']!,
          _installmentAmountMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      creditor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creditor'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      originalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount'],
      )!,
      remainingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_balance'],
      )!,
      interestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      installmentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_amount'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      )!,
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final String id;

  /// Persona, banco, entidad o empresa a la que se debe.
  final String creditor;

  /// Nombre identificador de la deuda.
  final String name;

  /// Valor original de la deuda.
  final int originalAmount;

  /// Capital pendiente actualmente.
  final int remainingBalance;

  /// Tasa de interés anual en porcentaje.
  /// Ejemplo: 24.5 representa 24.5% E.A.
  final double interestRate;
  final DateTime startDate;
  final DateTime? dueDate;

  /// Valor habitual de la cuota.
  final int? installmentAmount;

  /// DebtFrequency:
  /// 0 = oneTime
  /// 1 = weekly
  /// 2 = biweekly
  /// 3 = monthly
  /// 4 = quarterly
  /// 5 = yearly
  final int frequency;
  final DateTime? nextDueDate;

  /// DebtStatus:
  /// 0 = active
  /// 1 = paid
  /// 2 = overdue
  /// 3 = cancelled
  final int status;
  final String? notes;
  const Debt({
    required this.id,
    required this.creditor,
    required this.name,
    required this.originalAmount,
    required this.remainingBalance,
    required this.interestRate,
    required this.startDate,
    this.dueDate,
    this.installmentAmount,
    required this.frequency,
    this.nextDueDate,
    required this.status,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['creditor'] = Variable<String>(creditor);
    map['name'] = Variable<String>(name);
    map['original_amount'] = Variable<int>(originalAmount);
    map['remaining_balance'] = Variable<int>(remainingBalance);
    map['interest_rate'] = Variable<double>(interestRate);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || installmentAmount != null) {
      map['installment_amount'] = Variable<int>(installmentAmount);
    }
    map['frequency'] = Variable<int>(frequency);
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate);
    }
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      creditor: Value(creditor),
      name: Value(name),
      originalAmount: Value(originalAmount),
      remainingBalance: Value(remainingBalance),
      interestRate: Value(interestRate),
      startDate: Value(startDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      installmentAmount: installmentAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentAmount),
      frequency: Value(frequency),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Debt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<String>(json['id']),
      creditor: serializer.fromJson<String>(json['creditor']),
      name: serializer.fromJson<String>(json['name']),
      originalAmount: serializer.fromJson<int>(json['originalAmount']),
      remainingBalance: serializer.fromJson<int>(json['remainingBalance']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      installmentAmount: serializer.fromJson<int?>(json['installmentAmount']),
      frequency: serializer.fromJson<int>(json['frequency']),
      nextDueDate: serializer.fromJson<DateTime?>(json['nextDueDate']),
      status: serializer.fromJson<int>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'creditor': serializer.toJson<String>(creditor),
      'name': serializer.toJson<String>(name),
      'originalAmount': serializer.toJson<int>(originalAmount),
      'remainingBalance': serializer.toJson<int>(remainingBalance),
      'interestRate': serializer.toJson<double>(interestRate),
      'startDate': serializer.toJson<DateTime>(startDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'installmentAmount': serializer.toJson<int?>(installmentAmount),
      'frequency': serializer.toJson<int>(frequency),
      'nextDueDate': serializer.toJson<DateTime?>(nextDueDate),
      'status': serializer.toJson<int>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Debt copyWith({
    String? id,
    String? creditor,
    String? name,
    int? originalAmount,
    int? remainingBalance,
    double? interestRate,
    DateTime? startDate,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<int?> installmentAmount = const Value.absent(),
    int? frequency,
    Value<DateTime?> nextDueDate = const Value.absent(),
    int? status,
    Value<String?> notes = const Value.absent(),
  }) => Debt(
    id: id ?? this.id,
    creditor: creditor ?? this.creditor,
    name: name ?? this.name,
    originalAmount: originalAmount ?? this.originalAmount,
    remainingBalance: remainingBalance ?? this.remainingBalance,
    interestRate: interestRate ?? this.interestRate,
    startDate: startDate ?? this.startDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    installmentAmount: installmentAmount.present
        ? installmentAmount.value
        : this.installmentAmount,
    frequency: frequency ?? this.frequency,
    nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
  );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      creditor: data.creditor.present ? data.creditor.value : this.creditor,
      name: data.name.present ? data.name.value : this.name,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      remainingBalance: data.remainingBalance.present
          ? data.remainingBalance.value
          : this.remainingBalance,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      installmentAmount: data.installmentAmount.present
          ? data.installmentAmount.value
          : this.installmentAmount,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('creditor: $creditor, ')
          ..write('name: $name, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('interestRate: $interestRate, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('installmentAmount: $installmentAmount, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    creditor,
    name,
    originalAmount,
    remainingBalance,
    interestRate,
    startDate,
    dueDate,
    installmentAmount,
    frequency,
    nextDueDate,
    status,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.creditor == this.creditor &&
          other.name == this.name &&
          other.originalAmount == this.originalAmount &&
          other.remainingBalance == this.remainingBalance &&
          other.interestRate == this.interestRate &&
          other.startDate == this.startDate &&
          other.dueDate == this.dueDate &&
          other.installmentAmount == this.installmentAmount &&
          other.frequency == this.frequency &&
          other.nextDueDate == this.nextDueDate &&
          other.status == this.status &&
          other.notes == this.notes);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<String> id;
  final Value<String> creditor;
  final Value<String> name;
  final Value<int> originalAmount;
  final Value<int> remainingBalance;
  final Value<double> interestRate;
  final Value<DateTime> startDate;
  final Value<DateTime?> dueDate;
  final Value<int?> installmentAmount;
  final Value<int> frequency;
  final Value<DateTime?> nextDueDate;
  final Value<int> status;
  final Value<String?> notes;
  final Value<int> rowid;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.creditor = const Value.absent(),
    this.name = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.remainingBalance = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.installmentAmount = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtsCompanion.insert({
    required String id,
    required String creditor,
    required String name,
    required int originalAmount,
    required int remainingBalance,
    this.interestRate = const Value.absent(),
    required DateTime startDate,
    this.dueDate = const Value.absent(),
    this.installmentAmount = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       creditor = Value(creditor),
       name = Value(name),
       originalAmount = Value(originalAmount),
       remainingBalance = Value(remainingBalance),
       startDate = Value(startDate);
  static Insertable<Debt> custom({
    Expression<String>? id,
    Expression<String>? creditor,
    Expression<String>? name,
    Expression<int>? originalAmount,
    Expression<int>? remainingBalance,
    Expression<double>? interestRate,
    Expression<DateTime>? startDate,
    Expression<DateTime>? dueDate,
    Expression<int>? installmentAmount,
    Expression<int>? frequency,
    Expression<DateTime>? nextDueDate,
    Expression<int>? status,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creditor != null) 'creditor': creditor,
      if (name != null) 'name': name,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (remainingBalance != null) 'remaining_balance': remainingBalance,
      if (interestRate != null) 'interest_rate': interestRate,
      if (startDate != null) 'start_date': startDate,
      if (dueDate != null) 'due_date': dueDate,
      if (installmentAmount != null) 'installment_amount': installmentAmount,
      if (frequency != null) 'frequency': frequency,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtsCompanion copyWith({
    Value<String>? id,
    Value<String>? creditor,
    Value<String>? name,
    Value<int>? originalAmount,
    Value<int>? remainingBalance,
    Value<double>? interestRate,
    Value<DateTime>? startDate,
    Value<DateTime?>? dueDate,
    Value<int?>? installmentAmount,
    Value<int>? frequency,
    Value<DateTime?>? nextDueDate,
    Value<int>? status,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      creditor: creditor ?? this.creditor,
      name: name ?? this.name,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (creditor.present) {
      map['creditor'] = Variable<String>(creditor.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<int>(originalAmount.value);
    }
    if (remainingBalance.present) {
      map['remaining_balance'] = Variable<int>(remainingBalance.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (installmentAmount.present) {
      map['installment_amount'] = Variable<int>(installmentAmount.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('creditor: $creditor, ')
          ..write('name: $name, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('interestRate: $interestRate, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('installmentAmount: $installmentAmount, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    transactions,
    debts,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String name,
  required int type,
  Value<String> currency,
  required int legalOwner,
  required int economicResponsible,
  Value<bool> active,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> type,
  Value<String> currency,
  Value<int> legalOwner,
  Value<int> economicResponsible,
  Value<bool> active,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legalOwner => $composableBuilder(
    column: $table.legalOwner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get economicResponsible => $composableBuilder(
    column: $table.economicResponsible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legalOwner => $composableBuilder(
    column: $table.legalOwner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get economicResponsible => $composableBuilder(
    column: $table.economicResponsible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get legalOwner => $composableBuilder(
    column: $table.legalOwner,
    builder: (column) => column,
  );

  GeneratedColumn<int> get economicResponsible => $composableBuilder(
    column: $table.economicResponsible,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> legalOwner = const Value.absent(),
                Value<int> economicResponsible = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                type: type,
                currency: currency,
                legalOwner: legalOwner,
                economicResponsible: economicResponsible,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int type,
                Value<String> currency = const Value.absent(),
                required int legalOwner,
                required int economicResponsible,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                type: type,
                currency: currency,
                legalOwner: legalOwner,
                economicResponsible: economicResponsible,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  BaseReferences<_$AppDatabase, $AccountsTable, Account>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required int type,
      required int amount,
      required String accountId,
      required int category,
      required DateTime date,
      Value<String?> destinationAccountId,
      Value<String?> personId,
      Value<String?> debtId,
      Value<int?> context,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<int> type,
      Value<int> amount,
      Value<String> accountId,
      Value<int> category,
      Value<DateTime> date,
      Value<String?> destinationAccountId,
      Value<String?> personId,
      Value<String?> debtId,
      Value<int?> context,
      Value<String?> note,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get debtId => $composableBuilder(
    column: $table.debtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get debtId => $composableBuilder(
    column: $table.debtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get debtId =>
      $composableBuilder(column: $table.debtId, builder: (column) => column);

  GeneratedColumn<int> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> category = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String?> debtId = const Value.absent(),
                Value<int?> context = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                type: type,
                amount: amount,
                accountId: accountId,
                category: category,
                date: date,
                destinationAccountId: destinationAccountId,
                personId: personId,
                debtId: debtId,
                context: context,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int type,
                required int amount,
                required String accountId,
                required int category,
                required DateTime date,
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String?> debtId = const Value.absent(),
                Value<int?> context = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                accountId: accountId,
                category: category,
                date: date,
                destinationAccountId: destinationAccountId,
                personId: personId,
                debtId: debtId,
                context: context,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, Transaction>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TransactionsTable,
                    Transaction
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$DebtsTableCreateCompanionBuilder = DebtsCompanion Function({
  required String id,
  required String creditor,
  required String name,
  required int originalAmount,
  required int remainingBalance,
  Value<double> interestRate,
  required DateTime startDate,
  Value<DateTime?> dueDate,
  Value<int?> installmentAmount,
  Value<int> frequency,
  Value<DateTime?> nextDueDate,
  Value<int> status,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$DebtsTableUpdateCompanionBuilder = DebtsCompanion Function({
  Value<String> id,
  Value<String> creditor,
  Value<String> name,
  Value<int> originalAmount,
  Value<int> remainingBalance,
  Value<double> interestRate,
  Value<DateTime> startDate,
  Value<DateTime?> dueDate,
  Value<int?> installmentAmount,
  Value<int> frequency,
  Value<DateTime?> nextDueDate,
  Value<int> status,
  Value<String?> notes,
  Value<int> rowid,
});

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creditor => $composableBuilder(
    column: $table.creditor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentAmount => $composableBuilder(
    column: $table.installmentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creditor => $composableBuilder(
    column: $table.creditor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentAmount => $composableBuilder(
    column: $table.installmentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get creditor =>
      $composableBuilder(column: $table.creditor, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get installmentAmount => $composableBuilder(
    column: $table.installmentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          Debt,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
          Debt,
          PrefetchHooks Function()
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> creditor = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> originalAmount = const Value.absent(),
                Value<int> remainingBalance = const Value.absent(),
                Value<double> interestRate = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int?> installmentAmount = const Value.absent(),
                Value<int> frequency = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                creditor: creditor,
                name: name,
                originalAmount: originalAmount,
                remainingBalance: remainingBalance,
                interestRate: interestRate,
                startDate: startDate,
                dueDate: dueDate,
                installmentAmount: installmentAmount,
                frequency: frequency,
                nextDueDate: nextDueDate,
                status: status,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String creditor,
                required String name,
                required int originalAmount,
                required int remainingBalance,
                Value<double> interestRate = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int?> installmentAmount = const Value.absent(),
                Value<int> frequency = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion.insert(
                id: id,
                creditor: creditor,
                name: name,
                originalAmount: originalAmount,
                remainingBalance: remainingBalance,
                interestRate: interestRate,
                startDate: startDate,
                dueDate: dueDate,
                installmentAmount: installmentAmount,
                frequency: frequency,
                nextDueDate: nextDueDate,
                status: status,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DebtsTable, Debt>(table),
                  BaseReferences<_$AppDatabase, $DebtsTable, Debt>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      Debt,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
      Debt,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
}
