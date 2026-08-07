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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StoredTransactionsTable storedTransactions =
      $StoredTransactionsTable(this);
  late final $StoredPreferencesTable storedPreferences =
      $StoredPreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storedTransactions,
    storedPreferences,
  ];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoredTransactionsTableTableManager get storedTransactions =>
      $$StoredTransactionsTableTableManager(_db, _db.storedTransactions);
  $$StoredPreferencesTableTableManager get storedPreferences =>
      $$StoredPreferencesTableTableManager(_db, _db.storedPreferences);
}
