// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StoredTransactionsTable extends StoredTransactions
    with TableInfo<$StoredTransactionsTable, StoredTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeKeyMeta = const VerificationMeta(
    'typeKey',
  );
  @override
  late final GeneratedColumn<String> typeKey = GeneratedColumn<String>(
    'type_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodKeyMeta = const VerificationMeta(
    'paymentMethodKey',
  );
  @override
  late final GeneratedColumn<String> paymentMethodKey = GeneratedColumn<String>(
    'payment_method_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMicrosMeta =
      const VerificationMeta('occurredAtUtcMicros');
  @override
  late final GeneratedColumn<int> occurredAtUtcMicros = GeneratedColumn<int>(
    'occurred_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMicrosMeta =
      const VerificationMeta('updatedAtUtcMicros');
  @override
  late final GeneratedColumn<int> updatedAtUtcMicros = GeneratedColumn<int>(
    'updated_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guest'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    typeKey,
    amountMinorUnits,
    currencyCode,
    categoryKey,
    paymentMethodKey,
    occurredAtUtcMicros,
    merchant,
    note,
    createdAtUtcMicros,
    updatedAtUtcMicros,
    ownerScope,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type_key')) {
      context.handle(
        _typeKeyMeta,
        typeKey.isAcceptableOrUnknown(data['type_key']!, _typeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_typeKeyMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('payment_method_key')) {
      context.handle(
        _paymentMethodKeyMeta,
        paymentMethodKey.isAcceptableOrUnknown(
          data['payment_method_key']!,
          _paymentMethodKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodKeyMeta);
    }
    if (data.containsKey('occurred_at_utc_micros')) {
      context.handle(
        _occurredAtUtcMicrosMeta,
        occurredAtUtcMicros.isAcceptableOrUnknown(
          data['occurred_at_utc_micros']!,
          _occurredAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMicrosMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    if (data.containsKey('updated_at_utc_micros')) {
      context.handle(
        _updatedAtUtcMicrosMeta,
        updatedAtUtcMicros.isAcceptableOrUnknown(
          data['updated_at_utc_micros']!,
          _updatedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMicrosMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      typeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_key'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      paymentMethodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_key'],
      )!,
      occurredAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_utc_micros'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
      updatedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_micros'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
    );
  }

  @override
  $StoredTransactionsTable createAlias(String alias) {
    return $StoredTransactionsTable(attachedDatabase, alias);
  }
}

class StoredTransaction extends DataClass
    implements Insertable<StoredTransaction> {
  final String id;
  final String typeKey;
  final int amountMinorUnits;
  final String currencyCode;
  final String categoryKey;
  final String paymentMethodKey;
  final int occurredAtUtcMicros;
  final String? merchant;
  final String? note;
  final int createdAtUtcMicros;
  final int updatedAtUtcMicros;
  final String ownerScope;
  const StoredTransaction({
    required this.id,
    required this.typeKey,
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.categoryKey,
    required this.paymentMethodKey,
    required this.occurredAtUtcMicros,
    this.merchant,
    this.note,
    required this.createdAtUtcMicros,
    required this.updatedAtUtcMicros,
    required this.ownerScope,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type_key'] = Variable<String>(typeKey);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['category_key'] = Variable<String>(categoryKey);
    map['payment_method_key'] = Variable<String>(paymentMethodKey);
    map['occurred_at_utc_micros'] = Variable<int>(occurredAtUtcMicros);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros);
    map['owner_scope'] = Variable<String>(ownerScope);
    return map;
  }

  StoredTransactionsCompanion toCompanion(bool nullToAbsent) {
    return StoredTransactionsCompanion(
      id: Value(id),
      typeKey: Value(typeKey),
      amountMinorUnits: Value(amountMinorUnits),
      currencyCode: Value(currencyCode),
      categoryKey: Value(categoryKey),
      paymentMethodKey: Value(paymentMethodKey),
      occurredAtUtcMicros: Value(occurredAtUtcMicros),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtUtcMicros: Value(createdAtUtcMicros),
      updatedAtUtcMicros: Value(updatedAtUtcMicros),
      ownerScope: Value(ownerScope),
    );
  }

  factory StoredTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredTransaction(
      id: serializer.fromJson<String>(json['id']),
      typeKey: serializer.fromJson<String>(json['typeKey']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      paymentMethodKey: serializer.fromJson<String>(json['paymentMethodKey']),
      occurredAtUtcMicros: serializer.fromJson<int>(
        json['occurredAtUtcMicros'],
      ),
      merchant: serializer.fromJson<String?>(json['merchant']),
      note: serializer.fromJson<String?>(json['note']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
      updatedAtUtcMicros: serializer.fromJson<int>(json['updatedAtUtcMicros']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'typeKey': serializer.toJson<String>(typeKey),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'paymentMethodKey': serializer.toJson<String>(paymentMethodKey),
      'occurredAtUtcMicros': serializer.toJson<int>(occurredAtUtcMicros),
      'merchant': serializer.toJson<String?>(merchant),
      'note': serializer.toJson<String?>(note),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
      'updatedAtUtcMicros': serializer.toJson<int>(updatedAtUtcMicros),
      'ownerScope': serializer.toJson<String>(ownerScope),
    };
  }

  StoredTransaction copyWith({
    String? id,
    String? typeKey,
    int? amountMinorUnits,
    String? currencyCode,
    String? categoryKey,
    String? paymentMethodKey,
    int? occurredAtUtcMicros,
    Value<String?> merchant = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAtUtcMicros,
    int? updatedAtUtcMicros,
    String? ownerScope,
  }) => StoredTransaction(
    id: id ?? this.id,
    typeKey: typeKey ?? this.typeKey,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    categoryKey: categoryKey ?? this.categoryKey,
    paymentMethodKey: paymentMethodKey ?? this.paymentMethodKey,
    occurredAtUtcMicros: occurredAtUtcMicros ?? this.occurredAtUtcMicros,
    merchant: merchant.present ? merchant.value : this.merchant,
    note: note.present ? note.value : this.note,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
    updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
    ownerScope: ownerScope ?? this.ownerScope,
  );
  StoredTransaction copyWithCompanion(StoredTransactionsCompanion data) {
    return StoredTransaction(
      id: data.id.present ? data.id.value : this.id,
      typeKey: data.typeKey.present ? data.typeKey.value : this.typeKey,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      paymentMethodKey: data.paymentMethodKey.present
          ? data.paymentMethodKey.value
          : this.paymentMethodKey,
      occurredAtUtcMicros: data.occurredAtUtcMicros.present
          ? data.occurredAtUtcMicros.value
          : this.occurredAtUtcMicros,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      note: data.note.present ? data.note.value : this.note,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
      updatedAtUtcMicros: data.updatedAtUtcMicros.present
          ? data.updatedAtUtcMicros.value
          : this.updatedAtUtcMicros,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredTransaction(')
          ..write('id: $id, ')
          ..write('typeKey: $typeKey, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('paymentMethodKey: $paymentMethodKey, ')
          ..write('occurredAtUtcMicros: $occurredAtUtcMicros, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('ownerScope: $ownerScope')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    typeKey,
    amountMinorUnits,
    currencyCode,
    categoryKey,
    paymentMethodKey,
    occurredAtUtcMicros,
    merchant,
    note,
    createdAtUtcMicros,
    updatedAtUtcMicros,
    ownerScope,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredTransaction &&
          other.id == this.id &&
          other.typeKey == this.typeKey &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.categoryKey == this.categoryKey &&
          other.paymentMethodKey == this.paymentMethodKey &&
          other.occurredAtUtcMicros == this.occurredAtUtcMicros &&
          other.merchant == this.merchant &&
          other.note == this.note &&
          other.createdAtUtcMicros == this.createdAtUtcMicros &&
          other.updatedAtUtcMicros == this.updatedAtUtcMicros &&
          other.ownerScope == this.ownerScope);
}

class StoredTransactionsCompanion extends UpdateCompanion<StoredTransaction> {
  final Value<String> id;
  final Value<String> typeKey;
  final Value<int> amountMinorUnits;
  final Value<String> currencyCode;
  final Value<String> categoryKey;
  final Value<String> paymentMethodKey;
  final Value<int> occurredAtUtcMicros;
  final Value<String?> merchant;
  final Value<String?> note;
  final Value<int> createdAtUtcMicros;
  final Value<int> updatedAtUtcMicros;
  final Value<String> ownerScope;
  final Value<int> rowid;
  const StoredTransactionsCompanion({
    this.id = const Value.absent(),
    this.typeKey = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.paymentMethodKey = const Value.absent(),
    this.occurredAtUtcMicros = const Value.absent(),
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.updatedAtUtcMicros = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredTransactionsCompanion.insert({
    required String id,
    required String typeKey,
    required int amountMinorUnits,
    required String currencyCode,
    required String categoryKey,
    required String paymentMethodKey,
    required int occurredAtUtcMicros,
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAtUtcMicros,
    required int updatedAtUtcMicros,
    this.ownerScope = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       typeKey = Value(typeKey),
       amountMinorUnits = Value(amountMinorUnits),
       currencyCode = Value(currencyCode),
       categoryKey = Value(categoryKey),
       paymentMethodKey = Value(paymentMethodKey),
       occurredAtUtcMicros = Value(occurredAtUtcMicros),
       createdAtUtcMicros = Value(createdAtUtcMicros),
       updatedAtUtcMicros = Value(updatedAtUtcMicros);
  static Insertable<StoredTransaction> custom({
    Expression<String>? id,
    Expression<String>? typeKey,
    Expression<int>? amountMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? categoryKey,
    Expression<String>? paymentMethodKey,
    Expression<int>? occurredAtUtcMicros,
    Expression<String>? merchant,
    Expression<String>? note,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? updatedAtUtcMicros,
    Expression<String>? ownerScope,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeKey != null) 'type_key': typeKey,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (categoryKey != null) 'category_key': categoryKey,
      if (paymentMethodKey != null) 'payment_method_key': paymentMethodKey,
      if (occurredAtUtcMicros != null)
        'occurred_at_utc_micros': occurredAtUtcMicros,
      if (merchant != null) 'merchant': merchant,
      if (note != null) 'note': note,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (updatedAtUtcMicros != null)
        'updated_at_utc_micros': updatedAtUtcMicros,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? typeKey,
    Value<int>? amountMinorUnits,
    Value<String>? currencyCode,
    Value<String>? categoryKey,
    Value<String>? paymentMethodKey,
    Value<int>? occurredAtUtcMicros,
    Value<String?>? merchant,
    Value<String?>? note,
    Value<int>? createdAtUtcMicros,
    Value<int>? updatedAtUtcMicros,
    Value<String>? ownerScope,
    Value<int>? rowid,
  }) {
    return StoredTransactionsCompanion(
      id: id ?? this.id,
      typeKey: typeKey ?? this.typeKey,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryKey: categoryKey ?? this.categoryKey,
      paymentMethodKey: paymentMethodKey ?? this.paymentMethodKey,
      occurredAtUtcMicros: occurredAtUtcMicros ?? this.occurredAtUtcMicros,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
      ownerScope: ownerScope ?? this.ownerScope,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (typeKey.present) {
      map['type_key'] = Variable<String>(typeKey.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (paymentMethodKey.present) {
      map['payment_method_key'] = Variable<String>(paymentMethodKey.value);
    }
    if (occurredAtUtcMicros.present) {
      map['occurred_at_utc_micros'] = Variable<int>(occurredAtUtcMicros.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (updatedAtUtcMicros.present) {
      map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('typeKey: $typeKey, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('paymentMethodKey: $paymentMethodKey, ')
          ..write('occurredAtUtcMicros: $occurredAtUtcMicros, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredPreferencesTable extends StoredPreferences
    with TableInfo<$StoredPreferencesTable, StoredPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  StoredPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $StoredPreferencesTable createAlias(String alias) {
    return $StoredPreferencesTable(attachedDatabase, alias);
  }
}

class StoredPreference extends DataClass
    implements Insertable<StoredPreference> {
  final String key;
  final String value;
  const StoredPreference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  StoredPreferencesCompanion toCompanion(bool nullToAbsent) {
    return StoredPreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory StoredPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  StoredPreference copyWith({String? key, String? value}) =>
      StoredPreference(key: key ?? this.key, value: value ?? this.value);
  StoredPreference copyWithCompanion(StoredPreferencesCompanion data) {
    return StoredPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredPreference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredPreference &&
          other.key == this.key &&
          other.value == this.value);
}

class StoredPreferencesCompanion extends UpdateCompanion<StoredPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const StoredPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredPreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<StoredPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return StoredPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCategoriesTable extends CustomCategories
    with TableInfo<$CustomCategoriesTable, CustomCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeKeyMeta = const VerificationMeta(
    'typeKey',
  );
  @override
  late final GeneratedColumn<String> typeKey = GeneratedColumn<String>(
    'type_key',
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
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMicrosMeta =
      const VerificationMeta('updatedAtUtcMicros');
  @override
  late final GeneratedColumn<int> updatedAtUtcMicros = GeneratedColumn<int>(
    'updated_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    typeKey,
    name,
    normalizedName,
    iconKey,
    isArchived,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('type_key')) {
      context.handle(
        _typeKeyMeta,
        typeKey.isAcceptableOrUnknown(data['type_key']!, _typeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_typeKeyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    if (data.containsKey('updated_at_utc_micros')) {
      context.handle(
        _updatedAtUtcMicrosMeta,
        updatedAtUtcMicros.isAcceptableOrUnknown(
          data['updated_at_utc_micros']!,
          _updatedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      typeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
      updatedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_micros'],
      )!,
    );
  }

  @override
  $CustomCategoriesTable createAlias(String alias) {
    return $CustomCategoriesTable(attachedDatabase, alias);
  }
}

class CustomCategory extends DataClass implements Insertable<CustomCategory> {
  final String id;
  final String ownerScope;
  final String typeKey;
  final String name;
  final String normalizedName;
  final String iconKey;
  final bool isArchived;
  final int createdAtUtcMicros;
  final int updatedAtUtcMicros;
  const CustomCategory({
    required this.id,
    required this.ownerScope,
    required this.typeKey,
    required this.name,
    required this.normalizedName,
    required this.iconKey,
    required this.isArchived,
    required this.createdAtUtcMicros,
    required this.updatedAtUtcMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['type_key'] = Variable<String>(typeKey);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['icon_key'] = Variable<String>(iconKey);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros);
    return map;
  }

  CustomCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomCategoriesCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      typeKey: Value(typeKey),
      name: Value(name),
      normalizedName: Value(normalizedName),
      iconKey: Value(iconKey),
      isArchived: Value(isArchived),
      createdAtUtcMicros: Value(createdAtUtcMicros),
      updatedAtUtcMicros: Value(updatedAtUtcMicros),
    );
  }

  factory CustomCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCategory(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      typeKey: serializer.fromJson<String>(json['typeKey']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
      updatedAtUtcMicros: serializer.fromJson<int>(json['updatedAtUtcMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'typeKey': serializer.toJson<String>(typeKey),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'iconKey': serializer.toJson<String>(iconKey),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
      'updatedAtUtcMicros': serializer.toJson<int>(updatedAtUtcMicros),
    };
  }

  CustomCategory copyWith({
    String? id,
    String? ownerScope,
    String? typeKey,
    String? name,
    String? normalizedName,
    String? iconKey,
    bool? isArchived,
    int? createdAtUtcMicros,
    int? updatedAtUtcMicros,
  }) => CustomCategory(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    typeKey: typeKey ?? this.typeKey,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    iconKey: iconKey ?? this.iconKey,
    isArchived: isArchived ?? this.isArchived,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
    updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
  );
  CustomCategory copyWithCompanion(CustomCategoriesCompanion data) {
    return CustomCategory(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      typeKey: data.typeKey.present ? data.typeKey.value : this.typeKey,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
      updatedAtUtcMicros: data.updatedAtUtcMicros.present
          ? data.updatedAtUtcMicros.value
          : this.updatedAtUtcMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategory(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('typeKey: $typeKey, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('iconKey: $iconKey, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerScope,
    typeKey,
    name,
    normalizedName,
    iconKey,
    isArchived,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCategory &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.typeKey == this.typeKey &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.iconKey == this.iconKey &&
          other.isArchived == this.isArchived &&
          other.createdAtUtcMicros == this.createdAtUtcMicros &&
          other.updatedAtUtcMicros == this.updatedAtUtcMicros);
}

class CustomCategoriesCompanion extends UpdateCompanion<CustomCategory> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<String> typeKey;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> iconKey;
  final Value<bool> isArchived;
  final Value<int> createdAtUtcMicros;
  final Value<int> updatedAtUtcMicros;
  final Value<int> rowid;
  const CustomCategoriesCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.typeKey = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.updatedAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCategoriesCompanion.insert({
    required String id,
    required String ownerScope,
    required String typeKey,
    required String name,
    required String normalizedName,
    required String iconKey,
    this.isArchived = const Value.absent(),
    required int createdAtUtcMicros,
    required int updatedAtUtcMicros,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       typeKey = Value(typeKey),
       name = Value(name),
       normalizedName = Value(normalizedName),
       iconKey = Value(iconKey),
       createdAtUtcMicros = Value(createdAtUtcMicros),
       updatedAtUtcMicros = Value(updatedAtUtcMicros);
  static Insertable<CustomCategory> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<String>? typeKey,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? iconKey,
    Expression<bool>? isArchived,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? updatedAtUtcMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (typeKey != null) 'type_key': typeKey,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (iconKey != null) 'icon_key': iconKey,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (updatedAtUtcMicros != null)
        'updated_at_utc_micros': updatedAtUtcMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<String>? typeKey,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? iconKey,
    Value<bool>? isArchived,
    Value<int>? createdAtUtcMicros,
    Value<int>? updatedAtUtcMicros,
    Value<int>? rowid,
  }) {
    return CustomCategoriesCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      typeKey: typeKey ?? this.typeKey,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      iconKey: iconKey ?? this.iconKey,
      isArchived: isArchived ?? this.isArchived,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (typeKey.present) {
      map['type_key'] = Variable<String>(typeKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (updatedAtUtcMicros.present) {
      map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('typeKey: $typeKey, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('iconKey: $iconKey, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredTransfersTable extends StoredTransfers
    with TableInfo<$StoredTransfersTable, StoredTransfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredTransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationKeyMeta = const VerificationMeta(
    'destinationKey',
  );
  @override
  late final GeneratedColumn<String> destinationKey = GeneratedColumn<String>(
    'destination_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationNameMeta = const VerificationMeta(
    'destinationName',
  );
  @override
  late final GeneratedColumn<String> destinationName = GeneratedColumn<String>(
    'destination_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countsAsExpenseMeta = const VerificationMeta(
    'countsAsExpense',
  );
  @override
  late final GeneratedColumn<bool> countsAsExpense = GeneratedColumn<bool>(
    'counts_as_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("counts_as_expense" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _expenseCategoryKeyMeta =
      const VerificationMeta('expenseCategoryKey');
  @override
  late final GeneratedColumn<String> expenseCategoryKey =
      GeneratedColumn<String>(
        'expense_category_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _feeMinorUnitsMeta = const VerificationMeta(
    'feeMinorUnits',
  );
  @override
  late final GeneratedColumn<int> feeMinorUnits = GeneratedColumn<int>(
    'fee_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _occurredAtUtcMicrosMeta =
      const VerificationMeta('occurredAtUtcMicros');
  @override
  late final GeneratedColumn<int> occurredAtUtcMicros = GeneratedColumn<int>(
    'occurred_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMicrosMeta =
      const VerificationMeta('updatedAtUtcMicros');
  @override
  late final GeneratedColumn<int> updatedAtUtcMicros = GeneratedColumn<int>(
    'updated_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    amountMinorUnits,
    currencyCode,
    sourceKey,
    destinationKey,
    destinationName,
    countsAsExpense,
    expenseCategoryKey,
    feeMinorUnits,
    occurredAtUtcMicros,
    note,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredTransfer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('destination_key')) {
      context.handle(
        _destinationKeyMeta,
        destinationKey.isAcceptableOrUnknown(
          data['destination_key']!,
          _destinationKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationKeyMeta);
    }
    if (data.containsKey('destination_name')) {
      context.handle(
        _destinationNameMeta,
        destinationName.isAcceptableOrUnknown(
          data['destination_name']!,
          _destinationNameMeta,
        ),
      );
    }
    if (data.containsKey('counts_as_expense')) {
      context.handle(
        _countsAsExpenseMeta,
        countsAsExpense.isAcceptableOrUnknown(
          data['counts_as_expense']!,
          _countsAsExpenseMeta,
        ),
      );
    }
    if (data.containsKey('expense_category_key')) {
      context.handle(
        _expenseCategoryKeyMeta,
        expenseCategoryKey.isAcceptableOrUnknown(
          data['expense_category_key']!,
          _expenseCategoryKeyMeta,
        ),
      );
    }
    if (data.containsKey('fee_minor_units')) {
      context.handle(
        _feeMinorUnitsMeta,
        feeMinorUnits.isAcceptableOrUnknown(
          data['fee_minor_units']!,
          _feeMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at_utc_micros')) {
      context.handle(
        _occurredAtUtcMicrosMeta,
        occurredAtUtcMicros.isAcceptableOrUnknown(
          data['occurred_at_utc_micros']!,
          _occurredAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMicrosMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    if (data.containsKey('updated_at_utc_micros')) {
      context.handle(
        _updatedAtUtcMicrosMeta,
        updatedAtUtcMicros.isAcceptableOrUnknown(
          data['updated_at_utc_micros']!,
          _updatedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredTransfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredTransfer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      destinationKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_key'],
      )!,
      destinationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_name'],
      ),
      countsAsExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}counts_as_expense'],
      )!,
      expenseCategoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_category_key'],
      ),
      feeMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_minor_units'],
      )!,
      occurredAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_utc_micros'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
      updatedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_micros'],
      )!,
    );
  }

  @override
  $StoredTransfersTable createAlias(String alias) {
    return $StoredTransfersTable(attachedDatabase, alias);
  }
}

class StoredTransfer extends DataClass implements Insertable<StoredTransfer> {
  final String id;
  final String ownerScope;
  final int amountMinorUnits;
  final String currencyCode;
  final String sourceKey;
  final String destinationKey;
  final String? destinationName;
  final bool countsAsExpense;
  final String? expenseCategoryKey;
  final int feeMinorUnits;
  final int occurredAtUtcMicros;
  final String? note;
  final int createdAtUtcMicros;
  final int updatedAtUtcMicros;
  const StoredTransfer({
    required this.id,
    required this.ownerScope,
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.sourceKey,
    required this.destinationKey,
    this.destinationName,
    required this.countsAsExpense,
    this.expenseCategoryKey,
    required this.feeMinorUnits,
    required this.occurredAtUtcMicros,
    this.note,
    required this.createdAtUtcMicros,
    required this.updatedAtUtcMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['source_key'] = Variable<String>(sourceKey);
    map['destination_key'] = Variable<String>(destinationKey);
    if (!nullToAbsent || destinationName != null) {
      map['destination_name'] = Variable<String>(destinationName);
    }
    map['counts_as_expense'] = Variable<bool>(countsAsExpense);
    if (!nullToAbsent || expenseCategoryKey != null) {
      map['expense_category_key'] = Variable<String>(expenseCategoryKey);
    }
    map['fee_minor_units'] = Variable<int>(feeMinorUnits);
    map['occurred_at_utc_micros'] = Variable<int>(occurredAtUtcMicros);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros);
    return map;
  }

  StoredTransfersCompanion toCompanion(bool nullToAbsent) {
    return StoredTransfersCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      amountMinorUnits: Value(amountMinorUnits),
      currencyCode: Value(currencyCode),
      sourceKey: Value(sourceKey),
      destinationKey: Value(destinationKey),
      destinationName: destinationName == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationName),
      countsAsExpense: Value(countsAsExpense),
      expenseCategoryKey: expenseCategoryKey == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseCategoryKey),
      feeMinorUnits: Value(feeMinorUnits),
      occurredAtUtcMicros: Value(occurredAtUtcMicros),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtUtcMicros: Value(createdAtUtcMicros),
      updatedAtUtcMicros: Value(updatedAtUtcMicros),
    );
  }

  factory StoredTransfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredTransfer(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      destinationKey: serializer.fromJson<String>(json['destinationKey']),
      destinationName: serializer.fromJson<String?>(json['destinationName']),
      countsAsExpense: serializer.fromJson<bool>(json['countsAsExpense']),
      expenseCategoryKey: serializer.fromJson<String?>(
        json['expenseCategoryKey'],
      ),
      feeMinorUnits: serializer.fromJson<int>(json['feeMinorUnits']),
      occurredAtUtcMicros: serializer.fromJson<int>(
        json['occurredAtUtcMicros'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
      updatedAtUtcMicros: serializer.fromJson<int>(json['updatedAtUtcMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'destinationKey': serializer.toJson<String>(destinationKey),
      'destinationName': serializer.toJson<String?>(destinationName),
      'countsAsExpense': serializer.toJson<bool>(countsAsExpense),
      'expenseCategoryKey': serializer.toJson<String?>(expenseCategoryKey),
      'feeMinorUnits': serializer.toJson<int>(feeMinorUnits),
      'occurredAtUtcMicros': serializer.toJson<int>(occurredAtUtcMicros),
      'note': serializer.toJson<String?>(note),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
      'updatedAtUtcMicros': serializer.toJson<int>(updatedAtUtcMicros),
    };
  }

  StoredTransfer copyWith({
    String? id,
    String? ownerScope,
    int? amountMinorUnits,
    String? currencyCode,
    String? sourceKey,
    String? destinationKey,
    Value<String?> destinationName = const Value.absent(),
    bool? countsAsExpense,
    Value<String?> expenseCategoryKey = const Value.absent(),
    int? feeMinorUnits,
    int? occurredAtUtcMicros,
    Value<String?> note = const Value.absent(),
    int? createdAtUtcMicros,
    int? updatedAtUtcMicros,
  }) => StoredTransfer(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    sourceKey: sourceKey ?? this.sourceKey,
    destinationKey: destinationKey ?? this.destinationKey,
    destinationName: destinationName.present
        ? destinationName.value
        : this.destinationName,
    countsAsExpense: countsAsExpense ?? this.countsAsExpense,
    expenseCategoryKey: expenseCategoryKey.present
        ? expenseCategoryKey.value
        : this.expenseCategoryKey,
    feeMinorUnits: feeMinorUnits ?? this.feeMinorUnits,
    occurredAtUtcMicros: occurredAtUtcMicros ?? this.occurredAtUtcMicros,
    note: note.present ? note.value : this.note,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
    updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
  );
  StoredTransfer copyWithCompanion(StoredTransfersCompanion data) {
    return StoredTransfer(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      destinationKey: data.destinationKey.present
          ? data.destinationKey.value
          : this.destinationKey,
      destinationName: data.destinationName.present
          ? data.destinationName.value
          : this.destinationName,
      countsAsExpense: data.countsAsExpense.present
          ? data.countsAsExpense.value
          : this.countsAsExpense,
      expenseCategoryKey: data.expenseCategoryKey.present
          ? data.expenseCategoryKey.value
          : this.expenseCategoryKey,
      feeMinorUnits: data.feeMinorUnits.present
          ? data.feeMinorUnits.value
          : this.feeMinorUnits,
      occurredAtUtcMicros: data.occurredAtUtcMicros.present
          ? data.occurredAtUtcMicros.value
          : this.occurredAtUtcMicros,
      note: data.note.present ? data.note.value : this.note,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
      updatedAtUtcMicros: data.updatedAtUtcMicros.present
          ? data.updatedAtUtcMicros.value
          : this.updatedAtUtcMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredTransfer(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('destinationKey: $destinationKey, ')
          ..write('destinationName: $destinationName, ')
          ..write('countsAsExpense: $countsAsExpense, ')
          ..write('expenseCategoryKey: $expenseCategoryKey, ')
          ..write('feeMinorUnits: $feeMinorUnits, ')
          ..write('occurredAtUtcMicros: $occurredAtUtcMicros, ')
          ..write('note: $note, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerScope,
    amountMinorUnits,
    currencyCode,
    sourceKey,
    destinationKey,
    destinationName,
    countsAsExpense,
    expenseCategoryKey,
    feeMinorUnits,
    occurredAtUtcMicros,
    note,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredTransfer &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.sourceKey == this.sourceKey &&
          other.destinationKey == this.destinationKey &&
          other.destinationName == this.destinationName &&
          other.countsAsExpense == this.countsAsExpense &&
          other.expenseCategoryKey == this.expenseCategoryKey &&
          other.feeMinorUnits == this.feeMinorUnits &&
          other.occurredAtUtcMicros == this.occurredAtUtcMicros &&
          other.note == this.note &&
          other.createdAtUtcMicros == this.createdAtUtcMicros &&
          other.updatedAtUtcMicros == this.updatedAtUtcMicros);
}

class StoredTransfersCompanion extends UpdateCompanion<StoredTransfer> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<int> amountMinorUnits;
  final Value<String> currencyCode;
  final Value<String> sourceKey;
  final Value<String> destinationKey;
  final Value<String?> destinationName;
  final Value<bool> countsAsExpense;
  final Value<String?> expenseCategoryKey;
  final Value<int> feeMinorUnits;
  final Value<int> occurredAtUtcMicros;
  final Value<String?> note;
  final Value<int> createdAtUtcMicros;
  final Value<int> updatedAtUtcMicros;
  final Value<int> rowid;
  const StoredTransfersCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.destinationKey = const Value.absent(),
    this.destinationName = const Value.absent(),
    this.countsAsExpense = const Value.absent(),
    this.expenseCategoryKey = const Value.absent(),
    this.feeMinorUnits = const Value.absent(),
    this.occurredAtUtcMicros = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.updatedAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredTransfersCompanion.insert({
    required String id,
    required String ownerScope,
    required int amountMinorUnits,
    required String currencyCode,
    required String sourceKey,
    required String destinationKey,
    this.destinationName = const Value.absent(),
    this.countsAsExpense = const Value.absent(),
    this.expenseCategoryKey = const Value.absent(),
    this.feeMinorUnits = const Value.absent(),
    required int occurredAtUtcMicros,
    this.note = const Value.absent(),
    required int createdAtUtcMicros,
    required int updatedAtUtcMicros,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       amountMinorUnits = Value(amountMinorUnits),
       currencyCode = Value(currencyCode),
       sourceKey = Value(sourceKey),
       destinationKey = Value(destinationKey),
       occurredAtUtcMicros = Value(occurredAtUtcMicros),
       createdAtUtcMicros = Value(createdAtUtcMicros),
       updatedAtUtcMicros = Value(updatedAtUtcMicros);
  static Insertable<StoredTransfer> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<int>? amountMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? sourceKey,
    Expression<String>? destinationKey,
    Expression<String>? destinationName,
    Expression<bool>? countsAsExpense,
    Expression<String>? expenseCategoryKey,
    Expression<int>? feeMinorUnits,
    Expression<int>? occurredAtUtcMicros,
    Expression<String>? note,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? updatedAtUtcMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (sourceKey != null) 'source_key': sourceKey,
      if (destinationKey != null) 'destination_key': destinationKey,
      if (destinationName != null) 'destination_name': destinationName,
      if (countsAsExpense != null) 'counts_as_expense': countsAsExpense,
      if (expenseCategoryKey != null)
        'expense_category_key': expenseCategoryKey,
      if (feeMinorUnits != null) 'fee_minor_units': feeMinorUnits,
      if (occurredAtUtcMicros != null)
        'occurred_at_utc_micros': occurredAtUtcMicros,
      if (note != null) 'note': note,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (updatedAtUtcMicros != null)
        'updated_at_utc_micros': updatedAtUtcMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredTransfersCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<int>? amountMinorUnits,
    Value<String>? currencyCode,
    Value<String>? sourceKey,
    Value<String>? destinationKey,
    Value<String?>? destinationName,
    Value<bool>? countsAsExpense,
    Value<String?>? expenseCategoryKey,
    Value<int>? feeMinorUnits,
    Value<int>? occurredAtUtcMicros,
    Value<String?>? note,
    Value<int>? createdAtUtcMicros,
    Value<int>? updatedAtUtcMicros,
    Value<int>? rowid,
  }) {
    return StoredTransfersCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      sourceKey: sourceKey ?? this.sourceKey,
      destinationKey: destinationKey ?? this.destinationKey,
      destinationName: destinationName ?? this.destinationName,
      countsAsExpense: countsAsExpense ?? this.countsAsExpense,
      expenseCategoryKey: expenseCategoryKey ?? this.expenseCategoryKey,
      feeMinorUnits: feeMinorUnits ?? this.feeMinorUnits,
      occurredAtUtcMicros: occurredAtUtcMicros ?? this.occurredAtUtcMicros,
      note: note ?? this.note,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (destinationKey.present) {
      map['destination_key'] = Variable<String>(destinationKey.value);
    }
    if (destinationName.present) {
      map['destination_name'] = Variable<String>(destinationName.value);
    }
    if (countsAsExpense.present) {
      map['counts_as_expense'] = Variable<bool>(countsAsExpense.value);
    }
    if (expenseCategoryKey.present) {
      map['expense_category_key'] = Variable<String>(expenseCategoryKey.value);
    }
    if (feeMinorUnits.present) {
      map['fee_minor_units'] = Variable<int>(feeMinorUnits.value);
    }
    if (occurredAtUtcMicros.present) {
      map['occurred_at_utc_micros'] = Variable<int>(occurredAtUtcMicros.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (updatedAtUtcMicros.present) {
      map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredTransfersCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('destinationKey: $destinationKey, ')
          ..write('destinationName: $destinationName, ')
          ..write('countsAsExpense: $countsAsExpense, ')
          ..write('expenseCategoryKey: $expenseCategoryKey, ')
          ..write('feeMinorUnits: $feeMinorUnits, ')
          ..write('occurredAtUtcMicros: $occurredAtUtcMicros, ')
          ..write('note: $note, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionRulesTable extends RecurringTransactionRules
    with TableInfo<$RecurringTransactionRulesTable, RecurringTransactionRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeKeyMeta = const VerificationMeta(
    'typeKey',
  );
  @override
  late final GeneratedColumn<String> typeKey = GeneratedColumn<String>(
    'type_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodKeyMeta = const VerificationMeta(
    'paymentMethodKey',
  );
  @override
  late final GeneratedColumn<String> paymentMethodKey = GeneratedColumn<String>(
    'payment_method_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _frequencyKeyMeta = const VerificationMeta(
    'frequencyKey',
  );
  @override
  late final GeneratedColumn<String> frequencyKey = GeneratedColumn<String>(
    'frequency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceCalendarKeyMeta =
      const VerificationMeta('recurrenceCalendarKey');
  @override
  late final GeneratedColumn<String> recurrenceCalendarKey =
      GeneratedColumn<String>(
        'recurrence_calendar_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _anchorDayMeta = const VerificationMeta(
    'anchorDay',
  );
  @override
  late final GeneratedColumn<int> anchorDay = GeneratedColumn<int>(
    'anchor_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorMonthMeta = const VerificationMeta(
    'anchorMonth',
  );
  @override
  late final GeneratedColumn<int> anchorMonth = GeneratedColumn<int>(
    'anchor_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorWeekdayMeta = const VerificationMeta(
    'anchorWeekday',
  );
  @override
  late final GeneratedColumn<int> anchorWeekday = GeneratedColumn<int>(
    'anchor_weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstDueDateAdUtcMicrosMeta =
      const VerificationMeta('firstDueDateAdUtcMicros');
  @override
  late final GeneratedColumn<int> firstDueDateAdUtcMicros =
      GeneratedColumn<int>(
        'first_due_date_ad_utc_micros',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _nextDueDateAdUtcMicrosMeta =
      const VerificationMeta('nextDueDateAdUtcMicros');
  @override
  late final GeneratedColumn<int> nextDueDateAdUtcMicros = GeneratedColumn<int>(
    'next_due_date_ad_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusKeyMeta = const VerificationMeta(
    'statusKey',
  );
  @override
  late final GeneratedColumn<String> statusKey = GeneratedColumn<String>(
    'status_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMicrosMeta =
      const VerificationMeta('updatedAtUtcMicros');
  @override
  late final GeneratedColumn<int> updatedAtUtcMicros = GeneratedColumn<int>(
    'updated_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pausedAtUtcMicrosMeta = const VerificationMeta(
    'pausedAtUtcMicros',
  );
  @override
  late final GeneratedColumn<int> pausedAtUtcMicros = GeneratedColumn<int>(
    'paused_at_utc_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtUtcMicrosMeta =
      const VerificationMeta('deletedAtUtcMicros');
  @override
  late final GeneratedColumn<int> deletedAtUtcMicros = GeneratedColumn<int>(
    'deleted_at_utc_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    typeKey,
    amountMinorUnits,
    currencyCode,
    categoryKey,
    paymentMethodKey,
    merchant,
    note,
    frequencyKey,
    recurrenceCalendarKey,
    anchorDay,
    anchorMonth,
    anchorWeekday,
    firstDueDateAdUtcMicros,
    nextDueDateAdUtcMicros,
    statusKey,
    createdAtUtcMicros,
    updatedAtUtcMicros,
    pausedAtUtcMicros,
    deletedAtUtcMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transaction_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringTransactionRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('type_key')) {
      context.handle(
        _typeKeyMeta,
        typeKey.isAcceptableOrUnknown(data['type_key']!, _typeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_typeKeyMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('payment_method_key')) {
      context.handle(
        _paymentMethodKeyMeta,
        paymentMethodKey.isAcceptableOrUnknown(
          data['payment_method_key']!,
          _paymentMethodKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodKeyMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('frequency_key')) {
      context.handle(
        _frequencyKeyMeta,
        frequencyKey.isAcceptableOrUnknown(
          data['frequency_key']!,
          _frequencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frequencyKeyMeta);
    }
    if (data.containsKey('recurrence_calendar_key')) {
      context.handle(
        _recurrenceCalendarKeyMeta,
        recurrenceCalendarKey.isAcceptableOrUnknown(
          data['recurrence_calendar_key']!,
          _recurrenceCalendarKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurrenceCalendarKeyMeta);
    }
    if (data.containsKey('anchor_day')) {
      context.handle(
        _anchorDayMeta,
        anchorDay.isAcceptableOrUnknown(data['anchor_day']!, _anchorDayMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorDayMeta);
    }
    if (data.containsKey('anchor_month')) {
      context.handle(
        _anchorMonthMeta,
        anchorMonth.isAcceptableOrUnknown(
          data['anchor_month']!,
          _anchorMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anchorMonthMeta);
    }
    if (data.containsKey('anchor_weekday')) {
      context.handle(
        _anchorWeekdayMeta,
        anchorWeekday.isAcceptableOrUnknown(
          data['anchor_weekday']!,
          _anchorWeekdayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anchorWeekdayMeta);
    }
    if (data.containsKey('first_due_date_ad_utc_micros')) {
      context.handle(
        _firstDueDateAdUtcMicrosMeta,
        firstDueDateAdUtcMicros.isAcceptableOrUnknown(
          data['first_due_date_ad_utc_micros']!,
          _firstDueDateAdUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstDueDateAdUtcMicrosMeta);
    }
    if (data.containsKey('next_due_date_ad_utc_micros')) {
      context.handle(
        _nextDueDateAdUtcMicrosMeta,
        nextDueDateAdUtcMicros.isAcceptableOrUnknown(
          data['next_due_date_ad_utc_micros']!,
          _nextDueDateAdUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateAdUtcMicrosMeta);
    }
    if (data.containsKey('status_key')) {
      context.handle(
        _statusKeyMeta,
        statusKey.isAcceptableOrUnknown(data['status_key']!, _statusKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_statusKeyMeta);
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    if (data.containsKey('updated_at_utc_micros')) {
      context.handle(
        _updatedAtUtcMicrosMeta,
        updatedAtUtcMicros.isAcceptableOrUnknown(
          data['updated_at_utc_micros']!,
          _updatedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMicrosMeta);
    }
    if (data.containsKey('paused_at_utc_micros')) {
      context.handle(
        _pausedAtUtcMicrosMeta,
        pausedAtUtcMicros.isAcceptableOrUnknown(
          data['paused_at_utc_micros']!,
          _pausedAtUtcMicrosMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_utc_micros')) {
      context.handle(
        _deletedAtUtcMicrosMeta,
        deletedAtUtcMicros.isAcceptableOrUnknown(
          data['deleted_at_utc_micros']!,
          _deletedAtUtcMicrosMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransactionRule map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransactionRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      typeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_key'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      paymentMethodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_key'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      frequencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency_key'],
      )!,
      recurrenceCalendarKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_calendar_key'],
      )!,
      anchorDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_day'],
      )!,
      anchorMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_month'],
      )!,
      anchorWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_weekday'],
      )!,
      firstDueDateAdUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_due_date_ad_utc_micros'],
      )!,
      nextDueDateAdUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_due_date_ad_utc_micros'],
      )!,
      statusKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_key'],
      )!,
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
      updatedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_micros'],
      )!,
      pausedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_at_utc_micros'],
      ),
      deletedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_utc_micros'],
      ),
    );
  }

  @override
  $RecurringTransactionRulesTable createAlias(String alias) {
    return $RecurringTransactionRulesTable(attachedDatabase, alias);
  }
}

class RecurringTransactionRule extends DataClass
    implements Insertable<RecurringTransactionRule> {
  final String id;
  final String ownerScope;
  final String typeKey;
  final int amountMinorUnits;
  final String currencyCode;
  final String categoryKey;
  final String paymentMethodKey;
  final String? merchant;
  final String? note;
  final String frequencyKey;
  final String recurrenceCalendarKey;
  final int anchorDay;
  final int anchorMonth;
  final int anchorWeekday;
  final int firstDueDateAdUtcMicros;
  final int nextDueDateAdUtcMicros;
  final String statusKey;
  final int createdAtUtcMicros;
  final int updatedAtUtcMicros;
  final int? pausedAtUtcMicros;
  final int? deletedAtUtcMicros;
  const RecurringTransactionRule({
    required this.id,
    required this.ownerScope,
    required this.typeKey,
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.categoryKey,
    required this.paymentMethodKey,
    this.merchant,
    this.note,
    required this.frequencyKey,
    required this.recurrenceCalendarKey,
    required this.anchorDay,
    required this.anchorMonth,
    required this.anchorWeekday,
    required this.firstDueDateAdUtcMicros,
    required this.nextDueDateAdUtcMicros,
    required this.statusKey,
    required this.createdAtUtcMicros,
    required this.updatedAtUtcMicros,
    this.pausedAtUtcMicros,
    this.deletedAtUtcMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['type_key'] = Variable<String>(typeKey);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['category_key'] = Variable<String>(categoryKey);
    map['payment_method_key'] = Variable<String>(paymentMethodKey);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['frequency_key'] = Variable<String>(frequencyKey);
    map['recurrence_calendar_key'] = Variable<String>(recurrenceCalendarKey);
    map['anchor_day'] = Variable<int>(anchorDay);
    map['anchor_month'] = Variable<int>(anchorMonth);
    map['anchor_weekday'] = Variable<int>(anchorWeekday);
    map['first_due_date_ad_utc_micros'] = Variable<int>(
      firstDueDateAdUtcMicros,
    );
    map['next_due_date_ad_utc_micros'] = Variable<int>(nextDueDateAdUtcMicros);
    map['status_key'] = Variable<String>(statusKey);
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros);
    if (!nullToAbsent || pausedAtUtcMicros != null) {
      map['paused_at_utc_micros'] = Variable<int>(pausedAtUtcMicros);
    }
    if (!nullToAbsent || deletedAtUtcMicros != null) {
      map['deleted_at_utc_micros'] = Variable<int>(deletedAtUtcMicros);
    }
    return map;
  }

  RecurringTransactionRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionRulesCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      typeKey: Value(typeKey),
      amountMinorUnits: Value(amountMinorUnits),
      currencyCode: Value(currencyCode),
      categoryKey: Value(categoryKey),
      paymentMethodKey: Value(paymentMethodKey),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      frequencyKey: Value(frequencyKey),
      recurrenceCalendarKey: Value(recurrenceCalendarKey),
      anchorDay: Value(anchorDay),
      anchorMonth: Value(anchorMonth),
      anchorWeekday: Value(anchorWeekday),
      firstDueDateAdUtcMicros: Value(firstDueDateAdUtcMicros),
      nextDueDateAdUtcMicros: Value(nextDueDateAdUtcMicros),
      statusKey: Value(statusKey),
      createdAtUtcMicros: Value(createdAtUtcMicros),
      updatedAtUtcMicros: Value(updatedAtUtcMicros),
      pausedAtUtcMicros: pausedAtUtcMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAtUtcMicros),
      deletedAtUtcMicros: deletedAtUtcMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtcMicros),
    );
  }

  factory RecurringTransactionRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransactionRule(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      typeKey: serializer.fromJson<String>(json['typeKey']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      paymentMethodKey: serializer.fromJson<String>(json['paymentMethodKey']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      note: serializer.fromJson<String?>(json['note']),
      frequencyKey: serializer.fromJson<String>(json['frequencyKey']),
      recurrenceCalendarKey: serializer.fromJson<String>(
        json['recurrenceCalendarKey'],
      ),
      anchorDay: serializer.fromJson<int>(json['anchorDay']),
      anchorMonth: serializer.fromJson<int>(json['anchorMonth']),
      anchorWeekday: serializer.fromJson<int>(json['anchorWeekday']),
      firstDueDateAdUtcMicros: serializer.fromJson<int>(
        json['firstDueDateAdUtcMicros'],
      ),
      nextDueDateAdUtcMicros: serializer.fromJson<int>(
        json['nextDueDateAdUtcMicros'],
      ),
      statusKey: serializer.fromJson<String>(json['statusKey']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
      updatedAtUtcMicros: serializer.fromJson<int>(json['updatedAtUtcMicros']),
      pausedAtUtcMicros: serializer.fromJson<int?>(json['pausedAtUtcMicros']),
      deletedAtUtcMicros: serializer.fromJson<int?>(json['deletedAtUtcMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'typeKey': serializer.toJson<String>(typeKey),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'paymentMethodKey': serializer.toJson<String>(paymentMethodKey),
      'merchant': serializer.toJson<String?>(merchant),
      'note': serializer.toJson<String?>(note),
      'frequencyKey': serializer.toJson<String>(frequencyKey),
      'recurrenceCalendarKey': serializer.toJson<String>(recurrenceCalendarKey),
      'anchorDay': serializer.toJson<int>(anchorDay),
      'anchorMonth': serializer.toJson<int>(anchorMonth),
      'anchorWeekday': serializer.toJson<int>(anchorWeekday),
      'firstDueDateAdUtcMicros': serializer.toJson<int>(
        firstDueDateAdUtcMicros,
      ),
      'nextDueDateAdUtcMicros': serializer.toJson<int>(nextDueDateAdUtcMicros),
      'statusKey': serializer.toJson<String>(statusKey),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
      'updatedAtUtcMicros': serializer.toJson<int>(updatedAtUtcMicros),
      'pausedAtUtcMicros': serializer.toJson<int?>(pausedAtUtcMicros),
      'deletedAtUtcMicros': serializer.toJson<int?>(deletedAtUtcMicros),
    };
  }

  RecurringTransactionRule copyWith({
    String? id,
    String? ownerScope,
    String? typeKey,
    int? amountMinorUnits,
    String? currencyCode,
    String? categoryKey,
    String? paymentMethodKey,
    Value<String?> merchant = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? frequencyKey,
    String? recurrenceCalendarKey,
    int? anchorDay,
    int? anchorMonth,
    int? anchorWeekday,
    int? firstDueDateAdUtcMicros,
    int? nextDueDateAdUtcMicros,
    String? statusKey,
    int? createdAtUtcMicros,
    int? updatedAtUtcMicros,
    Value<int?> pausedAtUtcMicros = const Value.absent(),
    Value<int?> deletedAtUtcMicros = const Value.absent(),
  }) => RecurringTransactionRule(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    typeKey: typeKey ?? this.typeKey,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    categoryKey: categoryKey ?? this.categoryKey,
    paymentMethodKey: paymentMethodKey ?? this.paymentMethodKey,
    merchant: merchant.present ? merchant.value : this.merchant,
    note: note.present ? note.value : this.note,
    frequencyKey: frequencyKey ?? this.frequencyKey,
    recurrenceCalendarKey: recurrenceCalendarKey ?? this.recurrenceCalendarKey,
    anchorDay: anchorDay ?? this.anchorDay,
    anchorMonth: anchorMonth ?? this.anchorMonth,
    anchorWeekday: anchorWeekday ?? this.anchorWeekday,
    firstDueDateAdUtcMicros:
        firstDueDateAdUtcMicros ?? this.firstDueDateAdUtcMicros,
    nextDueDateAdUtcMicros:
        nextDueDateAdUtcMicros ?? this.nextDueDateAdUtcMicros,
    statusKey: statusKey ?? this.statusKey,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
    updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
    pausedAtUtcMicros: pausedAtUtcMicros.present
        ? pausedAtUtcMicros.value
        : this.pausedAtUtcMicros,
    deletedAtUtcMicros: deletedAtUtcMicros.present
        ? deletedAtUtcMicros.value
        : this.deletedAtUtcMicros,
  );
  RecurringTransactionRule copyWithCompanion(
    RecurringTransactionRulesCompanion data,
  ) {
    return RecurringTransactionRule(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      typeKey: data.typeKey.present ? data.typeKey.value : this.typeKey,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      paymentMethodKey: data.paymentMethodKey.present
          ? data.paymentMethodKey.value
          : this.paymentMethodKey,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      note: data.note.present ? data.note.value : this.note,
      frequencyKey: data.frequencyKey.present
          ? data.frequencyKey.value
          : this.frequencyKey,
      recurrenceCalendarKey: data.recurrenceCalendarKey.present
          ? data.recurrenceCalendarKey.value
          : this.recurrenceCalendarKey,
      anchorDay: data.anchorDay.present ? data.anchorDay.value : this.anchorDay,
      anchorMonth: data.anchorMonth.present
          ? data.anchorMonth.value
          : this.anchorMonth,
      anchorWeekday: data.anchorWeekday.present
          ? data.anchorWeekday.value
          : this.anchorWeekday,
      firstDueDateAdUtcMicros: data.firstDueDateAdUtcMicros.present
          ? data.firstDueDateAdUtcMicros.value
          : this.firstDueDateAdUtcMicros,
      nextDueDateAdUtcMicros: data.nextDueDateAdUtcMicros.present
          ? data.nextDueDateAdUtcMicros.value
          : this.nextDueDateAdUtcMicros,
      statusKey: data.statusKey.present ? data.statusKey.value : this.statusKey,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
      updatedAtUtcMicros: data.updatedAtUtcMicros.present
          ? data.updatedAtUtcMicros.value
          : this.updatedAtUtcMicros,
      pausedAtUtcMicros: data.pausedAtUtcMicros.present
          ? data.pausedAtUtcMicros.value
          : this.pausedAtUtcMicros,
      deletedAtUtcMicros: data.deletedAtUtcMicros.present
          ? data.deletedAtUtcMicros.value
          : this.deletedAtUtcMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionRule(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('typeKey: $typeKey, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('paymentMethodKey: $paymentMethodKey, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('frequencyKey: $frequencyKey, ')
          ..write('recurrenceCalendarKey: $recurrenceCalendarKey, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('anchorMonth: $anchorMonth, ')
          ..write('anchorWeekday: $anchorWeekday, ')
          ..write('firstDueDateAdUtcMicros: $firstDueDateAdUtcMicros, ')
          ..write('nextDueDateAdUtcMicros: $nextDueDateAdUtcMicros, ')
          ..write('statusKey: $statusKey, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('pausedAtUtcMicros: $pausedAtUtcMicros, ')
          ..write('deletedAtUtcMicros: $deletedAtUtcMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerScope,
    typeKey,
    amountMinorUnits,
    currencyCode,
    categoryKey,
    paymentMethodKey,
    merchant,
    note,
    frequencyKey,
    recurrenceCalendarKey,
    anchorDay,
    anchorMonth,
    anchorWeekday,
    firstDueDateAdUtcMicros,
    nextDueDateAdUtcMicros,
    statusKey,
    createdAtUtcMicros,
    updatedAtUtcMicros,
    pausedAtUtcMicros,
    deletedAtUtcMicros,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransactionRule &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.typeKey == this.typeKey &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.categoryKey == this.categoryKey &&
          other.paymentMethodKey == this.paymentMethodKey &&
          other.merchant == this.merchant &&
          other.note == this.note &&
          other.frequencyKey == this.frequencyKey &&
          other.recurrenceCalendarKey == this.recurrenceCalendarKey &&
          other.anchorDay == this.anchorDay &&
          other.anchorMonth == this.anchorMonth &&
          other.anchorWeekday == this.anchorWeekday &&
          other.firstDueDateAdUtcMicros == this.firstDueDateAdUtcMicros &&
          other.nextDueDateAdUtcMicros == this.nextDueDateAdUtcMicros &&
          other.statusKey == this.statusKey &&
          other.createdAtUtcMicros == this.createdAtUtcMicros &&
          other.updatedAtUtcMicros == this.updatedAtUtcMicros &&
          other.pausedAtUtcMicros == this.pausedAtUtcMicros &&
          other.deletedAtUtcMicros == this.deletedAtUtcMicros);
}

class RecurringTransactionRulesCompanion
    extends UpdateCompanion<RecurringTransactionRule> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<String> typeKey;
  final Value<int> amountMinorUnits;
  final Value<String> currencyCode;
  final Value<String> categoryKey;
  final Value<String> paymentMethodKey;
  final Value<String?> merchant;
  final Value<String?> note;
  final Value<String> frequencyKey;
  final Value<String> recurrenceCalendarKey;
  final Value<int> anchorDay;
  final Value<int> anchorMonth;
  final Value<int> anchorWeekday;
  final Value<int> firstDueDateAdUtcMicros;
  final Value<int> nextDueDateAdUtcMicros;
  final Value<String> statusKey;
  final Value<int> createdAtUtcMicros;
  final Value<int> updatedAtUtcMicros;
  final Value<int?> pausedAtUtcMicros;
  final Value<int?> deletedAtUtcMicros;
  final Value<int> rowid;
  const RecurringTransactionRulesCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.typeKey = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.paymentMethodKey = const Value.absent(),
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.frequencyKey = const Value.absent(),
    this.recurrenceCalendarKey = const Value.absent(),
    this.anchorDay = const Value.absent(),
    this.anchorMonth = const Value.absent(),
    this.anchorWeekday = const Value.absent(),
    this.firstDueDateAdUtcMicros = const Value.absent(),
    this.nextDueDateAdUtcMicros = const Value.absent(),
    this.statusKey = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.updatedAtUtcMicros = const Value.absent(),
    this.pausedAtUtcMicros = const Value.absent(),
    this.deletedAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTransactionRulesCompanion.insert({
    required String id,
    required String ownerScope,
    required String typeKey,
    required int amountMinorUnits,
    required String currencyCode,
    required String categoryKey,
    required String paymentMethodKey,
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    required String frequencyKey,
    required String recurrenceCalendarKey,
    required int anchorDay,
    required int anchorMonth,
    required int anchorWeekday,
    required int firstDueDateAdUtcMicros,
    required int nextDueDateAdUtcMicros,
    required String statusKey,
    required int createdAtUtcMicros,
    required int updatedAtUtcMicros,
    this.pausedAtUtcMicros = const Value.absent(),
    this.deletedAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       typeKey = Value(typeKey),
       amountMinorUnits = Value(amountMinorUnits),
       currencyCode = Value(currencyCode),
       categoryKey = Value(categoryKey),
       paymentMethodKey = Value(paymentMethodKey),
       frequencyKey = Value(frequencyKey),
       recurrenceCalendarKey = Value(recurrenceCalendarKey),
       anchorDay = Value(anchorDay),
       anchorMonth = Value(anchorMonth),
       anchorWeekday = Value(anchorWeekday),
       firstDueDateAdUtcMicros = Value(firstDueDateAdUtcMicros),
       nextDueDateAdUtcMicros = Value(nextDueDateAdUtcMicros),
       statusKey = Value(statusKey),
       createdAtUtcMicros = Value(createdAtUtcMicros),
       updatedAtUtcMicros = Value(updatedAtUtcMicros);
  static Insertable<RecurringTransactionRule> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<String>? typeKey,
    Expression<int>? amountMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? categoryKey,
    Expression<String>? paymentMethodKey,
    Expression<String>? merchant,
    Expression<String>? note,
    Expression<String>? frequencyKey,
    Expression<String>? recurrenceCalendarKey,
    Expression<int>? anchorDay,
    Expression<int>? anchorMonth,
    Expression<int>? anchorWeekday,
    Expression<int>? firstDueDateAdUtcMicros,
    Expression<int>? nextDueDateAdUtcMicros,
    Expression<String>? statusKey,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? updatedAtUtcMicros,
    Expression<int>? pausedAtUtcMicros,
    Expression<int>? deletedAtUtcMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (typeKey != null) 'type_key': typeKey,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (categoryKey != null) 'category_key': categoryKey,
      if (paymentMethodKey != null) 'payment_method_key': paymentMethodKey,
      if (merchant != null) 'merchant': merchant,
      if (note != null) 'note': note,
      if (frequencyKey != null) 'frequency_key': frequencyKey,
      if (recurrenceCalendarKey != null)
        'recurrence_calendar_key': recurrenceCalendarKey,
      if (anchorDay != null) 'anchor_day': anchorDay,
      if (anchorMonth != null) 'anchor_month': anchorMonth,
      if (anchorWeekday != null) 'anchor_weekday': anchorWeekday,
      if (firstDueDateAdUtcMicros != null)
        'first_due_date_ad_utc_micros': firstDueDateAdUtcMicros,
      if (nextDueDateAdUtcMicros != null)
        'next_due_date_ad_utc_micros': nextDueDateAdUtcMicros,
      if (statusKey != null) 'status_key': statusKey,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (updatedAtUtcMicros != null)
        'updated_at_utc_micros': updatedAtUtcMicros,
      if (pausedAtUtcMicros != null) 'paused_at_utc_micros': pausedAtUtcMicros,
      if (deletedAtUtcMicros != null)
        'deleted_at_utc_micros': deletedAtUtcMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTransactionRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<String>? typeKey,
    Value<int>? amountMinorUnits,
    Value<String>? currencyCode,
    Value<String>? categoryKey,
    Value<String>? paymentMethodKey,
    Value<String?>? merchant,
    Value<String?>? note,
    Value<String>? frequencyKey,
    Value<String>? recurrenceCalendarKey,
    Value<int>? anchorDay,
    Value<int>? anchorMonth,
    Value<int>? anchorWeekday,
    Value<int>? firstDueDateAdUtcMicros,
    Value<int>? nextDueDateAdUtcMicros,
    Value<String>? statusKey,
    Value<int>? createdAtUtcMicros,
    Value<int>? updatedAtUtcMicros,
    Value<int?>? pausedAtUtcMicros,
    Value<int?>? deletedAtUtcMicros,
    Value<int>? rowid,
  }) {
    return RecurringTransactionRulesCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      typeKey: typeKey ?? this.typeKey,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryKey: categoryKey ?? this.categoryKey,
      paymentMethodKey: paymentMethodKey ?? this.paymentMethodKey,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      frequencyKey: frequencyKey ?? this.frequencyKey,
      recurrenceCalendarKey:
          recurrenceCalendarKey ?? this.recurrenceCalendarKey,
      anchorDay: anchorDay ?? this.anchorDay,
      anchorMonth: anchorMonth ?? this.anchorMonth,
      anchorWeekday: anchorWeekday ?? this.anchorWeekday,
      firstDueDateAdUtcMicros:
          firstDueDateAdUtcMicros ?? this.firstDueDateAdUtcMicros,
      nextDueDateAdUtcMicros:
          nextDueDateAdUtcMicros ?? this.nextDueDateAdUtcMicros,
      statusKey: statusKey ?? this.statusKey,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
      pausedAtUtcMicros: pausedAtUtcMicros ?? this.pausedAtUtcMicros,
      deletedAtUtcMicros: deletedAtUtcMicros ?? this.deletedAtUtcMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (typeKey.present) {
      map['type_key'] = Variable<String>(typeKey.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (paymentMethodKey.present) {
      map['payment_method_key'] = Variable<String>(paymentMethodKey.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (frequencyKey.present) {
      map['frequency_key'] = Variable<String>(frequencyKey.value);
    }
    if (recurrenceCalendarKey.present) {
      map['recurrence_calendar_key'] = Variable<String>(
        recurrenceCalendarKey.value,
      );
    }
    if (anchorDay.present) {
      map['anchor_day'] = Variable<int>(anchorDay.value);
    }
    if (anchorMonth.present) {
      map['anchor_month'] = Variable<int>(anchorMonth.value);
    }
    if (anchorWeekday.present) {
      map['anchor_weekday'] = Variable<int>(anchorWeekday.value);
    }
    if (firstDueDateAdUtcMicros.present) {
      map['first_due_date_ad_utc_micros'] = Variable<int>(
        firstDueDateAdUtcMicros.value,
      );
    }
    if (nextDueDateAdUtcMicros.present) {
      map['next_due_date_ad_utc_micros'] = Variable<int>(
        nextDueDateAdUtcMicros.value,
      );
    }
    if (statusKey.present) {
      map['status_key'] = Variable<String>(statusKey.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (updatedAtUtcMicros.present) {
      map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros.value);
    }
    if (pausedAtUtcMicros.present) {
      map['paused_at_utc_micros'] = Variable<int>(pausedAtUtcMicros.value);
    }
    if (deletedAtUtcMicros.present) {
      map['deleted_at_utc_micros'] = Variable<int>(deletedAtUtcMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionRulesCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('typeKey: $typeKey, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('paymentMethodKey: $paymentMethodKey, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('frequencyKey: $frequencyKey, ')
          ..write('recurrenceCalendarKey: $recurrenceCalendarKey, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('anchorMonth: $anchorMonth, ')
          ..write('anchorWeekday: $anchorWeekday, ')
          ..write('firstDueDateAdUtcMicros: $firstDueDateAdUtcMicros, ')
          ..write('nextDueDateAdUtcMicros: $nextDueDateAdUtcMicros, ')
          ..write('statusKey: $statusKey, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('pausedAtUtcMicros: $pausedAtUtcMicros, ')
          ..write('deletedAtUtcMicros: $deletedAtUtcMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionOccurrencesTable
    extends RecurringTransactionOccurrences
    with
        TableInfo<
          $RecurringTransactionOccurrencesTable,
          RecurringTransactionOccurrence
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateAdUtcMicrosMeta =
      const VerificationMeta('dueDateAdUtcMicros');
  @override
  late final GeneratedColumn<int> dueDateAdUtcMicros = GeneratedColumn<int>(
    'due_date_ad_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusKeyMeta = const VerificationMeta(
    'statusKey',
  );
  @override
  late final GeneratedColumn<String> statusKey = GeneratedColumn<String>(
    'status_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeKeyMeta = const VerificationMeta(
    'typeKey',
  );
  @override
  late final GeneratedColumn<String> typeKey = GeneratedColumn<String>(
    'type_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodKeyMeta = const VerificationMeta(
    'paymentMethodKey',
  );
  @override
  late final GeneratedColumn<String> paymentMethodKey = GeneratedColumn<String>(
    'payment_method_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _recordedTransactionIdMeta =
      const VerificationMeta('recordedTransactionId');
  @override
  late final GeneratedColumn<String> recordedTransactionId =
      GeneratedColumn<String>(
        'recorded_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _handledAtUtcMicrosMeta =
      const VerificationMeta('handledAtUtcMicros');
  @override
  late final GeneratedColumn<int> handledAtUtcMicros = GeneratedColumn<int>(
    'handled_at_utc_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleId,
    ownerScope,
    dueDateAdUtcMicros,
    statusKey,
    typeKey,
    amountMinorUnits,
    currencyCode,
    categoryKey,
    paymentMethodKey,
    merchant,
    note,
    recordedTransactionId,
    handledAtUtcMicros,
    createdAtUtcMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transaction_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringTransactionOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('due_date_ad_utc_micros')) {
      context.handle(
        _dueDateAdUtcMicrosMeta,
        dueDateAdUtcMicros.isAcceptableOrUnknown(
          data['due_date_ad_utc_micros']!,
          _dueDateAdUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dueDateAdUtcMicrosMeta);
    }
    if (data.containsKey('status_key')) {
      context.handle(
        _statusKeyMeta,
        statusKey.isAcceptableOrUnknown(data['status_key']!, _statusKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_statusKeyMeta);
    }
    if (data.containsKey('type_key')) {
      context.handle(
        _typeKeyMeta,
        typeKey.isAcceptableOrUnknown(data['type_key']!, _typeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_typeKeyMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('payment_method_key')) {
      context.handle(
        _paymentMethodKeyMeta,
        paymentMethodKey.isAcceptableOrUnknown(
          data['payment_method_key']!,
          _paymentMethodKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodKeyMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('recorded_transaction_id')) {
      context.handle(
        _recordedTransactionIdMeta,
        recordedTransactionId.isAcceptableOrUnknown(
          data['recorded_transaction_id']!,
          _recordedTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('handled_at_utc_micros')) {
      context.handle(
        _handledAtUtcMicrosMeta,
        handledAtUtcMicros.isAcceptableOrUnknown(
          data['handled_at_utc_micros']!,
          _handledAtUtcMicrosMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerScope, ruleId, dueDateAdUtcMicros},
  ];
  @override
  RecurringTransactionOccurrence map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransactionOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      dueDateAdUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_date_ad_utc_micros'],
      )!,
      statusKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_key'],
      )!,
      typeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_key'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      paymentMethodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_key'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      recordedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_transaction_id'],
      ),
      handledAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}handled_at_utc_micros'],
      ),
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
    );
  }

  @override
  $RecurringTransactionOccurrencesTable createAlias(String alias) {
    return $RecurringTransactionOccurrencesTable(attachedDatabase, alias);
  }
}

class RecurringTransactionOccurrence extends DataClass
    implements Insertable<RecurringTransactionOccurrence> {
  final String id;
  final String ruleId;
  final String ownerScope;
  final int dueDateAdUtcMicros;
  final String statusKey;
  final String typeKey;
  final int amountMinorUnits;
  final String currencyCode;
  final String categoryKey;
  final String paymentMethodKey;
  final String? merchant;
  final String? note;
  final String? recordedTransactionId;
  final int? handledAtUtcMicros;
  final int createdAtUtcMicros;
  const RecurringTransactionOccurrence({
    required this.id,
    required this.ruleId,
    required this.ownerScope,
    required this.dueDateAdUtcMicros,
    required this.statusKey,
    required this.typeKey,
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.categoryKey,
    required this.paymentMethodKey,
    this.merchant,
    this.note,
    this.recordedTransactionId,
    this.handledAtUtcMicros,
    required this.createdAtUtcMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rule_id'] = Variable<String>(ruleId);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['due_date_ad_utc_micros'] = Variable<int>(dueDateAdUtcMicros);
    map['status_key'] = Variable<String>(statusKey);
    map['type_key'] = Variable<String>(typeKey);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['category_key'] = Variable<String>(categoryKey);
    map['payment_method_key'] = Variable<String>(paymentMethodKey);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || recordedTransactionId != null) {
      map['recorded_transaction_id'] = Variable<String>(recordedTransactionId);
    }
    if (!nullToAbsent || handledAtUtcMicros != null) {
      map['handled_at_utc_micros'] = Variable<int>(handledAtUtcMicros);
    }
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    return map;
  }

  RecurringTransactionOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionOccurrencesCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      ownerScope: Value(ownerScope),
      dueDateAdUtcMicros: Value(dueDateAdUtcMicros),
      statusKey: Value(statusKey),
      typeKey: Value(typeKey),
      amountMinorUnits: Value(amountMinorUnits),
      currencyCode: Value(currencyCode),
      categoryKey: Value(categoryKey),
      paymentMethodKey: Value(paymentMethodKey),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recordedTransactionId: recordedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedTransactionId),
      handledAtUtcMicros: handledAtUtcMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(handledAtUtcMicros),
      createdAtUtcMicros: Value(createdAtUtcMicros),
    );
  }

  factory RecurringTransactionOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransactionOccurrence(
      id: serializer.fromJson<String>(json['id']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      dueDateAdUtcMicros: serializer.fromJson<int>(json['dueDateAdUtcMicros']),
      statusKey: serializer.fromJson<String>(json['statusKey']),
      typeKey: serializer.fromJson<String>(json['typeKey']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      paymentMethodKey: serializer.fromJson<String>(json['paymentMethodKey']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      note: serializer.fromJson<String?>(json['note']),
      recordedTransactionId: serializer.fromJson<String?>(
        json['recordedTransactionId'],
      ),
      handledAtUtcMicros: serializer.fromJson<int?>(json['handledAtUtcMicros']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ruleId': serializer.toJson<String>(ruleId),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'dueDateAdUtcMicros': serializer.toJson<int>(dueDateAdUtcMicros),
      'statusKey': serializer.toJson<String>(statusKey),
      'typeKey': serializer.toJson<String>(typeKey),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'paymentMethodKey': serializer.toJson<String>(paymentMethodKey),
      'merchant': serializer.toJson<String?>(merchant),
      'note': serializer.toJson<String?>(note),
      'recordedTransactionId': serializer.toJson<String?>(
        recordedTransactionId,
      ),
      'handledAtUtcMicros': serializer.toJson<int?>(handledAtUtcMicros),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
    };
  }

  RecurringTransactionOccurrence copyWith({
    String? id,
    String? ruleId,
    String? ownerScope,
    int? dueDateAdUtcMicros,
    String? statusKey,
    String? typeKey,
    int? amountMinorUnits,
    String? currencyCode,
    String? categoryKey,
    String? paymentMethodKey,
    Value<String?> merchant = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> recordedTransactionId = const Value.absent(),
    Value<int?> handledAtUtcMicros = const Value.absent(),
    int? createdAtUtcMicros,
  }) => RecurringTransactionOccurrence(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    ownerScope: ownerScope ?? this.ownerScope,
    dueDateAdUtcMicros: dueDateAdUtcMicros ?? this.dueDateAdUtcMicros,
    statusKey: statusKey ?? this.statusKey,
    typeKey: typeKey ?? this.typeKey,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    categoryKey: categoryKey ?? this.categoryKey,
    paymentMethodKey: paymentMethodKey ?? this.paymentMethodKey,
    merchant: merchant.present ? merchant.value : this.merchant,
    note: note.present ? note.value : this.note,
    recordedTransactionId: recordedTransactionId.present
        ? recordedTransactionId.value
        : this.recordedTransactionId,
    handledAtUtcMicros: handledAtUtcMicros.present
        ? handledAtUtcMicros.value
        : this.handledAtUtcMicros,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
  );
  RecurringTransactionOccurrence copyWithCompanion(
    RecurringTransactionOccurrencesCompanion data,
  ) {
    return RecurringTransactionOccurrence(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      dueDateAdUtcMicros: data.dueDateAdUtcMicros.present
          ? data.dueDateAdUtcMicros.value
          : this.dueDateAdUtcMicros,
      statusKey: data.statusKey.present ? data.statusKey.value : this.statusKey,
      typeKey: data.typeKey.present ? data.typeKey.value : this.typeKey,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      paymentMethodKey: data.paymentMethodKey.present
          ? data.paymentMethodKey.value
          : this.paymentMethodKey,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      note: data.note.present ? data.note.value : this.note,
      recordedTransactionId: data.recordedTransactionId.present
          ? data.recordedTransactionId.value
          : this.recordedTransactionId,
      handledAtUtcMicros: data.handledAtUtcMicros.present
          ? data.handledAtUtcMicros.value
          : this.handledAtUtcMicros,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionOccurrence(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('dueDateAdUtcMicros: $dueDateAdUtcMicros, ')
          ..write('statusKey: $statusKey, ')
          ..write('typeKey: $typeKey, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('paymentMethodKey: $paymentMethodKey, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('recordedTransactionId: $recordedTransactionId, ')
          ..write('handledAtUtcMicros: $handledAtUtcMicros, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ruleId,
    ownerScope,
    dueDateAdUtcMicros,
    statusKey,
    typeKey,
    amountMinorUnits,
    currencyCode,
    categoryKey,
    paymentMethodKey,
    merchant,
    note,
    recordedTransactionId,
    handledAtUtcMicros,
    createdAtUtcMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransactionOccurrence &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.ownerScope == this.ownerScope &&
          other.dueDateAdUtcMicros == this.dueDateAdUtcMicros &&
          other.statusKey == this.statusKey &&
          other.typeKey == this.typeKey &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.categoryKey == this.categoryKey &&
          other.paymentMethodKey == this.paymentMethodKey &&
          other.merchant == this.merchant &&
          other.note == this.note &&
          other.recordedTransactionId == this.recordedTransactionId &&
          other.handledAtUtcMicros == this.handledAtUtcMicros &&
          other.createdAtUtcMicros == this.createdAtUtcMicros);
}

class RecurringTransactionOccurrencesCompanion
    extends UpdateCompanion<RecurringTransactionOccurrence> {
  final Value<String> id;
  final Value<String> ruleId;
  final Value<String> ownerScope;
  final Value<int> dueDateAdUtcMicros;
  final Value<String> statusKey;
  final Value<String> typeKey;
  final Value<int> amountMinorUnits;
  final Value<String> currencyCode;
  final Value<String> categoryKey;
  final Value<String> paymentMethodKey;
  final Value<String?> merchant;
  final Value<String?> note;
  final Value<String?> recordedTransactionId;
  final Value<int?> handledAtUtcMicros;
  final Value<int> createdAtUtcMicros;
  final Value<int> rowid;
  const RecurringTransactionOccurrencesCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.dueDateAdUtcMicros = const Value.absent(),
    this.statusKey = const Value.absent(),
    this.typeKey = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.paymentMethodKey = const Value.absent(),
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.recordedTransactionId = const Value.absent(),
    this.handledAtUtcMicros = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTransactionOccurrencesCompanion.insert({
    required String id,
    required String ruleId,
    required String ownerScope,
    required int dueDateAdUtcMicros,
    required String statusKey,
    required String typeKey,
    required int amountMinorUnits,
    required String currencyCode,
    required String categoryKey,
    required String paymentMethodKey,
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.recordedTransactionId = const Value.absent(),
    this.handledAtUtcMicros = const Value.absent(),
    required int createdAtUtcMicros,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleId = Value(ruleId),
       ownerScope = Value(ownerScope),
       dueDateAdUtcMicros = Value(dueDateAdUtcMicros),
       statusKey = Value(statusKey),
       typeKey = Value(typeKey),
       amountMinorUnits = Value(amountMinorUnits),
       currencyCode = Value(currencyCode),
       categoryKey = Value(categoryKey),
       paymentMethodKey = Value(paymentMethodKey),
       createdAtUtcMicros = Value(createdAtUtcMicros);
  static Insertable<RecurringTransactionOccurrence> custom({
    Expression<String>? id,
    Expression<String>? ruleId,
    Expression<String>? ownerScope,
    Expression<int>? dueDateAdUtcMicros,
    Expression<String>? statusKey,
    Expression<String>? typeKey,
    Expression<int>? amountMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? categoryKey,
    Expression<String>? paymentMethodKey,
    Expression<String>? merchant,
    Expression<String>? note,
    Expression<String>? recordedTransactionId,
    Expression<int>? handledAtUtcMicros,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (dueDateAdUtcMicros != null)
        'due_date_ad_utc_micros': dueDateAdUtcMicros,
      if (statusKey != null) 'status_key': statusKey,
      if (typeKey != null) 'type_key': typeKey,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (categoryKey != null) 'category_key': categoryKey,
      if (paymentMethodKey != null) 'payment_method_key': paymentMethodKey,
      if (merchant != null) 'merchant': merchant,
      if (note != null) 'note': note,
      if (recordedTransactionId != null)
        'recorded_transaction_id': recordedTransactionId,
      if (handledAtUtcMicros != null)
        'handled_at_utc_micros': handledAtUtcMicros,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTransactionOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? ruleId,
    Value<String>? ownerScope,
    Value<int>? dueDateAdUtcMicros,
    Value<String>? statusKey,
    Value<String>? typeKey,
    Value<int>? amountMinorUnits,
    Value<String>? currencyCode,
    Value<String>? categoryKey,
    Value<String>? paymentMethodKey,
    Value<String?>? merchant,
    Value<String?>? note,
    Value<String?>? recordedTransactionId,
    Value<int?>? handledAtUtcMicros,
    Value<int>? createdAtUtcMicros,
    Value<int>? rowid,
  }) {
    return RecurringTransactionOccurrencesCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      ownerScope: ownerScope ?? this.ownerScope,
      dueDateAdUtcMicros: dueDateAdUtcMicros ?? this.dueDateAdUtcMicros,
      statusKey: statusKey ?? this.statusKey,
      typeKey: typeKey ?? this.typeKey,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryKey: categoryKey ?? this.categoryKey,
      paymentMethodKey: paymentMethodKey ?? this.paymentMethodKey,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      recordedTransactionId:
          recordedTransactionId ?? this.recordedTransactionId,
      handledAtUtcMicros: handledAtUtcMicros ?? this.handledAtUtcMicros,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (dueDateAdUtcMicros.present) {
      map['due_date_ad_utc_micros'] = Variable<int>(dueDateAdUtcMicros.value);
    }
    if (statusKey.present) {
      map['status_key'] = Variable<String>(statusKey.value);
    }
    if (typeKey.present) {
      map['type_key'] = Variable<String>(typeKey.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (paymentMethodKey.present) {
      map['payment_method_key'] = Variable<String>(paymentMethodKey.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recordedTransactionId.present) {
      map['recorded_transaction_id'] = Variable<String>(
        recordedTransactionId.value,
      );
    }
    if (handledAtUtcMicros.present) {
      map['handled_at_utc_micros'] = Variable<int>(handledAtUtcMicros.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('dueDateAdUtcMicros: $dueDateAdUtcMicros, ')
          ..write('statusKey: $statusKey, ')
          ..write('typeKey: $typeKey, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('paymentMethodKey: $paymentMethodKey, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('recordedTransactionId: $recordedTransactionId, ')
          ..write('handledAtUtcMicros: $handledAtUtcMicros, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoneyPlanPreferencesTable extends MoneyPlanPreferences
    with TableInfo<$MoneyPlanPreferencesTable, MoneyPlanPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyPlanPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMicrosMeta =
      const VerificationMeta('updatedAtUtcMicros');
  @override
  late final GeneratedColumn<int> updatedAtUtcMicros = GeneratedColumn<int>(
    'updated_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerScope,
    isEnabled,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_plan_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyPlanPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    } else if (isInserting) {
      context.missing(_isEnabledMeta);
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    if (data.containsKey('updated_at_utc_micros')) {
      context.handle(
        _updatedAtUtcMicrosMeta,
        updatedAtUtcMicros.isAcceptableOrUnknown(
          data['updated_at_utc_micros']!,
          _updatedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerScope};
  @override
  MoneyPlanPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyPlanPreference(
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
      updatedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_micros'],
      )!,
    );
  }

  @override
  $MoneyPlanPreferencesTable createAlias(String alias) {
    return $MoneyPlanPreferencesTable(attachedDatabase, alias);
  }
}

class MoneyPlanPreference extends DataClass
    implements Insertable<MoneyPlanPreference> {
  final String ownerScope;
  final bool isEnabled;
  final int createdAtUtcMicros;
  final int updatedAtUtcMicros;
  const MoneyPlanPreference({
    required this.ownerScope,
    required this.isEnabled,
    required this.createdAtUtcMicros,
    required this.updatedAtUtcMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_scope'] = Variable<String>(ownerScope);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros);
    return map;
  }

  MoneyPlanPreferencesCompanion toCompanion(bool nullToAbsent) {
    return MoneyPlanPreferencesCompanion(
      ownerScope: Value(ownerScope),
      isEnabled: Value(isEnabled),
      createdAtUtcMicros: Value(createdAtUtcMicros),
      updatedAtUtcMicros: Value(updatedAtUtcMicros),
    );
  }

  factory MoneyPlanPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyPlanPreference(
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
      updatedAtUtcMicros: serializer.fromJson<int>(json['updatedAtUtcMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerScope': serializer.toJson<String>(ownerScope),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
      'updatedAtUtcMicros': serializer.toJson<int>(updatedAtUtcMicros),
    };
  }

  MoneyPlanPreference copyWith({
    String? ownerScope,
    bool? isEnabled,
    int? createdAtUtcMicros,
    int? updatedAtUtcMicros,
  }) => MoneyPlanPreference(
    ownerScope: ownerScope ?? this.ownerScope,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
    updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
  );
  MoneyPlanPreference copyWithCompanion(MoneyPlanPreferencesCompanion data) {
    return MoneyPlanPreference(
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
      updatedAtUtcMicros: data.updatedAtUtcMicros.present
          ? data.updatedAtUtcMicros.value
          : this.updatedAtUtcMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyPlanPreference(')
          ..write('ownerScope: $ownerScope, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerScope,
    isEnabled,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyPlanPreference &&
          other.ownerScope == this.ownerScope &&
          other.isEnabled == this.isEnabled &&
          other.createdAtUtcMicros == this.createdAtUtcMicros &&
          other.updatedAtUtcMicros == this.updatedAtUtcMicros);
}

class MoneyPlanPreferencesCompanion
    extends UpdateCompanion<MoneyPlanPreference> {
  final Value<String> ownerScope;
  final Value<bool> isEnabled;
  final Value<int> createdAtUtcMicros;
  final Value<int> updatedAtUtcMicros;
  final Value<int> rowid;
  const MoneyPlanPreferencesCompanion({
    this.ownerScope = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.updatedAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoneyPlanPreferencesCompanion.insert({
    required String ownerScope,
    required bool isEnabled,
    required int createdAtUtcMicros,
    required int updatedAtUtcMicros,
    this.rowid = const Value.absent(),
  }) : ownerScope = Value(ownerScope),
       isEnabled = Value(isEnabled),
       createdAtUtcMicros = Value(createdAtUtcMicros),
       updatedAtUtcMicros = Value(updatedAtUtcMicros);
  static Insertable<MoneyPlanPreference> custom({
    Expression<String>? ownerScope,
    Expression<bool>? isEnabled,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? updatedAtUtcMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (updatedAtUtcMicros != null)
        'updated_at_utc_micros': updatedAtUtcMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoneyPlanPreferencesCompanion copyWith({
    Value<String>? ownerScope,
    Value<bool>? isEnabled,
    Value<int>? createdAtUtcMicros,
    Value<int>? updatedAtUtcMicros,
    Value<int>? rowid,
  }) {
    return MoneyPlanPreferencesCompanion(
      ownerScope: ownerScope ?? this.ownerScope,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (updatedAtUtcMicros.present) {
      map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyPlanPreferencesCompanion(')
          ..write('ownerScope: $ownerScope, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoneyPlanPeriodsTable extends MoneyPlanPeriods
    with TableInfo<$MoneyPlanPeriodsTable, MoneyPlanPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyPlanPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodStartUtcMicrosMeta =
      const VerificationMeta('periodStartUtcMicros');
  @override
  late final GeneratedColumn<int> periodStartUtcMicros = GeneratedColumn<int>(
    'period_start_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndExclusiveUtcMicrosMeta =
      const VerificationMeta('periodEndExclusiveUtcMicros');
  @override
  late final GeneratedColumn<int> periodEndExclusiveUtcMicros =
      GeneratedColumn<int>(
        'period_end_exclusive_utc_micros',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calendarSystemKeyMeta = const VerificationMeta(
    'calendarSystemKey',
  );
  @override
  late final GeneratedColumn<String> calendarSystemKey =
      GeneratedColumn<String>(
        'calendar_system_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calendarYearMeta = const VerificationMeta(
    'calendarYear',
  );
  @override
  late final GeneratedColumn<int> calendarYear = GeneratedColumn<int>(
    'calendar_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calendarMonthMeta = const VerificationMeta(
    'calendarMonth',
  );
  @override
  late final GeneratedColumn<int> calendarMonth = GeneratedColumn<int>(
    'calendar_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _needsPercentMeta = const VerificationMeta(
    'needsPercent',
  );
  @override
  late final GeneratedColumn<int> needsPercent = GeneratedColumn<int>(
    'needs_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wantsPercentMeta = const VerificationMeta(
    'wantsPercent',
  );
  @override
  late final GeneratedColumn<int> wantsPercent = GeneratedColumn<int>(
    'wants_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingsPercentMeta = const VerificationMeta(
    'savingsPercent',
  );
  @override
  late final GeneratedColumn<int> savingsPercent = GeneratedColumn<int>(
    'savings_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMicrosMeta =
      const VerificationMeta('updatedAtUtcMicros');
  @override
  late final GeneratedColumn<int> updatedAtUtcMicros = GeneratedColumn<int>(
    'updated_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    periodStartUtcMicros,
    periodEndExclusiveUtcMicros,
    calendarSystemKey,
    calendarYear,
    calendarMonth,
    needsPercent,
    wantsPercent,
    savingsPercent,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_plan_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyPlanPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('period_start_utc_micros')) {
      context.handle(
        _periodStartUtcMicrosMeta,
        periodStartUtcMicros.isAcceptableOrUnknown(
          data['period_start_utc_micros']!,
          _periodStartUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartUtcMicrosMeta);
    }
    if (data.containsKey('period_end_exclusive_utc_micros')) {
      context.handle(
        _periodEndExclusiveUtcMicrosMeta,
        periodEndExclusiveUtcMicros.isAcceptableOrUnknown(
          data['period_end_exclusive_utc_micros']!,
          _periodEndExclusiveUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodEndExclusiveUtcMicrosMeta);
    }
    if (data.containsKey('calendar_system_key')) {
      context.handle(
        _calendarSystemKeyMeta,
        calendarSystemKey.isAcceptableOrUnknown(
          data['calendar_system_key']!,
          _calendarSystemKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calendarSystemKeyMeta);
    }
    if (data.containsKey('calendar_year')) {
      context.handle(
        _calendarYearMeta,
        calendarYear.isAcceptableOrUnknown(
          data['calendar_year']!,
          _calendarYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calendarYearMeta);
    }
    if (data.containsKey('calendar_month')) {
      context.handle(
        _calendarMonthMeta,
        calendarMonth.isAcceptableOrUnknown(
          data['calendar_month']!,
          _calendarMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calendarMonthMeta);
    }
    if (data.containsKey('needs_percent')) {
      context.handle(
        _needsPercentMeta,
        needsPercent.isAcceptableOrUnknown(
          data['needs_percent']!,
          _needsPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_needsPercentMeta);
    }
    if (data.containsKey('wants_percent')) {
      context.handle(
        _wantsPercentMeta,
        wantsPercent.isAcceptableOrUnknown(
          data['wants_percent']!,
          _wantsPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wantsPercentMeta);
    }
    if (data.containsKey('savings_percent')) {
      context.handle(
        _savingsPercentMeta,
        savingsPercent.isAcceptableOrUnknown(
          data['savings_percent']!,
          _savingsPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savingsPercentMeta);
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    if (data.containsKey('updated_at_utc_micros')) {
      context.handle(
        _updatedAtUtcMicrosMeta,
        updatedAtUtcMicros.isAcceptableOrUnknown(
          data['updated_at_utc_micros']!,
          _updatedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoneyPlanPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyPlanPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      periodStartUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_start_utc_micros'],
      )!,
      periodEndExclusiveUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_end_exclusive_utc_micros'],
      )!,
      calendarSystemKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_system_key'],
      )!,
      calendarYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calendar_year'],
      )!,
      calendarMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calendar_month'],
      )!,
      needsPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}needs_percent'],
      )!,
      wantsPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wants_percent'],
      )!,
      savingsPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savings_percent'],
      )!,
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
      updatedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_micros'],
      )!,
    );
  }

  @override
  $MoneyPlanPeriodsTable createAlias(String alias) {
    return $MoneyPlanPeriodsTable(attachedDatabase, alias);
  }
}

class MoneyPlanPeriod extends DataClass implements Insertable<MoneyPlanPeriod> {
  final String id;
  final String ownerScope;
  final int periodStartUtcMicros;
  final int periodEndExclusiveUtcMicros;
  final String calendarSystemKey;
  final int calendarYear;
  final int calendarMonth;
  final int needsPercent;
  final int wantsPercent;
  final int savingsPercent;
  final int createdAtUtcMicros;
  final int updatedAtUtcMicros;
  const MoneyPlanPeriod({
    required this.id,
    required this.ownerScope,
    required this.periodStartUtcMicros,
    required this.periodEndExclusiveUtcMicros,
    required this.calendarSystemKey,
    required this.calendarYear,
    required this.calendarMonth,
    required this.needsPercent,
    required this.wantsPercent,
    required this.savingsPercent,
    required this.createdAtUtcMicros,
    required this.updatedAtUtcMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['period_start_utc_micros'] = Variable<int>(periodStartUtcMicros);
    map['period_end_exclusive_utc_micros'] = Variable<int>(
      periodEndExclusiveUtcMicros,
    );
    map['calendar_system_key'] = Variable<String>(calendarSystemKey);
    map['calendar_year'] = Variable<int>(calendarYear);
    map['calendar_month'] = Variable<int>(calendarMonth);
    map['needs_percent'] = Variable<int>(needsPercent);
    map['wants_percent'] = Variable<int>(wantsPercent);
    map['savings_percent'] = Variable<int>(savingsPercent);
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros);
    return map;
  }

  MoneyPlanPeriodsCompanion toCompanion(bool nullToAbsent) {
    return MoneyPlanPeriodsCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      periodStartUtcMicros: Value(periodStartUtcMicros),
      periodEndExclusiveUtcMicros: Value(periodEndExclusiveUtcMicros),
      calendarSystemKey: Value(calendarSystemKey),
      calendarYear: Value(calendarYear),
      calendarMonth: Value(calendarMonth),
      needsPercent: Value(needsPercent),
      wantsPercent: Value(wantsPercent),
      savingsPercent: Value(savingsPercent),
      createdAtUtcMicros: Value(createdAtUtcMicros),
      updatedAtUtcMicros: Value(updatedAtUtcMicros),
    );
  }

  factory MoneyPlanPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyPlanPeriod(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      periodStartUtcMicros: serializer.fromJson<int>(
        json['periodStartUtcMicros'],
      ),
      periodEndExclusiveUtcMicros: serializer.fromJson<int>(
        json['periodEndExclusiveUtcMicros'],
      ),
      calendarSystemKey: serializer.fromJson<String>(json['calendarSystemKey']),
      calendarYear: serializer.fromJson<int>(json['calendarYear']),
      calendarMonth: serializer.fromJson<int>(json['calendarMonth']),
      needsPercent: serializer.fromJson<int>(json['needsPercent']),
      wantsPercent: serializer.fromJson<int>(json['wantsPercent']),
      savingsPercent: serializer.fromJson<int>(json['savingsPercent']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
      updatedAtUtcMicros: serializer.fromJson<int>(json['updatedAtUtcMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'periodStartUtcMicros': serializer.toJson<int>(periodStartUtcMicros),
      'periodEndExclusiveUtcMicros': serializer.toJson<int>(
        periodEndExclusiveUtcMicros,
      ),
      'calendarSystemKey': serializer.toJson<String>(calendarSystemKey),
      'calendarYear': serializer.toJson<int>(calendarYear),
      'calendarMonth': serializer.toJson<int>(calendarMonth),
      'needsPercent': serializer.toJson<int>(needsPercent),
      'wantsPercent': serializer.toJson<int>(wantsPercent),
      'savingsPercent': serializer.toJson<int>(savingsPercent),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
      'updatedAtUtcMicros': serializer.toJson<int>(updatedAtUtcMicros),
    };
  }

  MoneyPlanPeriod copyWith({
    String? id,
    String? ownerScope,
    int? periodStartUtcMicros,
    int? periodEndExclusiveUtcMicros,
    String? calendarSystemKey,
    int? calendarYear,
    int? calendarMonth,
    int? needsPercent,
    int? wantsPercent,
    int? savingsPercent,
    int? createdAtUtcMicros,
    int? updatedAtUtcMicros,
  }) => MoneyPlanPeriod(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    periodStartUtcMicros: periodStartUtcMicros ?? this.periodStartUtcMicros,
    periodEndExclusiveUtcMicros:
        periodEndExclusiveUtcMicros ?? this.periodEndExclusiveUtcMicros,
    calendarSystemKey: calendarSystemKey ?? this.calendarSystemKey,
    calendarYear: calendarYear ?? this.calendarYear,
    calendarMonth: calendarMonth ?? this.calendarMonth,
    needsPercent: needsPercent ?? this.needsPercent,
    wantsPercent: wantsPercent ?? this.wantsPercent,
    savingsPercent: savingsPercent ?? this.savingsPercent,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
    updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
  );
  MoneyPlanPeriod copyWithCompanion(MoneyPlanPeriodsCompanion data) {
    return MoneyPlanPeriod(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      periodStartUtcMicros: data.periodStartUtcMicros.present
          ? data.periodStartUtcMicros.value
          : this.periodStartUtcMicros,
      periodEndExclusiveUtcMicros: data.periodEndExclusiveUtcMicros.present
          ? data.periodEndExclusiveUtcMicros.value
          : this.periodEndExclusiveUtcMicros,
      calendarSystemKey: data.calendarSystemKey.present
          ? data.calendarSystemKey.value
          : this.calendarSystemKey,
      calendarYear: data.calendarYear.present
          ? data.calendarYear.value
          : this.calendarYear,
      calendarMonth: data.calendarMonth.present
          ? data.calendarMonth.value
          : this.calendarMonth,
      needsPercent: data.needsPercent.present
          ? data.needsPercent.value
          : this.needsPercent,
      wantsPercent: data.wantsPercent.present
          ? data.wantsPercent.value
          : this.wantsPercent,
      savingsPercent: data.savingsPercent.present
          ? data.savingsPercent.value
          : this.savingsPercent,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
      updatedAtUtcMicros: data.updatedAtUtcMicros.present
          ? data.updatedAtUtcMicros.value
          : this.updatedAtUtcMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyPlanPeriod(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('periodStartUtcMicros: $periodStartUtcMicros, ')
          ..write('periodEndExclusiveUtcMicros: $periodEndExclusiveUtcMicros, ')
          ..write('calendarSystemKey: $calendarSystemKey, ')
          ..write('calendarYear: $calendarYear, ')
          ..write('calendarMonth: $calendarMonth, ')
          ..write('needsPercent: $needsPercent, ')
          ..write('wantsPercent: $wantsPercent, ')
          ..write('savingsPercent: $savingsPercent, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerScope,
    periodStartUtcMicros,
    periodEndExclusiveUtcMicros,
    calendarSystemKey,
    calendarYear,
    calendarMonth,
    needsPercent,
    wantsPercent,
    savingsPercent,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyPlanPeriod &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.periodStartUtcMicros == this.periodStartUtcMicros &&
          other.periodEndExclusiveUtcMicros ==
              this.periodEndExclusiveUtcMicros &&
          other.calendarSystemKey == this.calendarSystemKey &&
          other.calendarYear == this.calendarYear &&
          other.calendarMonth == this.calendarMonth &&
          other.needsPercent == this.needsPercent &&
          other.wantsPercent == this.wantsPercent &&
          other.savingsPercent == this.savingsPercent &&
          other.createdAtUtcMicros == this.createdAtUtcMicros &&
          other.updatedAtUtcMicros == this.updatedAtUtcMicros);
}

class MoneyPlanPeriodsCompanion extends UpdateCompanion<MoneyPlanPeriod> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<int> periodStartUtcMicros;
  final Value<int> periodEndExclusiveUtcMicros;
  final Value<String> calendarSystemKey;
  final Value<int> calendarYear;
  final Value<int> calendarMonth;
  final Value<int> needsPercent;
  final Value<int> wantsPercent;
  final Value<int> savingsPercent;
  final Value<int> createdAtUtcMicros;
  final Value<int> updatedAtUtcMicros;
  final Value<int> rowid;
  const MoneyPlanPeriodsCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.periodStartUtcMicros = const Value.absent(),
    this.periodEndExclusiveUtcMicros = const Value.absent(),
    this.calendarSystemKey = const Value.absent(),
    this.calendarYear = const Value.absent(),
    this.calendarMonth = const Value.absent(),
    this.needsPercent = const Value.absent(),
    this.wantsPercent = const Value.absent(),
    this.savingsPercent = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.updatedAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoneyPlanPeriodsCompanion.insert({
    required String id,
    required String ownerScope,
    required int periodStartUtcMicros,
    required int periodEndExclusiveUtcMicros,
    required String calendarSystemKey,
    required int calendarYear,
    required int calendarMonth,
    required int needsPercent,
    required int wantsPercent,
    required int savingsPercent,
    required int createdAtUtcMicros,
    required int updatedAtUtcMicros,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       periodStartUtcMicros = Value(periodStartUtcMicros),
       periodEndExclusiveUtcMicros = Value(periodEndExclusiveUtcMicros),
       calendarSystemKey = Value(calendarSystemKey),
       calendarYear = Value(calendarYear),
       calendarMonth = Value(calendarMonth),
       needsPercent = Value(needsPercent),
       wantsPercent = Value(wantsPercent),
       savingsPercent = Value(savingsPercent),
       createdAtUtcMicros = Value(createdAtUtcMicros),
       updatedAtUtcMicros = Value(updatedAtUtcMicros);
  static Insertable<MoneyPlanPeriod> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<int>? periodStartUtcMicros,
    Expression<int>? periodEndExclusiveUtcMicros,
    Expression<String>? calendarSystemKey,
    Expression<int>? calendarYear,
    Expression<int>? calendarMonth,
    Expression<int>? needsPercent,
    Expression<int>? wantsPercent,
    Expression<int>? savingsPercent,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? updatedAtUtcMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (periodStartUtcMicros != null)
        'period_start_utc_micros': periodStartUtcMicros,
      if (periodEndExclusiveUtcMicros != null)
        'period_end_exclusive_utc_micros': periodEndExclusiveUtcMicros,
      if (calendarSystemKey != null) 'calendar_system_key': calendarSystemKey,
      if (calendarYear != null) 'calendar_year': calendarYear,
      if (calendarMonth != null) 'calendar_month': calendarMonth,
      if (needsPercent != null) 'needs_percent': needsPercent,
      if (wantsPercent != null) 'wants_percent': wantsPercent,
      if (savingsPercent != null) 'savings_percent': savingsPercent,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (updatedAtUtcMicros != null)
        'updated_at_utc_micros': updatedAtUtcMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoneyPlanPeriodsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<int>? periodStartUtcMicros,
    Value<int>? periodEndExclusiveUtcMicros,
    Value<String>? calendarSystemKey,
    Value<int>? calendarYear,
    Value<int>? calendarMonth,
    Value<int>? needsPercent,
    Value<int>? wantsPercent,
    Value<int>? savingsPercent,
    Value<int>? createdAtUtcMicros,
    Value<int>? updatedAtUtcMicros,
    Value<int>? rowid,
  }) {
    return MoneyPlanPeriodsCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      periodStartUtcMicros: periodStartUtcMicros ?? this.periodStartUtcMicros,
      periodEndExclusiveUtcMicros:
          periodEndExclusiveUtcMicros ?? this.periodEndExclusiveUtcMicros,
      calendarSystemKey: calendarSystemKey ?? this.calendarSystemKey,
      calendarYear: calendarYear ?? this.calendarYear,
      calendarMonth: calendarMonth ?? this.calendarMonth,
      needsPercent: needsPercent ?? this.needsPercent,
      wantsPercent: wantsPercent ?? this.wantsPercent,
      savingsPercent: savingsPercent ?? this.savingsPercent,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (periodStartUtcMicros.present) {
      map['period_start_utc_micros'] = Variable<int>(
        periodStartUtcMicros.value,
      );
    }
    if (periodEndExclusiveUtcMicros.present) {
      map['period_end_exclusive_utc_micros'] = Variable<int>(
        periodEndExclusiveUtcMicros.value,
      );
    }
    if (calendarSystemKey.present) {
      map['calendar_system_key'] = Variable<String>(calendarSystemKey.value);
    }
    if (calendarYear.present) {
      map['calendar_year'] = Variable<int>(calendarYear.value);
    }
    if (calendarMonth.present) {
      map['calendar_month'] = Variable<int>(calendarMonth.value);
    }
    if (needsPercent.present) {
      map['needs_percent'] = Variable<int>(needsPercent.value);
    }
    if (wantsPercent.present) {
      map['wants_percent'] = Variable<int>(wantsPercent.value);
    }
    if (savingsPercent.present) {
      map['savings_percent'] = Variable<int>(savingsPercent.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (updatedAtUtcMicros.present) {
      map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyPlanPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('periodStartUtcMicros: $periodStartUtcMicros, ')
          ..write('periodEndExclusiveUtcMicros: $periodEndExclusiveUtcMicros, ')
          ..write('calendarSystemKey: $calendarSystemKey, ')
          ..write('calendarYear: $calendarYear, ')
          ..write('calendarMonth: $calendarMonth, ')
          ..write('needsPercent: $needsPercent, ')
          ..write('wantsPercent: $wantsPercent, ')
          ..write('savingsPercent: $savingsPercent, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoneyPlanCategoryMappingsTable extends MoneyPlanCategoryMappings
    with TableInfo<$MoneyPlanCategoryMappingsTable, MoneyPlanCategoryMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyPlanCategoryMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<String> periodId = GeneratedColumn<String>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES money_plan_periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planGroupKeyMeta = const VerificationMeta(
    'planGroupKey',
  );
  @override
  late final GeneratedColumn<String> planGroupKey = GeneratedColumn<String>(
    'plan_group_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMicrosMeta =
      const VerificationMeta('updatedAtUtcMicros');
  @override
  late final GeneratedColumn<int> updatedAtUtcMicros = GeneratedColumn<int>(
    'updated_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    periodId,
    categoryId,
    planGroupKey,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_plan_category_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyPlanCategoryMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('plan_group_key')) {
      context.handle(
        _planGroupKeyMeta,
        planGroupKey.isAcceptableOrUnknown(
          data['plan_group_key']!,
          _planGroupKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_planGroupKeyMeta);
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    if (data.containsKey('updated_at_utc_micros')) {
      context.handle(
        _updatedAtUtcMicrosMeta,
        updatedAtUtcMicros.isAcceptableOrUnknown(
          data['updated_at_utc_micros']!,
          _updatedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoneyPlanCategoryMapping map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyPlanCategoryMapping(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      planGroupKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_group_key'],
      )!,
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
      updatedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_micros'],
      )!,
    );
  }

  @override
  $MoneyPlanCategoryMappingsTable createAlias(String alias) {
    return $MoneyPlanCategoryMappingsTable(attachedDatabase, alias);
  }
}

class MoneyPlanCategoryMapping extends DataClass
    implements Insertable<MoneyPlanCategoryMapping> {
  final String id;
  final String ownerScope;
  final String periodId;
  final String categoryId;
  final String planGroupKey;
  final int createdAtUtcMicros;
  final int updatedAtUtcMicros;
  const MoneyPlanCategoryMapping({
    required this.id,
    required this.ownerScope,
    required this.periodId,
    required this.categoryId,
    required this.planGroupKey,
    required this.createdAtUtcMicros,
    required this.updatedAtUtcMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['period_id'] = Variable<String>(periodId);
    map['category_id'] = Variable<String>(categoryId);
    map['plan_group_key'] = Variable<String>(planGroupKey);
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros);
    return map;
  }

  MoneyPlanCategoryMappingsCompanion toCompanion(bool nullToAbsent) {
    return MoneyPlanCategoryMappingsCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      periodId: Value(periodId),
      categoryId: Value(categoryId),
      planGroupKey: Value(planGroupKey),
      createdAtUtcMicros: Value(createdAtUtcMicros),
      updatedAtUtcMicros: Value(updatedAtUtcMicros),
    );
  }

  factory MoneyPlanCategoryMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyPlanCategoryMapping(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      periodId: serializer.fromJson<String>(json['periodId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      planGroupKey: serializer.fromJson<String>(json['planGroupKey']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
      updatedAtUtcMicros: serializer.fromJson<int>(json['updatedAtUtcMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'periodId': serializer.toJson<String>(periodId),
      'categoryId': serializer.toJson<String>(categoryId),
      'planGroupKey': serializer.toJson<String>(planGroupKey),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
      'updatedAtUtcMicros': serializer.toJson<int>(updatedAtUtcMicros),
    };
  }

  MoneyPlanCategoryMapping copyWith({
    String? id,
    String? ownerScope,
    String? periodId,
    String? categoryId,
    String? planGroupKey,
    int? createdAtUtcMicros,
    int? updatedAtUtcMicros,
  }) => MoneyPlanCategoryMapping(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    periodId: periodId ?? this.periodId,
    categoryId: categoryId ?? this.categoryId,
    planGroupKey: planGroupKey ?? this.planGroupKey,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
    updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
  );
  MoneyPlanCategoryMapping copyWithCompanion(
    MoneyPlanCategoryMappingsCompanion data,
  ) {
    return MoneyPlanCategoryMapping(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      planGroupKey: data.planGroupKey.present
          ? data.planGroupKey.value
          : this.planGroupKey,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
      updatedAtUtcMicros: data.updatedAtUtcMicros.present
          ? data.updatedAtUtcMicros.value
          : this.updatedAtUtcMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyPlanCategoryMapping(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('periodId: $periodId, ')
          ..write('categoryId: $categoryId, ')
          ..write('planGroupKey: $planGroupKey, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerScope,
    periodId,
    categoryId,
    planGroupKey,
    createdAtUtcMicros,
    updatedAtUtcMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyPlanCategoryMapping &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.periodId == this.periodId &&
          other.categoryId == this.categoryId &&
          other.planGroupKey == this.planGroupKey &&
          other.createdAtUtcMicros == this.createdAtUtcMicros &&
          other.updatedAtUtcMicros == this.updatedAtUtcMicros);
}

class MoneyPlanCategoryMappingsCompanion
    extends UpdateCompanion<MoneyPlanCategoryMapping> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<String> periodId;
  final Value<String> categoryId;
  final Value<String> planGroupKey;
  final Value<int> createdAtUtcMicros;
  final Value<int> updatedAtUtcMicros;
  final Value<int> rowid;
  const MoneyPlanCategoryMappingsCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.periodId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.planGroupKey = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.updatedAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoneyPlanCategoryMappingsCompanion.insert({
    required String id,
    required String ownerScope,
    required String periodId,
    required String categoryId,
    required String planGroupKey,
    required int createdAtUtcMicros,
    required int updatedAtUtcMicros,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       periodId = Value(periodId),
       categoryId = Value(categoryId),
       planGroupKey = Value(planGroupKey),
       createdAtUtcMicros = Value(createdAtUtcMicros),
       updatedAtUtcMicros = Value(updatedAtUtcMicros);
  static Insertable<MoneyPlanCategoryMapping> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<String>? periodId,
    Expression<String>? categoryId,
    Expression<String>? planGroupKey,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? updatedAtUtcMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (periodId != null) 'period_id': periodId,
      if (categoryId != null) 'category_id': categoryId,
      if (planGroupKey != null) 'plan_group_key': planGroupKey,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (updatedAtUtcMicros != null)
        'updated_at_utc_micros': updatedAtUtcMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoneyPlanCategoryMappingsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<String>? periodId,
    Value<String>? categoryId,
    Value<String>? planGroupKey,
    Value<int>? createdAtUtcMicros,
    Value<int>? updatedAtUtcMicros,
    Value<int>? rowid,
  }) {
    return MoneyPlanCategoryMappingsCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      periodId: periodId ?? this.periodId,
      categoryId: categoryId ?? this.categoryId,
      planGroupKey: planGroupKey ?? this.planGroupKey,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      updatedAtUtcMicros: updatedAtUtcMicros ?? this.updatedAtUtcMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<String>(periodId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (planGroupKey.present) {
      map['plan_group_key'] = Variable<String>(planGroupKey.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (updatedAtUtcMicros.present) {
      map['updated_at_utc_micros'] = Variable<int>(updatedAtUtcMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyPlanCategoryMappingsCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('periodId: $periodId, ')
          ..write('categoryId: $categoryId, ')
          ..write('planGroupKey: $planGroupKey, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('updatedAtUtcMicros: $updatedAtUtcMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StoredTransactionsTable storedTransactions =
      $StoredTransactionsTable(this);
  late final $StoredPreferencesTable storedPreferences =
      $StoredPreferencesTable(this);
  late final $CustomCategoriesTable customCategories = $CustomCategoriesTable(
    this,
  );
  late final $StoredTransfersTable storedTransfers = $StoredTransfersTable(
    this,
  );
  late final $RecurringTransactionRulesTable recurringTransactionRules =
      $RecurringTransactionRulesTable(this);
  late final $RecurringTransactionOccurrencesTable
  recurringTransactionOccurrences = $RecurringTransactionOccurrencesTable(this);
  late final $MoneyPlanPreferencesTable moneyPlanPreferences =
      $MoneyPlanPreferencesTable(this);
  late final $MoneyPlanPeriodsTable moneyPlanPeriods = $MoneyPlanPeriodsTable(
    this,
  );
  late final $MoneyPlanCategoryMappingsTable moneyPlanCategoryMappings =
      $MoneyPlanCategoryMappingsTable(this);
  late final Index customCategoriesOwnerTypeName = Index(
    'custom_categories_owner_type_name',
    'CREATE UNIQUE INDEX custom_categories_owner_type_name ON custom_categories (owner_scope, type_key, normalized_name)',
  );
  late final Index storedTransfersOwnerDate = Index(
    'stored_transfers_owner_date',
    'CREATE INDEX stored_transfers_owner_date ON stored_transfers (owner_scope, occurred_at_utc_micros)',
  );
  late final Index moneyPlanPeriodsOwnerIdentity = Index(
    'money_plan_periods_owner_identity',
    'CREATE UNIQUE INDEX money_plan_periods_owner_identity ON money_plan_periods (owner_scope, calendar_system_key, calendar_year, calendar_month)',
  );
  late final Index moneyPlanMappingsPeriodCategory = Index(
    'money_plan_mappings_period_category',
    'CREATE UNIQUE INDEX money_plan_mappings_period_category ON money_plan_category_mappings (period_id, category_id)',
  );
  late final Index moneyPlanMappingsOwnerPeriod = Index(
    'money_plan_mappings_owner_period',
    'CREATE INDEX money_plan_mappings_owner_period ON money_plan_category_mappings (owner_scope, period_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storedTransactions,
    storedPreferences,
    customCategories,
    storedTransfers,
    recurringTransactionRules,
    recurringTransactionOccurrences,
    moneyPlanPreferences,
    moneyPlanPeriods,
    moneyPlanCategoryMappings,
    customCategoriesOwnerTypeName,
    storedTransfersOwnerDate,
    moneyPlanPeriodsOwnerIdentity,
    moneyPlanMappingsPeriodCategory,
    moneyPlanMappingsOwnerPeriod,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'money_plan_periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('money_plan_category_mappings', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$StoredTransactionsTableCreateCompanionBuilder =
    StoredTransactionsCompanion Function({
      required String id,
      required String typeKey,
      required int amountMinorUnits,
      required String currencyCode,
      required String categoryKey,
      required String paymentMethodKey,
      required int occurredAtUtcMicros,
      Value<String?> merchant,
      Value<String?> note,
      required int createdAtUtcMicros,
      required int updatedAtUtcMicros,
      Value<String> ownerScope,
      Value<int> rowid,
    });
typedef $$StoredTransactionsTableUpdateCompanionBuilder =
    StoredTransactionsCompanion Function({
      Value<String> id,
      Value<String> typeKey,
      Value<int> amountMinorUnits,
      Value<String> currencyCode,
      Value<String> categoryKey,
      Value<String> paymentMethodKey,
      Value<int> occurredAtUtcMicros,
      Value<String?> merchant,
      Value<String?> note,
      Value<int> createdAtUtcMicros,
      Value<int> updatedAtUtcMicros,
      Value<String> ownerScope,
      Value<int> rowid,
    });

class $$StoredTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $StoredTransactionsTable> {
  $$StoredTransactionsTableFilterComposer({
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

  ColumnFilters<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAtUtcMicros => $composableBuilder(
    column: $table.occurredAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredTransactionsTable> {
  $$StoredTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAtUtcMicros => $composableBuilder(
    column: $table.occurredAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredTransactionsTable> {
  $$StoredTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get typeKey =>
      $composableBuilder(column: $table.typeKey, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAtUtcMicros => $composableBuilder(
    column: $table.occurredAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );
}

class $$StoredTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredTransactionsTable,
          StoredTransaction,
          $$StoredTransactionsTableFilterComposer,
          $$StoredTransactionsTableOrderingComposer,
          $$StoredTransactionsTableAnnotationComposer,
          $$StoredTransactionsTableCreateCompanionBuilder,
          $$StoredTransactionsTableUpdateCompanionBuilder,
          (
            StoredTransaction,
            BaseReferences<
              _$AppDatabase,
              $StoredTransactionsTable,
              StoredTransaction
            >,
          ),
          StoredTransaction,
          PrefetchHooks Function()
        > {
  $$StoredTransactionsTableTableManager(
    _$AppDatabase db,
    $StoredTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> typeKey = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<String> paymentMethodKey = const Value.absent(),
                Value<int> occurredAtUtcMicros = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> updatedAtUtcMicros = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredTransactionsCompanion(
                id: id,
                typeKey: typeKey,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                categoryKey: categoryKey,
                paymentMethodKey: paymentMethodKey,
                occurredAtUtcMicros: occurredAtUtcMicros,
                merchant: merchant,
                note: note,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                ownerScope: ownerScope,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String typeKey,
                required int amountMinorUnits,
                required String currencyCode,
                required String categoryKey,
                required String paymentMethodKey,
                required int occurredAtUtcMicros,
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAtUtcMicros,
                required int updatedAtUtcMicros,
                Value<String> ownerScope = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredTransactionsCompanion.insert(
                id: id,
                typeKey: typeKey,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                categoryKey: categoryKey,
                paymentMethodKey: paymentMethodKey,
                occurredAtUtcMicros: occurredAtUtcMicros,
                merchant: merchant,
                note: note,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                ownerScope: ownerScope,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredTransactionsTable,
      StoredTransaction,
      $$StoredTransactionsTableFilterComposer,
      $$StoredTransactionsTableOrderingComposer,
      $$StoredTransactionsTableAnnotationComposer,
      $$StoredTransactionsTableCreateCompanionBuilder,
      $$StoredTransactionsTableUpdateCompanionBuilder,
      (
        StoredTransaction,
        BaseReferences<
          _$AppDatabase,
          $StoredTransactionsTable,
          StoredTransaction
        >,
      ),
      StoredTransaction,
      PrefetchHooks Function()
    >;
typedef $$StoredPreferencesTableCreateCompanionBuilder =
    StoredPreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$StoredPreferencesTableUpdateCompanionBuilder =
    StoredPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$StoredPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $StoredPreferencesTable> {
  $$StoredPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredPreferencesTable> {
  $$StoredPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredPreferencesTable> {
  $$StoredPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$StoredPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredPreferencesTable,
          StoredPreference,
          $$StoredPreferencesTableFilterComposer,
          $$StoredPreferencesTableOrderingComposer,
          $$StoredPreferencesTableAnnotationComposer,
          $$StoredPreferencesTableCreateCompanionBuilder,
          $$StoredPreferencesTableUpdateCompanionBuilder,
          (
            StoredPreference,
            BaseReferences<
              _$AppDatabase,
              $StoredPreferencesTable,
              StoredPreference
            >,
          ),
          StoredPreference,
          PrefetchHooks Function()
        > {
  $$StoredPreferencesTableTableManager(
    _$AppDatabase db,
    $StoredPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredPreferencesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => StoredPreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredPreferencesTable,
      StoredPreference,
      $$StoredPreferencesTableFilterComposer,
      $$StoredPreferencesTableOrderingComposer,
      $$StoredPreferencesTableAnnotationComposer,
      $$StoredPreferencesTableCreateCompanionBuilder,
      $$StoredPreferencesTableUpdateCompanionBuilder,
      (
        StoredPreference,
        BaseReferences<
          _$AppDatabase,
          $StoredPreferencesTable,
          StoredPreference
        >,
      ),
      StoredPreference,
      PrefetchHooks Function()
    >;
typedef $$CustomCategoriesTableCreateCompanionBuilder =
    CustomCategoriesCompanion Function({
      required String id,
      required String ownerScope,
      required String typeKey,
      required String name,
      required String normalizedName,
      required String iconKey,
      Value<bool> isArchived,
      required int createdAtUtcMicros,
      required int updatedAtUtcMicros,
      Value<int> rowid,
    });
typedef $$CustomCategoriesTableUpdateCompanionBuilder =
    CustomCategoriesCompanion Function({
      Value<String> id,
      Value<String> ownerScope,
      Value<String> typeKey,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> iconKey,
      Value<bool> isArchived,
      Value<int> createdAtUtcMicros,
      Value<int> updatedAtUtcMicros,
      Value<int> rowid,
    });

class $$CustomCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typeKey =>
      $composableBuilder(column: $table.typeKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => column,
  );
}

class $$CustomCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomCategoriesTable,
          CustomCategory,
          $$CustomCategoriesTableFilterComposer,
          $$CustomCategoriesTableOrderingComposer,
          $$CustomCategoriesTableAnnotationComposer,
          $$CustomCategoriesTableCreateCompanionBuilder,
          $$CustomCategoriesTableUpdateCompanionBuilder,
          (
            CustomCategory,
            BaseReferences<
              _$AppDatabase,
              $CustomCategoriesTable,
              CustomCategory
            >,
          ),
          CustomCategory,
          PrefetchHooks Function()
        > {
  $$CustomCategoriesTableTableManager(
    _$AppDatabase db,
    $CustomCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<String> typeKey = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> updatedAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomCategoriesCompanion(
                id: id,
                ownerScope: ownerScope,
                typeKey: typeKey,
                name: name,
                normalizedName: normalizedName,
                iconKey: iconKey,
                isArchived: isArchived,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required String typeKey,
                required String name,
                required String normalizedName,
                required String iconKey,
                Value<bool> isArchived = const Value.absent(),
                required int createdAtUtcMicros,
                required int updatedAtUtcMicros,
                Value<int> rowid = const Value.absent(),
              }) => CustomCategoriesCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                typeKey: typeKey,
                name: name,
                normalizedName: normalizedName,
                iconKey: iconKey,
                isArchived: isArchived,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomCategoriesTable,
      CustomCategory,
      $$CustomCategoriesTableFilterComposer,
      $$CustomCategoriesTableOrderingComposer,
      $$CustomCategoriesTableAnnotationComposer,
      $$CustomCategoriesTableCreateCompanionBuilder,
      $$CustomCategoriesTableUpdateCompanionBuilder,
      (
        CustomCategory,
        BaseReferences<_$AppDatabase, $CustomCategoriesTable, CustomCategory>,
      ),
      CustomCategory,
      PrefetchHooks Function()
    >;
typedef $$StoredTransfersTableCreateCompanionBuilder =
    StoredTransfersCompanion Function({
      required String id,
      required String ownerScope,
      required int amountMinorUnits,
      required String currencyCode,
      required String sourceKey,
      required String destinationKey,
      Value<String?> destinationName,
      Value<bool> countsAsExpense,
      Value<String?> expenseCategoryKey,
      Value<int> feeMinorUnits,
      required int occurredAtUtcMicros,
      Value<String?> note,
      required int createdAtUtcMicros,
      required int updatedAtUtcMicros,
      Value<int> rowid,
    });
typedef $$StoredTransfersTableUpdateCompanionBuilder =
    StoredTransfersCompanion Function({
      Value<String> id,
      Value<String> ownerScope,
      Value<int> amountMinorUnits,
      Value<String> currencyCode,
      Value<String> sourceKey,
      Value<String> destinationKey,
      Value<String?> destinationName,
      Value<bool> countsAsExpense,
      Value<String?> expenseCategoryKey,
      Value<int> feeMinorUnits,
      Value<int> occurredAtUtcMicros,
      Value<String?> note,
      Value<int> createdAtUtcMicros,
      Value<int> updatedAtUtcMicros,
      Value<int> rowid,
    });

class $$StoredTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $StoredTransfersTable> {
  $$StoredTransfersTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationKey => $composableBuilder(
    column: $table.destinationKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get countsAsExpense => $composableBuilder(
    column: $table.countsAsExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseCategoryKey => $composableBuilder(
    column: $table.expenseCategoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feeMinorUnits => $composableBuilder(
    column: $table.feeMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAtUtcMicros => $composableBuilder(
    column: $table.occurredAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredTransfersTable> {
  $$StoredTransfersTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationKey => $composableBuilder(
    column: $table.destinationKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get countsAsExpense => $composableBuilder(
    column: $table.countsAsExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseCategoryKey => $composableBuilder(
    column: $table.expenseCategoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feeMinorUnits => $composableBuilder(
    column: $table.feeMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAtUtcMicros => $composableBuilder(
    column: $table.occurredAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredTransfersTable> {
  $$StoredTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<String> get destinationKey => $composableBuilder(
    column: $table.destinationKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get countsAsExpense => $composableBuilder(
    column: $table.countsAsExpense,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expenseCategoryKey => $composableBuilder(
    column: $table.expenseCategoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feeMinorUnits => $composableBuilder(
    column: $table.feeMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAtUtcMicros => $composableBuilder(
    column: $table.occurredAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => column,
  );
}

class $$StoredTransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredTransfersTable,
          StoredTransfer,
          $$StoredTransfersTableFilterComposer,
          $$StoredTransfersTableOrderingComposer,
          $$StoredTransfersTableAnnotationComposer,
          $$StoredTransfersTableCreateCompanionBuilder,
          $$StoredTransfersTableUpdateCompanionBuilder,
          (
            StoredTransfer,
            BaseReferences<
              _$AppDatabase,
              $StoredTransfersTable,
              StoredTransfer
            >,
          ),
          StoredTransfer,
          PrefetchHooks Function()
        > {
  $$StoredTransfersTableTableManager(
    _$AppDatabase db,
    $StoredTransfersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredTransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<String> destinationKey = const Value.absent(),
                Value<String?> destinationName = const Value.absent(),
                Value<bool> countsAsExpense = const Value.absent(),
                Value<String?> expenseCategoryKey = const Value.absent(),
                Value<int> feeMinorUnits = const Value.absent(),
                Value<int> occurredAtUtcMicros = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> updatedAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredTransfersCompanion(
                id: id,
                ownerScope: ownerScope,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                sourceKey: sourceKey,
                destinationKey: destinationKey,
                destinationName: destinationName,
                countsAsExpense: countsAsExpense,
                expenseCategoryKey: expenseCategoryKey,
                feeMinorUnits: feeMinorUnits,
                occurredAtUtcMicros: occurredAtUtcMicros,
                note: note,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required int amountMinorUnits,
                required String currencyCode,
                required String sourceKey,
                required String destinationKey,
                Value<String?> destinationName = const Value.absent(),
                Value<bool> countsAsExpense = const Value.absent(),
                Value<String?> expenseCategoryKey = const Value.absent(),
                Value<int> feeMinorUnits = const Value.absent(),
                required int occurredAtUtcMicros,
                Value<String?> note = const Value.absent(),
                required int createdAtUtcMicros,
                required int updatedAtUtcMicros,
                Value<int> rowid = const Value.absent(),
              }) => StoredTransfersCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                sourceKey: sourceKey,
                destinationKey: destinationKey,
                destinationName: destinationName,
                countsAsExpense: countsAsExpense,
                expenseCategoryKey: expenseCategoryKey,
                feeMinorUnits: feeMinorUnits,
                occurredAtUtcMicros: occurredAtUtcMicros,
                note: note,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredTransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredTransfersTable,
      StoredTransfer,
      $$StoredTransfersTableFilterComposer,
      $$StoredTransfersTableOrderingComposer,
      $$StoredTransfersTableAnnotationComposer,
      $$StoredTransfersTableCreateCompanionBuilder,
      $$StoredTransfersTableUpdateCompanionBuilder,
      (
        StoredTransfer,
        BaseReferences<_$AppDatabase, $StoredTransfersTable, StoredTransfer>,
      ),
      StoredTransfer,
      PrefetchHooks Function()
    >;
typedef $$RecurringTransactionRulesTableCreateCompanionBuilder =
    RecurringTransactionRulesCompanion Function({
      required String id,
      required String ownerScope,
      required String typeKey,
      required int amountMinorUnits,
      required String currencyCode,
      required String categoryKey,
      required String paymentMethodKey,
      Value<String?> merchant,
      Value<String?> note,
      required String frequencyKey,
      required String recurrenceCalendarKey,
      required int anchorDay,
      required int anchorMonth,
      required int anchorWeekday,
      required int firstDueDateAdUtcMicros,
      required int nextDueDateAdUtcMicros,
      required String statusKey,
      required int createdAtUtcMicros,
      required int updatedAtUtcMicros,
      Value<int?> pausedAtUtcMicros,
      Value<int?> deletedAtUtcMicros,
      Value<int> rowid,
    });
typedef $$RecurringTransactionRulesTableUpdateCompanionBuilder =
    RecurringTransactionRulesCompanion Function({
      Value<String> id,
      Value<String> ownerScope,
      Value<String> typeKey,
      Value<int> amountMinorUnits,
      Value<String> currencyCode,
      Value<String> categoryKey,
      Value<String> paymentMethodKey,
      Value<String?> merchant,
      Value<String?> note,
      Value<String> frequencyKey,
      Value<String> recurrenceCalendarKey,
      Value<int> anchorDay,
      Value<int> anchorMonth,
      Value<int> anchorWeekday,
      Value<int> firstDueDateAdUtcMicros,
      Value<int> nextDueDateAdUtcMicros,
      Value<String> statusKey,
      Value<int> createdAtUtcMicros,
      Value<int> updatedAtUtcMicros,
      Value<int?> pausedAtUtcMicros,
      Value<int?> deletedAtUtcMicros,
      Value<int> rowid,
    });

class $$RecurringTransactionRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTransactionRulesTable> {
  $$RecurringTransactionRulesTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyKey => $composableBuilder(
    column: $table.frequencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceCalendarKey => $composableBuilder(
    column: $table.recurrenceCalendarKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorMonth => $composableBuilder(
    column: $table.anchorMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorWeekday => $composableBuilder(
    column: $table.anchorWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstDueDateAdUtcMicros => $composableBuilder(
    column: $table.firstDueDateAdUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextDueDateAdUtcMicros => $composableBuilder(
    column: $table.nextDueDateAdUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusKey => $composableBuilder(
    column: $table.statusKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedAtUtcMicros => $composableBuilder(
    column: $table.pausedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtUtcMicros => $composableBuilder(
    column: $table.deletedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringTransactionRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTransactionRulesTable> {
  $$RecurringTransactionRulesTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyKey => $composableBuilder(
    column: $table.frequencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceCalendarKey => $composableBuilder(
    column: $table.recurrenceCalendarKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorMonth => $composableBuilder(
    column: $table.anchorMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorWeekday => $composableBuilder(
    column: $table.anchorWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstDueDateAdUtcMicros => $composableBuilder(
    column: $table.firstDueDateAdUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextDueDateAdUtcMicros => $composableBuilder(
    column: $table.nextDueDateAdUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusKey => $composableBuilder(
    column: $table.statusKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedAtUtcMicros => $composableBuilder(
    column: $table.pausedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtUtcMicros => $composableBuilder(
    column: $table.deletedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringTransactionRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTransactionRulesTable> {
  $$RecurringTransactionRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typeKey =>
      $composableBuilder(column: $table.typeKey, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get frequencyKey => $composableBuilder(
    column: $table.frequencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceCalendarKey => $composableBuilder(
    column: $table.recurrenceCalendarKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anchorDay =>
      $composableBuilder(column: $table.anchorDay, builder: (column) => column);

  GeneratedColumn<int> get anchorMonth => $composableBuilder(
    column: $table.anchorMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anchorWeekday => $composableBuilder(
    column: $table.anchorWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstDueDateAdUtcMicros => $composableBuilder(
    column: $table.firstDueDateAdUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextDueDateAdUtcMicros => $composableBuilder(
    column: $table.nextDueDateAdUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusKey =>
      $composableBuilder(column: $table.statusKey, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pausedAtUtcMicros => $composableBuilder(
    column: $table.pausedAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtUtcMicros => $composableBuilder(
    column: $table.deletedAtUtcMicros,
    builder: (column) => column,
  );
}

class $$RecurringTransactionRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTransactionRulesTable,
          RecurringTransactionRule,
          $$RecurringTransactionRulesTableFilterComposer,
          $$RecurringTransactionRulesTableOrderingComposer,
          $$RecurringTransactionRulesTableAnnotationComposer,
          $$RecurringTransactionRulesTableCreateCompanionBuilder,
          $$RecurringTransactionRulesTableUpdateCompanionBuilder,
          (
            RecurringTransactionRule,
            BaseReferences<
              _$AppDatabase,
              $RecurringTransactionRulesTable,
              RecurringTransactionRule
            >,
          ),
          RecurringTransactionRule,
          PrefetchHooks Function()
        > {
  $$RecurringTransactionRulesTableTableManager(
    _$AppDatabase db,
    $RecurringTransactionRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionRulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringTransactionRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringTransactionRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<String> typeKey = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<String> paymentMethodKey = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> frequencyKey = const Value.absent(),
                Value<String> recurrenceCalendarKey = const Value.absent(),
                Value<int> anchorDay = const Value.absent(),
                Value<int> anchorMonth = const Value.absent(),
                Value<int> anchorWeekday = const Value.absent(),
                Value<int> firstDueDateAdUtcMicros = const Value.absent(),
                Value<int> nextDueDateAdUtcMicros = const Value.absent(),
                Value<String> statusKey = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> updatedAtUtcMicros = const Value.absent(),
                Value<int?> pausedAtUtcMicros = const Value.absent(),
                Value<int?> deletedAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionRulesCompanion(
                id: id,
                ownerScope: ownerScope,
                typeKey: typeKey,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                categoryKey: categoryKey,
                paymentMethodKey: paymentMethodKey,
                merchant: merchant,
                note: note,
                frequencyKey: frequencyKey,
                recurrenceCalendarKey: recurrenceCalendarKey,
                anchorDay: anchorDay,
                anchorMonth: anchorMonth,
                anchorWeekday: anchorWeekday,
                firstDueDateAdUtcMicros: firstDueDateAdUtcMicros,
                nextDueDateAdUtcMicros: nextDueDateAdUtcMicros,
                statusKey: statusKey,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                pausedAtUtcMicros: pausedAtUtcMicros,
                deletedAtUtcMicros: deletedAtUtcMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required String typeKey,
                required int amountMinorUnits,
                required String currencyCode,
                required String categoryKey,
                required String paymentMethodKey,
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String frequencyKey,
                required String recurrenceCalendarKey,
                required int anchorDay,
                required int anchorMonth,
                required int anchorWeekday,
                required int firstDueDateAdUtcMicros,
                required int nextDueDateAdUtcMicros,
                required String statusKey,
                required int createdAtUtcMicros,
                required int updatedAtUtcMicros,
                Value<int?> pausedAtUtcMicros = const Value.absent(),
                Value<int?> deletedAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionRulesCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                typeKey: typeKey,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                categoryKey: categoryKey,
                paymentMethodKey: paymentMethodKey,
                merchant: merchant,
                note: note,
                frequencyKey: frequencyKey,
                recurrenceCalendarKey: recurrenceCalendarKey,
                anchorDay: anchorDay,
                anchorMonth: anchorMonth,
                anchorWeekday: anchorWeekday,
                firstDueDateAdUtcMicros: firstDueDateAdUtcMicros,
                nextDueDateAdUtcMicros: nextDueDateAdUtcMicros,
                statusKey: statusKey,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                pausedAtUtcMicros: pausedAtUtcMicros,
                deletedAtUtcMicros: deletedAtUtcMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringTransactionRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringTransactionRulesTable,
      RecurringTransactionRule,
      $$RecurringTransactionRulesTableFilterComposer,
      $$RecurringTransactionRulesTableOrderingComposer,
      $$RecurringTransactionRulesTableAnnotationComposer,
      $$RecurringTransactionRulesTableCreateCompanionBuilder,
      $$RecurringTransactionRulesTableUpdateCompanionBuilder,
      (
        RecurringTransactionRule,
        BaseReferences<
          _$AppDatabase,
          $RecurringTransactionRulesTable,
          RecurringTransactionRule
        >,
      ),
      RecurringTransactionRule,
      PrefetchHooks Function()
    >;
typedef $$RecurringTransactionOccurrencesTableCreateCompanionBuilder =
    RecurringTransactionOccurrencesCompanion Function({
      required String id,
      required String ruleId,
      required String ownerScope,
      required int dueDateAdUtcMicros,
      required String statusKey,
      required String typeKey,
      required int amountMinorUnits,
      required String currencyCode,
      required String categoryKey,
      required String paymentMethodKey,
      Value<String?> merchant,
      Value<String?> note,
      Value<String?> recordedTransactionId,
      Value<int?> handledAtUtcMicros,
      required int createdAtUtcMicros,
      Value<int> rowid,
    });
typedef $$RecurringTransactionOccurrencesTableUpdateCompanionBuilder =
    RecurringTransactionOccurrencesCompanion Function({
      Value<String> id,
      Value<String> ruleId,
      Value<String> ownerScope,
      Value<int> dueDateAdUtcMicros,
      Value<String> statusKey,
      Value<String> typeKey,
      Value<int> amountMinorUnits,
      Value<String> currencyCode,
      Value<String> categoryKey,
      Value<String> paymentMethodKey,
      Value<String?> merchant,
      Value<String?> note,
      Value<String?> recordedTransactionId,
      Value<int?> handledAtUtcMicros,
      Value<int> createdAtUtcMicros,
      Value<int> rowid,
    });

class $$RecurringTransactionOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTransactionOccurrencesTable> {
  $$RecurringTransactionOccurrencesTableFilterComposer({
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

  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDateAdUtcMicros => $composableBuilder(
    column: $table.dueDateAdUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusKey => $composableBuilder(
    column: $table.statusKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordedTransactionId => $composableBuilder(
    column: $table.recordedTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handledAtUtcMicros => $composableBuilder(
    column: $table.handledAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringTransactionOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTransactionOccurrencesTable> {
  $$RecurringTransactionOccurrencesTableOrderingComposer({
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

  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDateAdUtcMicros => $composableBuilder(
    column: $table.dueDateAdUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusKey => $composableBuilder(
    column: $table.statusKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordedTransactionId => $composableBuilder(
    column: $table.recordedTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handledAtUtcMicros => $composableBuilder(
    column: $table.handledAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringTransactionOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTransactionOccurrencesTable> {
  $$RecurringTransactionOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDateAdUtcMicros => $composableBuilder(
    column: $table.dueDateAdUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusKey =>
      $composableBuilder(column: $table.statusKey, builder: (column) => column);

  GeneratedColumn<String> get typeKey =>
      $composableBuilder(column: $table.typeKey, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethodKey => $composableBuilder(
    column: $table.paymentMethodKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get recordedTransactionId => $composableBuilder(
    column: $table.recordedTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get handledAtUtcMicros => $composableBuilder(
    column: $table.handledAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );
}

class $$RecurringTransactionOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTransactionOccurrencesTable,
          RecurringTransactionOccurrence,
          $$RecurringTransactionOccurrencesTableFilterComposer,
          $$RecurringTransactionOccurrencesTableOrderingComposer,
          $$RecurringTransactionOccurrencesTableAnnotationComposer,
          $$RecurringTransactionOccurrencesTableCreateCompanionBuilder,
          $$RecurringTransactionOccurrencesTableUpdateCompanionBuilder,
          (
            RecurringTransactionOccurrence,
            BaseReferences<
              _$AppDatabase,
              $RecurringTransactionOccurrencesTable,
              RecurringTransactionOccurrence
            >,
          ),
          RecurringTransactionOccurrence,
          PrefetchHooks Function()
        > {
  $$RecurringTransactionOccurrencesTableTableManager(
    _$AppDatabase db,
    $RecurringTransactionOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionOccurrencesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringTransactionOccurrencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringTransactionOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<int> dueDateAdUtcMicros = const Value.absent(),
                Value<String> statusKey = const Value.absent(),
                Value<String> typeKey = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<String> paymentMethodKey = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> recordedTransactionId = const Value.absent(),
                Value<int?> handledAtUtcMicros = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionOccurrencesCompanion(
                id: id,
                ruleId: ruleId,
                ownerScope: ownerScope,
                dueDateAdUtcMicros: dueDateAdUtcMicros,
                statusKey: statusKey,
                typeKey: typeKey,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                categoryKey: categoryKey,
                paymentMethodKey: paymentMethodKey,
                merchant: merchant,
                note: note,
                recordedTransactionId: recordedTransactionId,
                handledAtUtcMicros: handledAtUtcMicros,
                createdAtUtcMicros: createdAtUtcMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ruleId,
                required String ownerScope,
                required int dueDateAdUtcMicros,
                required String statusKey,
                required String typeKey,
                required int amountMinorUnits,
                required String currencyCode,
                required String categoryKey,
                required String paymentMethodKey,
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> recordedTransactionId = const Value.absent(),
                Value<int?> handledAtUtcMicros = const Value.absent(),
                required int createdAtUtcMicros,
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionOccurrencesCompanion.insert(
                id: id,
                ruleId: ruleId,
                ownerScope: ownerScope,
                dueDateAdUtcMicros: dueDateAdUtcMicros,
                statusKey: statusKey,
                typeKey: typeKey,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                categoryKey: categoryKey,
                paymentMethodKey: paymentMethodKey,
                merchant: merchant,
                note: note,
                recordedTransactionId: recordedTransactionId,
                handledAtUtcMicros: handledAtUtcMicros,
                createdAtUtcMicros: createdAtUtcMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringTransactionOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringTransactionOccurrencesTable,
      RecurringTransactionOccurrence,
      $$RecurringTransactionOccurrencesTableFilterComposer,
      $$RecurringTransactionOccurrencesTableOrderingComposer,
      $$RecurringTransactionOccurrencesTableAnnotationComposer,
      $$RecurringTransactionOccurrencesTableCreateCompanionBuilder,
      $$RecurringTransactionOccurrencesTableUpdateCompanionBuilder,
      (
        RecurringTransactionOccurrence,
        BaseReferences<
          _$AppDatabase,
          $RecurringTransactionOccurrencesTable,
          RecurringTransactionOccurrence
        >,
      ),
      RecurringTransactionOccurrence,
      PrefetchHooks Function()
    >;
typedef $$MoneyPlanPreferencesTableCreateCompanionBuilder =
    MoneyPlanPreferencesCompanion Function({
      required String ownerScope,
      required bool isEnabled,
      required int createdAtUtcMicros,
      required int updatedAtUtcMicros,
      Value<int> rowid,
    });
typedef $$MoneyPlanPreferencesTableUpdateCompanionBuilder =
    MoneyPlanPreferencesCompanion Function({
      Value<String> ownerScope,
      Value<bool> isEnabled,
      Value<int> createdAtUtcMicros,
      Value<int> updatedAtUtcMicros,
      Value<int> rowid,
    });

class $$MoneyPlanPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyPlanPreferencesTable> {
  $$MoneyPlanPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoneyPlanPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyPlanPreferencesTable> {
  $$MoneyPlanPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoneyPlanPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyPlanPreferencesTable> {
  $$MoneyPlanPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => column,
  );
}

class $$MoneyPlanPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyPlanPreferencesTable,
          MoneyPlanPreference,
          $$MoneyPlanPreferencesTableFilterComposer,
          $$MoneyPlanPreferencesTableOrderingComposer,
          $$MoneyPlanPreferencesTableAnnotationComposer,
          $$MoneyPlanPreferencesTableCreateCompanionBuilder,
          $$MoneyPlanPreferencesTableUpdateCompanionBuilder,
          (
            MoneyPlanPreference,
            BaseReferences<
              _$AppDatabase,
              $MoneyPlanPreferencesTable,
              MoneyPlanPreference
            >,
          ),
          MoneyPlanPreference,
          PrefetchHooks Function()
        > {
  $$MoneyPlanPreferencesTableTableManager(
    _$AppDatabase db,
    $MoneyPlanPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyPlanPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneyPlanPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MoneyPlanPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerScope = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> updatedAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyPlanPreferencesCompanion(
                ownerScope: ownerScope,
                isEnabled: isEnabled,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerScope,
                required bool isEnabled,
                required int createdAtUtcMicros,
                required int updatedAtUtcMicros,
                Value<int> rowid = const Value.absent(),
              }) => MoneyPlanPreferencesCompanion.insert(
                ownerScope: ownerScope,
                isEnabled: isEnabled,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoneyPlanPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyPlanPreferencesTable,
      MoneyPlanPreference,
      $$MoneyPlanPreferencesTableFilterComposer,
      $$MoneyPlanPreferencesTableOrderingComposer,
      $$MoneyPlanPreferencesTableAnnotationComposer,
      $$MoneyPlanPreferencesTableCreateCompanionBuilder,
      $$MoneyPlanPreferencesTableUpdateCompanionBuilder,
      (
        MoneyPlanPreference,
        BaseReferences<
          _$AppDatabase,
          $MoneyPlanPreferencesTable,
          MoneyPlanPreference
        >,
      ),
      MoneyPlanPreference,
      PrefetchHooks Function()
    >;
typedef $$MoneyPlanPeriodsTableCreateCompanionBuilder =
    MoneyPlanPeriodsCompanion Function({
      required String id,
      required String ownerScope,
      required int periodStartUtcMicros,
      required int periodEndExclusiveUtcMicros,
      required String calendarSystemKey,
      required int calendarYear,
      required int calendarMonth,
      required int needsPercent,
      required int wantsPercent,
      required int savingsPercent,
      required int createdAtUtcMicros,
      required int updatedAtUtcMicros,
      Value<int> rowid,
    });
typedef $$MoneyPlanPeriodsTableUpdateCompanionBuilder =
    MoneyPlanPeriodsCompanion Function({
      Value<String> id,
      Value<String> ownerScope,
      Value<int> periodStartUtcMicros,
      Value<int> periodEndExclusiveUtcMicros,
      Value<String> calendarSystemKey,
      Value<int> calendarYear,
      Value<int> calendarMonth,
      Value<int> needsPercent,
      Value<int> wantsPercent,
      Value<int> savingsPercent,
      Value<int> createdAtUtcMicros,
      Value<int> updatedAtUtcMicros,
      Value<int> rowid,
    });

final class $$MoneyPlanPeriodsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MoneyPlanPeriodsTable, MoneyPlanPeriod> {
  $$MoneyPlanPeriodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $MoneyPlanCategoryMappingsTable,
    List<MoneyPlanCategoryMapping>
  >
  _moneyPlanCategoryMappingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.moneyPlanCategoryMappings,
        aliasName: $_aliasNameGenerator(
          db.moneyPlanPeriods.id,
          db.moneyPlanCategoryMappings.periodId,
        ),
      );

  $$MoneyPlanCategoryMappingsTableProcessedTableManager
  get moneyPlanCategoryMappingsRefs {
    final manager = $$MoneyPlanCategoryMappingsTableTableManager(
      $_db,
      $_db.moneyPlanCategoryMappings,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _moneyPlanCategoryMappingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MoneyPlanPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyPlanPeriodsTable> {
  $$MoneyPlanPeriodsTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodStartUtcMicros => $composableBuilder(
    column: $table.periodStartUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodEndExclusiveUtcMicros => $composableBuilder(
    column: $table.periodEndExclusiveUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarSystemKey => $composableBuilder(
    column: $table.calendarSystemKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calendarYear => $composableBuilder(
    column: $table.calendarYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calendarMonth => $composableBuilder(
    column: $table.calendarMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get needsPercent => $composableBuilder(
    column: $table.needsPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wantsPercent => $composableBuilder(
    column: $table.wantsPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savingsPercent => $composableBuilder(
    column: $table.savingsPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> moneyPlanCategoryMappingsRefs(
    Expression<bool> Function($$MoneyPlanCategoryMappingsTableFilterComposer f)
    f,
  ) {
    final $$MoneyPlanCategoryMappingsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.moneyPlanCategoryMappings,
          getReferencedColumn: (t) => t.periodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MoneyPlanCategoryMappingsTableFilterComposer(
                $db: $db,
                $table: $db.moneyPlanCategoryMappings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MoneyPlanPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyPlanPeriodsTable> {
  $$MoneyPlanPeriodsTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodStartUtcMicros => $composableBuilder(
    column: $table.periodStartUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodEndExclusiveUtcMicros => $composableBuilder(
    column: $table.periodEndExclusiveUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarSystemKey => $composableBuilder(
    column: $table.calendarSystemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calendarYear => $composableBuilder(
    column: $table.calendarYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calendarMonth => $composableBuilder(
    column: $table.calendarMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get needsPercent => $composableBuilder(
    column: $table.needsPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wantsPercent => $composableBuilder(
    column: $table.wantsPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savingsPercent => $composableBuilder(
    column: $table.savingsPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoneyPlanPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyPlanPeriodsTable> {
  $$MoneyPlanPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodStartUtcMicros => $composableBuilder(
    column: $table.periodStartUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodEndExclusiveUtcMicros => $composableBuilder(
    column: $table.periodEndExclusiveUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarSystemKey => $composableBuilder(
    column: $table.calendarSystemKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calendarYear => $composableBuilder(
    column: $table.calendarYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calendarMonth => $composableBuilder(
    column: $table.calendarMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get needsPercent => $composableBuilder(
    column: $table.needsPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wantsPercent => $composableBuilder(
    column: $table.wantsPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savingsPercent => $composableBuilder(
    column: $table.savingsPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => column,
  );

  Expression<T> moneyPlanCategoryMappingsRefs<T extends Object>(
    Expression<T> Function($$MoneyPlanCategoryMappingsTableAnnotationComposer a)
    f,
  ) {
    final $$MoneyPlanCategoryMappingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.moneyPlanCategoryMappings,
          getReferencedColumn: (t) => t.periodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MoneyPlanCategoryMappingsTableAnnotationComposer(
                $db: $db,
                $table: $db.moneyPlanCategoryMappings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MoneyPlanPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyPlanPeriodsTable,
          MoneyPlanPeriod,
          $$MoneyPlanPeriodsTableFilterComposer,
          $$MoneyPlanPeriodsTableOrderingComposer,
          $$MoneyPlanPeriodsTableAnnotationComposer,
          $$MoneyPlanPeriodsTableCreateCompanionBuilder,
          $$MoneyPlanPeriodsTableUpdateCompanionBuilder,
          (MoneyPlanPeriod, $$MoneyPlanPeriodsTableReferences),
          MoneyPlanPeriod,
          PrefetchHooks Function({bool moneyPlanCategoryMappingsRefs})
        > {
  $$MoneyPlanPeriodsTableTableManager(
    _$AppDatabase db,
    $MoneyPlanPeriodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyPlanPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneyPlanPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoneyPlanPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<int> periodStartUtcMicros = const Value.absent(),
                Value<int> periodEndExclusiveUtcMicros = const Value.absent(),
                Value<String> calendarSystemKey = const Value.absent(),
                Value<int> calendarYear = const Value.absent(),
                Value<int> calendarMonth = const Value.absent(),
                Value<int> needsPercent = const Value.absent(),
                Value<int> wantsPercent = const Value.absent(),
                Value<int> savingsPercent = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> updatedAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyPlanPeriodsCompanion(
                id: id,
                ownerScope: ownerScope,
                periodStartUtcMicros: periodStartUtcMicros,
                periodEndExclusiveUtcMicros: periodEndExclusiveUtcMicros,
                calendarSystemKey: calendarSystemKey,
                calendarYear: calendarYear,
                calendarMonth: calendarMonth,
                needsPercent: needsPercent,
                wantsPercent: wantsPercent,
                savingsPercent: savingsPercent,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required int periodStartUtcMicros,
                required int periodEndExclusiveUtcMicros,
                required String calendarSystemKey,
                required int calendarYear,
                required int calendarMonth,
                required int needsPercent,
                required int wantsPercent,
                required int savingsPercent,
                required int createdAtUtcMicros,
                required int updatedAtUtcMicros,
                Value<int> rowid = const Value.absent(),
              }) => MoneyPlanPeriodsCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                periodStartUtcMicros: periodStartUtcMicros,
                periodEndExclusiveUtcMicros: periodEndExclusiveUtcMicros,
                calendarSystemKey: calendarSystemKey,
                calendarYear: calendarYear,
                calendarMonth: calendarMonth,
                needsPercent: needsPercent,
                wantsPercent: wantsPercent,
                savingsPercent: savingsPercent,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoneyPlanPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({moneyPlanCategoryMappingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (moneyPlanCategoryMappingsRefs) db.moneyPlanCategoryMappings,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (moneyPlanCategoryMappingsRefs)
                    await $_getPrefetchedData<
                      MoneyPlanPeriod,
                      $MoneyPlanPeriodsTable,
                      MoneyPlanCategoryMapping
                    >(
                      currentTable: table,
                      referencedTable: $$MoneyPlanPeriodsTableReferences
                          ._moneyPlanCategoryMappingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MoneyPlanPeriodsTableReferences(
                            db,
                            table,
                            p0,
                          ).moneyPlanCategoryMappingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.periodId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MoneyPlanPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyPlanPeriodsTable,
      MoneyPlanPeriod,
      $$MoneyPlanPeriodsTableFilterComposer,
      $$MoneyPlanPeriodsTableOrderingComposer,
      $$MoneyPlanPeriodsTableAnnotationComposer,
      $$MoneyPlanPeriodsTableCreateCompanionBuilder,
      $$MoneyPlanPeriodsTableUpdateCompanionBuilder,
      (MoneyPlanPeriod, $$MoneyPlanPeriodsTableReferences),
      MoneyPlanPeriod,
      PrefetchHooks Function({bool moneyPlanCategoryMappingsRefs})
    >;
typedef $$MoneyPlanCategoryMappingsTableCreateCompanionBuilder =
    MoneyPlanCategoryMappingsCompanion Function({
      required String id,
      required String ownerScope,
      required String periodId,
      required String categoryId,
      required String planGroupKey,
      required int createdAtUtcMicros,
      required int updatedAtUtcMicros,
      Value<int> rowid,
    });
typedef $$MoneyPlanCategoryMappingsTableUpdateCompanionBuilder =
    MoneyPlanCategoryMappingsCompanion Function({
      Value<String> id,
      Value<String> ownerScope,
      Value<String> periodId,
      Value<String> categoryId,
      Value<String> planGroupKey,
      Value<int> createdAtUtcMicros,
      Value<int> updatedAtUtcMicros,
      Value<int> rowid,
    });

final class $$MoneyPlanCategoryMappingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MoneyPlanCategoryMappingsTable,
          MoneyPlanCategoryMapping
        > {
  $$MoneyPlanCategoryMappingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MoneyPlanPeriodsTable _periodIdTable(_$AppDatabase db) =>
      db.moneyPlanPeriods.createAlias(
        $_aliasNameGenerator(
          db.moneyPlanCategoryMappings.periodId,
          db.moneyPlanPeriods.id,
        ),
      );

  $$MoneyPlanPeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<String>('period_id')!;

    final manager = $$MoneyPlanPeriodsTableTableManager(
      $_db,
      $_db.moneyPlanPeriods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoneyPlanCategoryMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyPlanCategoryMappingsTable> {
  $$MoneyPlanCategoryMappingsTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planGroupKey => $composableBuilder(
    column: $table.planGroupKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  $$MoneyPlanPeriodsTableFilterComposer get periodId {
    final $$MoneyPlanPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.moneyPlanPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyPlanPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.moneyPlanPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyPlanCategoryMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyPlanCategoryMappingsTable> {
  $$MoneyPlanCategoryMappingsTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planGroupKey => $composableBuilder(
    column: $table.planGroupKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  $$MoneyPlanPeriodsTableOrderingComposer get periodId {
    final $$MoneyPlanPeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.moneyPlanPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyPlanPeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.moneyPlanPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyPlanCategoryMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyPlanCategoryMappingsTable> {
  $$MoneyPlanCategoryMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planGroupKey => $composableBuilder(
    column: $table.planGroupKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMicros => $composableBuilder(
    column: $table.updatedAtUtcMicros,
    builder: (column) => column,
  );

  $$MoneyPlanPeriodsTableAnnotationComposer get periodId {
    final $$MoneyPlanPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.moneyPlanPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyPlanPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyPlanPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyPlanCategoryMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyPlanCategoryMappingsTable,
          MoneyPlanCategoryMapping,
          $$MoneyPlanCategoryMappingsTableFilterComposer,
          $$MoneyPlanCategoryMappingsTableOrderingComposer,
          $$MoneyPlanCategoryMappingsTableAnnotationComposer,
          $$MoneyPlanCategoryMappingsTableCreateCompanionBuilder,
          $$MoneyPlanCategoryMappingsTableUpdateCompanionBuilder,
          (
            MoneyPlanCategoryMapping,
            $$MoneyPlanCategoryMappingsTableReferences,
          ),
          MoneyPlanCategoryMapping,
          PrefetchHooks Function({bool periodId})
        > {
  $$MoneyPlanCategoryMappingsTableTableManager(
    _$AppDatabase db,
    $MoneyPlanCategoryMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyPlanCategoryMappingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MoneyPlanCategoryMappingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MoneyPlanCategoryMappingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<String> periodId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> planGroupKey = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> updatedAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyPlanCategoryMappingsCompanion(
                id: id,
                ownerScope: ownerScope,
                periodId: periodId,
                categoryId: categoryId,
                planGroupKey: planGroupKey,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required String periodId,
                required String categoryId,
                required String planGroupKey,
                required int createdAtUtcMicros,
                required int updatedAtUtcMicros,
                Value<int> rowid = const Value.absent(),
              }) => MoneyPlanCategoryMappingsCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                periodId: periodId,
                categoryId: categoryId,
                planGroupKey: planGroupKey,
                createdAtUtcMicros: createdAtUtcMicros,
                updatedAtUtcMicros: updatedAtUtcMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoneyPlanCategoryMappingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.periodId,
                                referencedTable:
                                    $$MoneyPlanCategoryMappingsTableReferences
                                        ._periodIdTable(db),
                                referencedColumn:
                                    $$MoneyPlanCategoryMappingsTableReferences
                                        ._periodIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MoneyPlanCategoryMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyPlanCategoryMappingsTable,
      MoneyPlanCategoryMapping,
      $$MoneyPlanCategoryMappingsTableFilterComposer,
      $$MoneyPlanCategoryMappingsTableOrderingComposer,
      $$MoneyPlanCategoryMappingsTableAnnotationComposer,
      $$MoneyPlanCategoryMappingsTableCreateCompanionBuilder,
      $$MoneyPlanCategoryMappingsTableUpdateCompanionBuilder,
      (MoneyPlanCategoryMapping, $$MoneyPlanCategoryMappingsTableReferences),
      MoneyPlanCategoryMapping,
      PrefetchHooks Function({bool periodId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoredTransactionsTableTableManager get storedTransactions =>
      $$StoredTransactionsTableTableManager(_db, _db.storedTransactions);
  $$StoredPreferencesTableTableManager get storedPreferences =>
      $$StoredPreferencesTableTableManager(_db, _db.storedPreferences);
  $$CustomCategoriesTableTableManager get customCategories =>
      $$CustomCategoriesTableTableManager(_db, _db.customCategories);
  $$StoredTransfersTableTableManager get storedTransfers =>
      $$StoredTransfersTableTableManager(_db, _db.storedTransfers);
  $$RecurringTransactionRulesTableTableManager get recurringTransactionRules =>
      $$RecurringTransactionRulesTableTableManager(
        _db,
        _db.recurringTransactionRules,
      );
  $$RecurringTransactionOccurrencesTableTableManager
  get recurringTransactionOccurrences =>
      $$RecurringTransactionOccurrencesTableTableManager(
        _db,
        _db.recurringTransactionOccurrences,
      );
  $$MoneyPlanPreferencesTableTableManager get moneyPlanPreferences =>
      $$MoneyPlanPreferencesTableTableManager(_db, _db.moneyPlanPreferences);
  $$MoneyPlanPeriodsTableTableManager get moneyPlanPeriods =>
      $$MoneyPlanPeriodsTableTableManager(_db, _db.moneyPlanPeriods);
  $$MoneyPlanCategoryMappingsTableTableManager get moneyPlanCategoryMappings =>
      $$MoneyPlanCategoryMappingsTableTableManager(
        _db,
        _db.moneyPlanCategoryMappings,
      );
}
