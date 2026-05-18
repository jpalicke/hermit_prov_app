// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomPromptsTable extends CustomPrompts
    with TableInfo<$CustomPromptsTable, CustomPromptData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomPromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptTextMeta = const VerificationMeta(
    'promptText',
  );
  @override
  late final GeneratedColumn<String> promptText = GeneratedColumn<String>(
    'prompt_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    promptText,
    category,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_prompts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomPromptData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('prompt_text')) {
      context.handle(
        _promptTextMeta,
        promptText.isAcceptableOrUnknown(data['prompt_text']!, _promptTextMeta),
      );
    } else if (isInserting) {
      context.missing(_promptTextMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomPromptData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomPromptData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      promptText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_text'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $CustomPromptsTable createAlias(String alias) {
    return $CustomPromptsTable(attachedDatabase, alias);
  }
}

class CustomPromptData extends DataClass
    implements Insertable<CustomPromptData> {
  final String id;
  final String promptText;
  final String category;
  final int createdAtMs;
  final int updatedAtMs;
  const CustomPromptData({
    required this.id,
    required this.promptText,
    required this.category,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['prompt_text'] = Variable<String>(promptText);
    map['category'] = Variable<String>(category);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  CustomPromptsCompanion toCompanion(bool nullToAbsent) {
    return CustomPromptsCompanion(
      id: Value(id),
      promptText: Value(promptText),
      category: Value(category),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory CustomPromptData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomPromptData(
      id: serializer.fromJson<String>(json['id']),
      promptText: serializer.fromJson<String>(json['promptText']),
      category: serializer.fromJson<String>(json['category']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'promptText': serializer.toJson<String>(promptText),
      'category': serializer.toJson<String>(category),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  CustomPromptData copyWith({
    String? id,
    String? promptText,
    String? category,
    int? createdAtMs,
    int? updatedAtMs,
  }) => CustomPromptData(
    id: id ?? this.id,
    promptText: promptText ?? this.promptText,
    category: category ?? this.category,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  CustomPromptData copyWithCompanion(CustomPromptsCompanion data) {
    return CustomPromptData(
      id: data.id.present ? data.id.value : this.id,
      promptText: data.promptText.present
          ? data.promptText.value
          : this.promptText,
      category: data.category.present ? data.category.value : this.category,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomPromptData(')
          ..write('id: $id, ')
          ..write('promptText: $promptText, ')
          ..write('category: $category, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, promptText, category, createdAtMs, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomPromptData &&
          other.id == this.id &&
          other.promptText == this.promptText &&
          other.category == this.category &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class CustomPromptsCompanion extends UpdateCompanion<CustomPromptData> {
  final Value<String> id;
  final Value<String> promptText;
  final Value<String> category;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const CustomPromptsCompanion({
    this.id = const Value.absent(),
    this.promptText = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomPromptsCompanion.insert({
    required String id,
    required String promptText,
    required String category,
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       promptText = Value(promptText),
       category = Value(category),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<CustomPromptData> custom({
    Expression<String>? id,
    Expression<String>? promptText,
    Expression<String>? category,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (promptText != null) 'prompt_text': promptText,
      if (category != null) 'category': category,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomPromptsCompanion copyWith({
    Value<String>? id,
    Value<String>? promptText,
    Value<String>? category,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return CustomPromptsCompanion(
      id: id ?? this.id,
      promptText: promptText ?? this.promptText,
      category: category ?? this.category,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (promptText.present) {
      map['prompt_text'] = Variable<String>(promptText.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomPromptsCompanion(')
          ..write('id: $id, ')
          ..write('promptText: $promptText, ')
          ..write('category: $category, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DrillSettingsTableTable extends DrillSettingsTable
    with TableInfo<$DrillSettingsTableTable, DrillSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrillSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _drillIdMeta = const VerificationMeta(
    'drillId',
  );
  @override
  late final GeneratedColumn<String> drillId = GeneratedColumn<String>(
    'drill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [drillId, settingsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drill_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrillSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('drill_id')) {
      context.handle(
        _drillIdMeta,
        drillId.isAcceptableOrUnknown(data['drill_id']!, _drillIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drillIdMeta);
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {drillId};
  @override
  DrillSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrillSettingsTableData(
      drillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drill_id'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
    );
  }

  @override
  $DrillSettingsTableTable createAlias(String alias) {
    return $DrillSettingsTableTable(attachedDatabase, alias);
  }
}

class DrillSettingsTableData extends DataClass
    implements Insertable<DrillSettingsTableData> {
  final String drillId;
  final String settingsJson;
  const DrillSettingsTableData({
    required this.drillId,
    required this.settingsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['drill_id'] = Variable<String>(drillId);
    map['settings_json'] = Variable<String>(settingsJson);
    return map;
  }

  DrillSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return DrillSettingsTableCompanion(
      drillId: Value(drillId),
      settingsJson: Value(settingsJson),
    );
  }

  factory DrillSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrillSettingsTableData(
      drillId: serializer.fromJson<String>(json['drillId']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'drillId': serializer.toJson<String>(drillId),
      'settingsJson': serializer.toJson<String>(settingsJson),
    };
  }

  DrillSettingsTableData copyWith({String? drillId, String? settingsJson}) =>
      DrillSettingsTableData(
        drillId: drillId ?? this.drillId,
        settingsJson: settingsJson ?? this.settingsJson,
      );
  DrillSettingsTableData copyWithCompanion(DrillSettingsTableCompanion data) {
    return DrillSettingsTableData(
      drillId: data.drillId.present ? data.drillId.value : this.drillId,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrillSettingsTableData(')
          ..write('drillId: $drillId, ')
          ..write('settingsJson: $settingsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(drillId, settingsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrillSettingsTableData &&
          other.drillId == this.drillId &&
          other.settingsJson == this.settingsJson);
}

class DrillSettingsTableCompanion
    extends UpdateCompanion<DrillSettingsTableData> {
  final Value<String> drillId;
  final Value<String> settingsJson;
  final Value<int> rowid;
  const DrillSettingsTableCompanion({
    this.drillId = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DrillSettingsTableCompanion.insert({
    required String drillId,
    required String settingsJson,
    this.rowid = const Value.absent(),
  }) : drillId = Value(drillId),
       settingsJson = Value(settingsJson);
  static Insertable<DrillSettingsTableData> custom({
    Expression<String>? drillId,
    Expression<String>? settingsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (drillId != null) 'drill_id': drillId,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DrillSettingsTableCompanion copyWith({
    Value<String>? drillId,
    Value<String>? settingsJson,
    Value<int>? rowid,
  }) {
    return DrillSettingsTableCompanion(
      drillId: drillId ?? this.drillId,
      settingsJson: settingsJson ?? this.settingsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (drillId.present) {
      map['drill_id'] = Variable<String>(drillId.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrillSettingsTableCompanion(')
          ..write('drillId: $drillId, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PracticeSessionsTable extends PracticeSessions
    with TableInfo<$PracticeSessionsTable, PracticeSessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drillIdMeta = const VerificationMeta(
    'drillId',
  );
  @override
  late final GeneratedColumn<String> drillId = GeneratedColumn<String>(
    'drill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMsMeta = const VerificationMeta(
    'loggedAtMs',
  );
  @override
  late final GeneratedColumn<int> loggedAtMs = GeneratedColumn<int>(
    'logged_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    drillId,
    startedAtMs,
    durationSeconds,
    loggedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeSessionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('drill_id')) {
      context.handle(
        _drillIdMeta,
        drillId.isAcceptableOrUnknown(data['drill_id']!, _drillIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drillIdMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('logged_at_ms')) {
      context.handle(
        _loggedAtMsMeta,
        loggedAtMs.isAcceptableOrUnknown(
          data['logged_at_ms']!,
          _loggedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeSessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeSessionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      drillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drill_id'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      loggedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}logged_at_ms'],
      )!,
    );
  }

  @override
  $PracticeSessionsTable createAlias(String alias) {
    return $PracticeSessionsTable(attachedDatabase, alias);
  }
}

class PracticeSessionData extends DataClass
    implements Insertable<PracticeSessionData> {
  final String id;
  final String drillId;
  final int startedAtMs;
  final int durationSeconds;
  final int loggedAtMs;
  const PracticeSessionData({
    required this.id,
    required this.drillId,
    required this.startedAtMs,
    required this.durationSeconds,
    required this.loggedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['drill_id'] = Variable<String>(drillId);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['logged_at_ms'] = Variable<int>(loggedAtMs);
    return map;
  }

  PracticeSessionsCompanion toCompanion(bool nullToAbsent) {
    return PracticeSessionsCompanion(
      id: Value(id),
      drillId: Value(drillId),
      startedAtMs: Value(startedAtMs),
      durationSeconds: Value(durationSeconds),
      loggedAtMs: Value(loggedAtMs),
    );
  }

  factory PracticeSessionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeSessionData(
      id: serializer.fromJson<String>(json['id']),
      drillId: serializer.fromJson<String>(json['drillId']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      loggedAtMs: serializer.fromJson<int>(json['loggedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'drillId': serializer.toJson<String>(drillId),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'loggedAtMs': serializer.toJson<int>(loggedAtMs),
    };
  }

  PracticeSessionData copyWith({
    String? id,
    String? drillId,
    int? startedAtMs,
    int? durationSeconds,
    int? loggedAtMs,
  }) => PracticeSessionData(
    id: id ?? this.id,
    drillId: drillId ?? this.drillId,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    loggedAtMs: loggedAtMs ?? this.loggedAtMs,
  );
  PracticeSessionData copyWithCompanion(PracticeSessionsCompanion data) {
    return PracticeSessionData(
      id: data.id.present ? data.id.value : this.id,
      drillId: data.drillId.present ? data.drillId.value : this.drillId,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      loggedAtMs: data.loggedAtMs.present
          ? data.loggedAtMs.value
          : this.loggedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionData(')
          ..write('id: $id, ')
          ..write('drillId: $drillId, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('loggedAtMs: $loggedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, drillId, startedAtMs, durationSeconds, loggedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeSessionData &&
          other.id == this.id &&
          other.drillId == this.drillId &&
          other.startedAtMs == this.startedAtMs &&
          other.durationSeconds == this.durationSeconds &&
          other.loggedAtMs == this.loggedAtMs);
}

class PracticeSessionsCompanion extends UpdateCompanion<PracticeSessionData> {
  final Value<String> id;
  final Value<String> drillId;
  final Value<int> startedAtMs;
  final Value<int> durationSeconds;
  final Value<int> loggedAtMs;
  final Value<int> rowid;
  const PracticeSessionsCompanion({
    this.id = const Value.absent(),
    this.drillId = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.loggedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeSessionsCompanion.insert({
    required String id,
    required String drillId,
    required int startedAtMs,
    required int durationSeconds,
    required int loggedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       drillId = Value(drillId),
       startedAtMs = Value(startedAtMs),
       durationSeconds = Value(durationSeconds),
       loggedAtMs = Value(loggedAtMs);
  static Insertable<PracticeSessionData> custom({
    Expression<String>? id,
    Expression<String>? drillId,
    Expression<int>? startedAtMs,
    Expression<int>? durationSeconds,
    Expression<int>? loggedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (drillId != null) 'drill_id': drillId,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (loggedAtMs != null) 'logged_at_ms': loggedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? drillId,
    Value<int>? startedAtMs,
    Value<int>? durationSeconds,
    Value<int>? loggedAtMs,
    Value<int>? rowid,
  }) {
    return PracticeSessionsCompanion(
      id: id ?? this.id,
      drillId: drillId ?? this.drillId,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      loggedAtMs: loggedAtMs ?? this.loggedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (drillId.present) {
      map['drill_id'] = Variable<String>(drillId.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (loggedAtMs.present) {
      map['logged_at_ms'] = Variable<int>(loggedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionsCompanion(')
          ..write('id: $id, ')
          ..write('drillId: $drillId, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('loggedAtMs: $loggedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drillTagMeta = const VerificationMeta(
    'drillTag',
  );
  @override
  late final GeneratedColumn<String> drillTag = GeneratedColumn<String>(
    'drill_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAtMs,
    updatedAtMs,
    drillTag,
    body,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('drill_tag')) {
      context.handle(
        _drillTagMeta,
        drillTag.isAcceptableOrUnknown(data['drill_tag']!, _drillTagMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      drillTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drill_tag'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntryData extends DataClass
    implements Insertable<JournalEntryData> {
  final String id;
  final int createdAtMs;
  final int updatedAtMs;
  final String? drillTag;
  final String body;
  const JournalEntryData({
    required this.id,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.drillTag,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || drillTag != null) {
      map['drill_tag'] = Variable<String>(drillTag);
    }
    map['body'] = Variable<String>(body);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      drillTag: drillTag == null && nullToAbsent
          ? const Value.absent()
          : Value(drillTag),
      body: Value(body),
    );
  }

  factory JournalEntryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntryData(
      id: serializer.fromJson<String>(json['id']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      drillTag: serializer.fromJson<String?>(json['drillTag']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'drillTag': serializer.toJson<String?>(drillTag),
      'body': serializer.toJson<String>(body),
    };
  }

  JournalEntryData copyWith({
    String? id,
    int? createdAtMs,
    int? updatedAtMs,
    Value<String?> drillTag = const Value.absent(),
    String? body,
  }) => JournalEntryData(
    id: id ?? this.id,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    drillTag: drillTag.present ? drillTag.value : this.drillTag,
    body: body ?? this.body,
  );
  JournalEntryData copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntryData(
      id: data.id.present ? data.id.value : this.id,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      drillTag: data.drillTag.present ? data.drillTag.value : this.drillTag,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntryData(')
          ..write('id: $id, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('drillTag: $drillTag, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAtMs, updatedAtMs, drillTag, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntryData &&
          other.id == this.id &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.drillTag == this.drillTag &&
          other.body == this.body);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntryData> {
  final Value<String> id;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String?> drillTag;
  final Value<String> body;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.drillTag = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required int createdAtMs,
    required int updatedAtMs,
    this.drillTag = const Value.absent(),
    required String body,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       body = Value(body);
  static Insertable<JournalEntryData> custom({
    Expression<String>? id,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? drillTag,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (drillTag != null) 'drill_tag': drillTag,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String?>? drillTag,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      drillTag: drillTag ?? this.drillTag,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (drillTag.present) {
      map['drill_tag'] = Variable<String>(drillTag.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('drillTag: $drillTag, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomPromptsTable customPrompts = $CustomPromptsTable(this);
  late final $DrillSettingsTableTable drillSettingsTable =
      $DrillSettingsTableTable(this);
  late final $PracticeSessionsTable practiceSessions = $PracticeSessionsTable(
    this,
  );
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customPrompts,
    drillSettingsTable,
    practiceSessions,
    journalEntries,
  ];
}

typedef $$CustomPromptsTableCreateCompanionBuilder =
    CustomPromptsCompanion Function({
      required String id,
      required String promptText,
      required String category,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$CustomPromptsTableUpdateCompanionBuilder =
    CustomPromptsCompanion Function({
      Value<String> id,
      Value<String> promptText,
      Value<String> category,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$CustomPromptsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomPromptsTable> {
  $$CustomPromptsTableFilterComposer({
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

  ColumnFilters<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomPromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomPromptsTable> {
  $$CustomPromptsTableOrderingComposer({
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

  ColumnOrderings<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomPromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomPromptsTable> {
  $$CustomPromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$CustomPromptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomPromptsTable,
          CustomPromptData,
          $$CustomPromptsTableFilterComposer,
          $$CustomPromptsTableOrderingComposer,
          $$CustomPromptsTableAnnotationComposer,
          $$CustomPromptsTableCreateCompanionBuilder,
          $$CustomPromptsTableUpdateCompanionBuilder,
          (
            CustomPromptData,
            BaseReferences<
              _$AppDatabase,
              $CustomPromptsTable,
              CustomPromptData
            >,
          ),
          CustomPromptData,
          PrefetchHooks Function()
        > {
  $$CustomPromptsTableTableManager(_$AppDatabase db, $CustomPromptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomPromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomPromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomPromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> promptText = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomPromptsCompanion(
                id: id,
                promptText: promptText,
                category: category,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String promptText,
                required String category,
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => CustomPromptsCompanion.insert(
                id: id,
                promptText: promptText,
                category: category,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomPromptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomPromptsTable,
      CustomPromptData,
      $$CustomPromptsTableFilterComposer,
      $$CustomPromptsTableOrderingComposer,
      $$CustomPromptsTableAnnotationComposer,
      $$CustomPromptsTableCreateCompanionBuilder,
      $$CustomPromptsTableUpdateCompanionBuilder,
      (
        CustomPromptData,
        BaseReferences<_$AppDatabase, $CustomPromptsTable, CustomPromptData>,
      ),
      CustomPromptData,
      PrefetchHooks Function()
    >;
typedef $$DrillSettingsTableTableCreateCompanionBuilder =
    DrillSettingsTableCompanion Function({
      required String drillId,
      required String settingsJson,
      Value<int> rowid,
    });
typedef $$DrillSettingsTableTableUpdateCompanionBuilder =
    DrillSettingsTableCompanion Function({
      Value<String> drillId,
      Value<String> settingsJson,
      Value<int> rowid,
    });

class $$DrillSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DrillSettingsTableTable> {
  $$DrillSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get drillId => $composableBuilder(
    column: $table.drillId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DrillSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DrillSettingsTableTable> {
  $$DrillSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get drillId => $composableBuilder(
    column: $table.drillId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DrillSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DrillSettingsTableTable> {
  $$DrillSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get drillId =>
      $composableBuilder(column: $table.drillId, builder: (column) => column);

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );
}

class $$DrillSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DrillSettingsTableTable,
          DrillSettingsTableData,
          $$DrillSettingsTableTableFilterComposer,
          $$DrillSettingsTableTableOrderingComposer,
          $$DrillSettingsTableTableAnnotationComposer,
          $$DrillSettingsTableTableCreateCompanionBuilder,
          $$DrillSettingsTableTableUpdateCompanionBuilder,
          (
            DrillSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $DrillSettingsTableTable,
              DrillSettingsTableData
            >,
          ),
          DrillSettingsTableData,
          PrefetchHooks Function()
        > {
  $$DrillSettingsTableTableTableManager(
    _$AppDatabase db,
    $DrillSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrillSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrillSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrillSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> drillId = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrillSettingsTableCompanion(
                drillId: drillId,
                settingsJson: settingsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String drillId,
                required String settingsJson,
                Value<int> rowid = const Value.absent(),
              }) => DrillSettingsTableCompanion.insert(
                drillId: drillId,
                settingsJson: settingsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DrillSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DrillSettingsTableTable,
      DrillSettingsTableData,
      $$DrillSettingsTableTableFilterComposer,
      $$DrillSettingsTableTableOrderingComposer,
      $$DrillSettingsTableTableAnnotationComposer,
      $$DrillSettingsTableTableCreateCompanionBuilder,
      $$DrillSettingsTableTableUpdateCompanionBuilder,
      (
        DrillSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $DrillSettingsTableTable,
          DrillSettingsTableData
        >,
      ),
      DrillSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$PracticeSessionsTableCreateCompanionBuilder =
    PracticeSessionsCompanion Function({
      required String id,
      required String drillId,
      required int startedAtMs,
      required int durationSeconds,
      required int loggedAtMs,
      Value<int> rowid,
    });
typedef $$PracticeSessionsTableUpdateCompanionBuilder =
    PracticeSessionsCompanion Function({
      Value<String> id,
      Value<String> drillId,
      Value<int> startedAtMs,
      Value<int> durationSeconds,
      Value<int> loggedAtMs,
      Value<int> rowid,
    });

class $$PracticeSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableFilterComposer({
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

  ColumnFilters<String> get drillId => $composableBuilder(
    column: $table.drillId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loggedAtMs => $composableBuilder(
    column: $table.loggedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PracticeSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get drillId => $composableBuilder(
    column: $table.drillId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loggedAtMs => $composableBuilder(
    column: $table.loggedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get drillId =>
      $composableBuilder(column: $table.drillId, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get loggedAtMs => $composableBuilder(
    column: $table.loggedAtMs,
    builder: (column) => column,
  );
}

class $$PracticeSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeSessionsTable,
          PracticeSessionData,
          $$PracticeSessionsTableFilterComposer,
          $$PracticeSessionsTableOrderingComposer,
          $$PracticeSessionsTableAnnotationComposer,
          $$PracticeSessionsTableCreateCompanionBuilder,
          $$PracticeSessionsTableUpdateCompanionBuilder,
          (
            PracticeSessionData,
            BaseReferences<
              _$AppDatabase,
              $PracticeSessionsTable,
              PracticeSessionData
            >,
          ),
          PracticeSessionData,
          PrefetchHooks Function()
        > {
  $$PracticeSessionsTableTableManager(
    _$AppDatabase db,
    $PracticeSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> drillId = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> loggedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeSessionsCompanion(
                id: id,
                drillId: drillId,
                startedAtMs: startedAtMs,
                durationSeconds: durationSeconds,
                loggedAtMs: loggedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String drillId,
                required int startedAtMs,
                required int durationSeconds,
                required int loggedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => PracticeSessionsCompanion.insert(
                id: id,
                drillId: drillId,
                startedAtMs: startedAtMs,
                durationSeconds: durationSeconds,
                loggedAtMs: loggedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PracticeSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeSessionsTable,
      PracticeSessionData,
      $$PracticeSessionsTableFilterComposer,
      $$PracticeSessionsTableOrderingComposer,
      $$PracticeSessionsTableAnnotationComposer,
      $$PracticeSessionsTableCreateCompanionBuilder,
      $$PracticeSessionsTableUpdateCompanionBuilder,
      (
        PracticeSessionData,
        BaseReferences<
          _$AppDatabase,
          $PracticeSessionsTable,
          PracticeSessionData
        >,
      ),
      PracticeSessionData,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required int createdAtMs,
      required int updatedAtMs,
      Value<String?> drillTag,
      required String body,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String?> drillTag,
      Value<String> body,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
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

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drillTag => $composableBuilder(
    column: $table.drillTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drillTag => $composableBuilder(
    column: $table.drillTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get drillTag =>
      $composableBuilder(column: $table.drillTag, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntryData,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntryData,
            BaseReferences<
              _$AppDatabase,
              $JournalEntriesTable,
              JournalEntryData
            >,
          ),
          JournalEntryData,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> drillTag = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                drillTag: drillTag,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAtMs,
                required int updatedAtMs,
                Value<String?> drillTag = const Value.absent(),
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                drillTag: drillTag,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntryData,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntryData,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntryData>,
      ),
      JournalEntryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomPromptsTableTableManager get customPrompts =>
      $$CustomPromptsTableTableManager(_db, _db.customPrompts);
  $$DrillSettingsTableTableTableManager get drillSettingsTable =>
      $$DrillSettingsTableTableTableManager(_db, _db.drillSettingsTable);
  $$PracticeSessionsTableTableManager get practiceSessions =>
      $$PracticeSessionsTableTableManager(_db, _db.practiceSessions);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
}
