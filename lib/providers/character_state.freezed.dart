// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'character_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CharacterDraft _$CharacterDraftFromJson(Map<String, dynamic> json) {
  return _CharacterDraft.fromJson(json);
}

/// @nodoc
mixin _$CharacterDraft {
  String get name => throw _privateConstructorUsedError; // Le scelte principali
  DaggerheartClass? get selectedClass => throw _privateConstructorUsedError;
  Subclass? get subclass => throw _privateConstructorUsedError;
  Ancestry? get ancestry => throw _privateConstructorUsedError;
  Community? get community => throw _privateConstructorUsedError;
  Weapon? get primaryWeapon => throw _privateConstructorUsedError;
  Weapon? get secondaryWeapon => throw _privateConstructorUsedError;
  Armor? get selectedArmor =>
      throw _privateConstructorUsedError; // Carte Dominio (Nuovo campo)
  List<DomainCard> get selectedDomainCards =>
      throw _privateConstructorUsedError; // Attributi (Stats)
  int get agility => throw _privateConstructorUsedError;
  int get strength => throw _privateConstructorUsedError;
  int get finesse => throw _privateConstructorUsedError;
  int get instinct => throw _privateConstructorUsedError;
  int get presence => throw _privateConstructorUsedError;
  int get knowledge => throw _privateConstructorUsedError; // Stato di gioco
  int get maxHp => throw _privateConstructorUsedError;
  int get currentHp => throw _privateConstructorUsedError;
  int get stress => throw _privateConstructorUsedError;
  int get hope => throw _privateConstructorUsedError;
  int get evasion => throw _privateConstructorUsedError; // Livello
  int get level =>
      throw _privateConstructorUsedError; // NUOVI CAMPI PER BACKGROUND & LORE
  List<String> get startingItems =>
      throw _privateConstructorUsedError; // L'oggetto scelto dall'inventario
  Map<String, String> get backgroundAnswers =>
      throw _privateConstructorUsedError; // Domanda -> Risposta
  Map<String, String> get connectionAnswers =>
      throw _privateConstructorUsedError;

  /// Serializes this CharacterDraft to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CharacterDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CharacterDraftCopyWith<CharacterDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterDraftCopyWith<$Res> {
  factory $CharacterDraftCopyWith(
          CharacterDraft value, $Res Function(CharacterDraft) then) =
      _$CharacterDraftCopyWithImpl<$Res, CharacterDraft>;
  @useResult
  $Res call(
      {String name,
      DaggerheartClass? selectedClass,
      Subclass? subclass,
      Ancestry? ancestry,
      Community? community,
      Weapon? primaryWeapon,
      Weapon? secondaryWeapon,
      Armor? selectedArmor,
      List<DomainCard> selectedDomainCards,
      int agility,
      int strength,
      int finesse,
      int instinct,
      int presence,
      int knowledge,
      int maxHp,
      int currentHp,
      int stress,
      int hope,
      int evasion,
      int level,
      List<String> startingItems,
      Map<String, String> backgroundAnswers,
      Map<String, String> connectionAnswers});
}

/// @nodoc
class _$CharacterDraftCopyWithImpl<$Res, $Val extends CharacterDraft>
    implements $CharacterDraftCopyWith<$Res> {
  _$CharacterDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CharacterDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? selectedClass = freezed,
    Object? subclass = freezed,
    Object? ancestry = freezed,
    Object? community = freezed,
    Object? primaryWeapon = freezed,
    Object? secondaryWeapon = freezed,
    Object? selectedArmor = freezed,
    Object? selectedDomainCards = null,
    Object? agility = null,
    Object? strength = null,
    Object? finesse = null,
    Object? instinct = null,
    Object? presence = null,
    Object? knowledge = null,
    Object? maxHp = null,
    Object? currentHp = null,
    Object? stress = null,
    Object? hope = null,
    Object? evasion = null,
    Object? level = null,
    Object? startingItems = null,
    Object? backgroundAnswers = null,
    Object? connectionAnswers = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      selectedClass: freezed == selectedClass
          ? _value.selectedClass
          : selectedClass // ignore: cast_nullable_to_non_nullable
              as DaggerheartClass?,
      subclass: freezed == subclass
          ? _value.subclass
          : subclass // ignore: cast_nullable_to_non_nullable
              as Subclass?,
      ancestry: freezed == ancestry
          ? _value.ancestry
          : ancestry // ignore: cast_nullable_to_non_nullable
              as Ancestry?,
      community: freezed == community
          ? _value.community
          : community // ignore: cast_nullable_to_non_nullable
              as Community?,
      primaryWeapon: freezed == primaryWeapon
          ? _value.primaryWeapon
          : primaryWeapon // ignore: cast_nullable_to_non_nullable
              as Weapon?,
      secondaryWeapon: freezed == secondaryWeapon
          ? _value.secondaryWeapon
          : secondaryWeapon // ignore: cast_nullable_to_non_nullable
              as Weapon?,
      selectedArmor: freezed == selectedArmor
          ? _value.selectedArmor
          : selectedArmor // ignore: cast_nullable_to_non_nullable
              as Armor?,
      selectedDomainCards: null == selectedDomainCards
          ? _value.selectedDomainCards
          : selectedDomainCards // ignore: cast_nullable_to_non_nullable
              as List<DomainCard>,
      agility: null == agility
          ? _value.agility
          : agility // ignore: cast_nullable_to_non_nullable
              as int,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as int,
      finesse: null == finesse
          ? _value.finesse
          : finesse // ignore: cast_nullable_to_non_nullable
              as int,
      instinct: null == instinct
          ? _value.instinct
          : instinct // ignore: cast_nullable_to_non_nullable
              as int,
      presence: null == presence
          ? _value.presence
          : presence // ignore: cast_nullable_to_non_nullable
              as int,
      knowledge: null == knowledge
          ? _value.knowledge
          : knowledge // ignore: cast_nullable_to_non_nullable
              as int,
      maxHp: null == maxHp
          ? _value.maxHp
          : maxHp // ignore: cast_nullable_to_non_nullable
              as int,
      currentHp: null == currentHp
          ? _value.currentHp
          : currentHp // ignore: cast_nullable_to_non_nullable
              as int,
      stress: null == stress
          ? _value.stress
          : stress // ignore: cast_nullable_to_non_nullable
              as int,
      hope: null == hope
          ? _value.hope
          : hope // ignore: cast_nullable_to_non_nullable
              as int,
      evasion: null == evasion
          ? _value.evasion
          : evasion // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      startingItems: null == startingItems
          ? _value.startingItems
          : startingItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      backgroundAnswers: null == backgroundAnswers
          ? _value.backgroundAnswers
          : backgroundAnswers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      connectionAnswers: null == connectionAnswers
          ? _value.connectionAnswers
          : connectionAnswers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CharacterDraftImplCopyWith<$Res>
    implements $CharacterDraftCopyWith<$Res> {
  factory _$$CharacterDraftImplCopyWith(_$CharacterDraftImpl value,
          $Res Function(_$CharacterDraftImpl) then) =
      __$$CharacterDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      DaggerheartClass? selectedClass,
      Subclass? subclass,
      Ancestry? ancestry,
      Community? community,
      Weapon? primaryWeapon,
      Weapon? secondaryWeapon,
      Armor? selectedArmor,
      List<DomainCard> selectedDomainCards,
      int agility,
      int strength,
      int finesse,
      int instinct,
      int presence,
      int knowledge,
      int maxHp,
      int currentHp,
      int stress,
      int hope,
      int evasion,
      int level,
      List<String> startingItems,
      Map<String, String> backgroundAnswers,
      Map<String, String> connectionAnswers});
}

/// @nodoc
class __$$CharacterDraftImplCopyWithImpl<$Res>
    extends _$CharacterDraftCopyWithImpl<$Res, _$CharacterDraftImpl>
    implements _$$CharacterDraftImplCopyWith<$Res> {
  __$$CharacterDraftImplCopyWithImpl(
      _$CharacterDraftImpl _value, $Res Function(_$CharacterDraftImpl) _then)
      : super(_value, _then);

  /// Create a copy of CharacterDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? selectedClass = freezed,
    Object? subclass = freezed,
    Object? ancestry = freezed,
    Object? community = freezed,
    Object? primaryWeapon = freezed,
    Object? secondaryWeapon = freezed,
    Object? selectedArmor = freezed,
    Object? selectedDomainCards = null,
    Object? agility = null,
    Object? strength = null,
    Object? finesse = null,
    Object? instinct = null,
    Object? presence = null,
    Object? knowledge = null,
    Object? maxHp = null,
    Object? currentHp = null,
    Object? stress = null,
    Object? hope = null,
    Object? evasion = null,
    Object? level = null,
    Object? startingItems = null,
    Object? backgroundAnswers = null,
    Object? connectionAnswers = null,
  }) {
    return _then(_$CharacterDraftImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      selectedClass: freezed == selectedClass
          ? _value.selectedClass
          : selectedClass // ignore: cast_nullable_to_non_nullable
              as DaggerheartClass?,
      subclass: freezed == subclass
          ? _value.subclass
          : subclass // ignore: cast_nullable_to_non_nullable
              as Subclass?,
      ancestry: freezed == ancestry
          ? _value.ancestry
          : ancestry // ignore: cast_nullable_to_non_nullable
              as Ancestry?,
      community: freezed == community
          ? _value.community
          : community // ignore: cast_nullable_to_non_nullable
              as Community?,
      primaryWeapon: freezed == primaryWeapon
          ? _value.primaryWeapon
          : primaryWeapon // ignore: cast_nullable_to_non_nullable
              as Weapon?,
      secondaryWeapon: freezed == secondaryWeapon
          ? _value.secondaryWeapon
          : secondaryWeapon // ignore: cast_nullable_to_non_nullable
              as Weapon?,
      selectedArmor: freezed == selectedArmor
          ? _value.selectedArmor
          : selectedArmor // ignore: cast_nullable_to_non_nullable
              as Armor?,
      selectedDomainCards: null == selectedDomainCards
          ? _value._selectedDomainCards
          : selectedDomainCards // ignore: cast_nullable_to_non_nullable
              as List<DomainCard>,
      agility: null == agility
          ? _value.agility
          : agility // ignore: cast_nullable_to_non_nullable
              as int,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as int,
      finesse: null == finesse
          ? _value.finesse
          : finesse // ignore: cast_nullable_to_non_nullable
              as int,
      instinct: null == instinct
          ? _value.instinct
          : instinct // ignore: cast_nullable_to_non_nullable
              as int,
      presence: null == presence
          ? _value.presence
          : presence // ignore: cast_nullable_to_non_nullable
              as int,
      knowledge: null == knowledge
          ? _value.knowledge
          : knowledge // ignore: cast_nullable_to_non_nullable
              as int,
      maxHp: null == maxHp
          ? _value.maxHp
          : maxHp // ignore: cast_nullable_to_non_nullable
              as int,
      currentHp: null == currentHp
          ? _value.currentHp
          : currentHp // ignore: cast_nullable_to_non_nullable
              as int,
      stress: null == stress
          ? _value.stress
          : stress // ignore: cast_nullable_to_non_nullable
              as int,
      hope: null == hope
          ? _value.hope
          : hope // ignore: cast_nullable_to_non_nullable
              as int,
      evasion: null == evasion
          ? _value.evasion
          : evasion // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      startingItems: null == startingItems
          ? _value._startingItems
          : startingItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      backgroundAnswers: null == backgroundAnswers
          ? _value._backgroundAnswers
          : backgroundAnswers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      connectionAnswers: null == connectionAnswers
          ? _value._connectionAnswers
          : connectionAnswers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CharacterDraftImpl implements _CharacterDraft {
  const _$CharacterDraftImpl(
      {this.name = "New Character",
      this.selectedClass,
      this.subclass,
      this.ancestry,
      this.community,
      this.primaryWeapon,
      this.secondaryWeapon,
      this.selectedArmor,
      final List<DomainCard> selectedDomainCards = const [],
      this.agility = 0,
      this.strength = 0,
      this.finesse = 0,
      this.instinct = 0,
      this.presence = 0,
      this.knowledge = 0,
      this.maxHp = 6,
      this.currentHp = 6,
      this.stress = 0,
      this.hope = 2,
      this.evasion = 10,
      this.level = 1,
      final List<String> startingItems = const [],
      final Map<String, String> backgroundAnswers = const {},
      final Map<String, String> connectionAnswers = const {}})
      : _selectedDomainCards = selectedDomainCards,
        _startingItems = startingItems,
        _backgroundAnswers = backgroundAnswers,
        _connectionAnswers = connectionAnswers;

  factory _$CharacterDraftImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterDraftImplFromJson(json);

  @override
  @JsonKey()
  final String name;
// Le scelte principali
  @override
  final DaggerheartClass? selectedClass;
  @override
  final Subclass? subclass;
  @override
  final Ancestry? ancestry;
  @override
  final Community? community;
  @override
  final Weapon? primaryWeapon;
  @override
  final Weapon? secondaryWeapon;
  @override
  final Armor? selectedArmor;
// Carte Dominio (Nuovo campo)
  final List<DomainCard> _selectedDomainCards;
// Carte Dominio (Nuovo campo)
  @override
  @JsonKey()
  List<DomainCard> get selectedDomainCards {
    if (_selectedDomainCards is EqualUnmodifiableListView)
      return _selectedDomainCards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedDomainCards);
  }

// Attributi (Stats)
  @override
  @JsonKey()
  final int agility;
  @override
  @JsonKey()
  final int strength;
  @override
  @JsonKey()
  final int finesse;
  @override
  @JsonKey()
  final int instinct;
  @override
  @JsonKey()
  final int presence;
  @override
  @JsonKey()
  final int knowledge;
// Stato di gioco
  @override
  @JsonKey()
  final int maxHp;
  @override
  @JsonKey()
  final int currentHp;
  @override
  @JsonKey()
  final int stress;
  @override
  @JsonKey()
  final int hope;
  @override
  @JsonKey()
  final int evasion;
// Livello
  @override
  @JsonKey()
  final int level;
// NUOVI CAMPI PER BACKGROUND & LORE
  final List<String> _startingItems;
// NUOVI CAMPI PER BACKGROUND & LORE
  @override
  @JsonKey()
  List<String> get startingItems {
    if (_startingItems is EqualUnmodifiableListView) return _startingItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_startingItems);
  }

// L'oggetto scelto dall'inventario
  final Map<String, String> _backgroundAnswers;
// L'oggetto scelto dall'inventario
  @override
  @JsonKey()
  Map<String, String> get backgroundAnswers {
    if (_backgroundAnswers is EqualUnmodifiableMapView)
      return _backgroundAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_backgroundAnswers);
  }

// Domanda -> Risposta
  final Map<String, String> _connectionAnswers;
// Domanda -> Risposta
  @override
  @JsonKey()
  Map<String, String> get connectionAnswers {
    if (_connectionAnswers is EqualUnmodifiableMapView)
      return _connectionAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_connectionAnswers);
  }

  @override
  String toString() {
    return 'CharacterDraft(name: $name, selectedClass: $selectedClass, subclass: $subclass, ancestry: $ancestry, community: $community, primaryWeapon: $primaryWeapon, secondaryWeapon: $secondaryWeapon, selectedArmor: $selectedArmor, selectedDomainCards: $selectedDomainCards, agility: $agility, strength: $strength, finesse: $finesse, instinct: $instinct, presence: $presence, knowledge: $knowledge, maxHp: $maxHp, currentHp: $currentHp, stress: $stress, hope: $hope, evasion: $evasion, level: $level, startingItems: $startingItems, backgroundAnswers: $backgroundAnswers, connectionAnswers: $connectionAnswers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterDraftImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.selectedClass, selectedClass) ||
                other.selectedClass == selectedClass) &&
            (identical(other.subclass, subclass) ||
                other.subclass == subclass) &&
            (identical(other.ancestry, ancestry) ||
                other.ancestry == ancestry) &&
            (identical(other.community, community) ||
                other.community == community) &&
            (identical(other.primaryWeapon, primaryWeapon) ||
                other.primaryWeapon == primaryWeapon) &&
            (identical(other.secondaryWeapon, secondaryWeapon) ||
                other.secondaryWeapon == secondaryWeapon) &&
            (identical(other.selectedArmor, selectedArmor) ||
                other.selectedArmor == selectedArmor) &&
            const DeepCollectionEquality()
                .equals(other._selectedDomainCards, _selectedDomainCards) &&
            (identical(other.agility, agility) || other.agility == agility) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.finesse, finesse) || other.finesse == finesse) &&
            (identical(other.instinct, instinct) ||
                other.instinct == instinct) &&
            (identical(other.presence, presence) ||
                other.presence == presence) &&
            (identical(other.knowledge, knowledge) ||
                other.knowledge == knowledge) &&
            (identical(other.maxHp, maxHp) || other.maxHp == maxHp) &&
            (identical(other.currentHp, currentHp) ||
                other.currentHp == currentHp) &&
            (identical(other.stress, stress) || other.stress == stress) &&
            (identical(other.hope, hope) || other.hope == hope) &&
            (identical(other.evasion, evasion) || other.evasion == evasion) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality()
                .equals(other._startingItems, _startingItems) &&
            const DeepCollectionEquality()
                .equals(other._backgroundAnswers, _backgroundAnswers) &&
            const DeepCollectionEquality()
                .equals(other._connectionAnswers, _connectionAnswers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        name,
        selectedClass,
        subclass,
        ancestry,
        community,
        primaryWeapon,
        secondaryWeapon,
        selectedArmor,
        const DeepCollectionEquality().hash(_selectedDomainCards),
        agility,
        strength,
        finesse,
        instinct,
        presence,
        knowledge,
        maxHp,
        currentHp,
        stress,
        hope,
        evasion,
        level,
        const DeepCollectionEquality().hash(_startingItems),
        const DeepCollectionEquality().hash(_backgroundAnswers),
        const DeepCollectionEquality().hash(_connectionAnswers)
      ]);

  /// Create a copy of CharacterDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterDraftImplCopyWith<_$CharacterDraftImpl> get copyWith =>
      __$$CharacterDraftImplCopyWithImpl<_$CharacterDraftImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CharacterDraftImplToJson(
      this,
    );
  }
}

abstract class _CharacterDraft implements CharacterDraft {
  const factory _CharacterDraft(
      {final String name,
      final DaggerheartClass? selectedClass,
      final Subclass? subclass,
      final Ancestry? ancestry,
      final Community? community,
      final Weapon? primaryWeapon,
      final Weapon? secondaryWeapon,
      final Armor? selectedArmor,
      final List<DomainCard> selectedDomainCards,
      final int agility,
      final int strength,
      final int finesse,
      final int instinct,
      final int presence,
      final int knowledge,
      final int maxHp,
      final int currentHp,
      final int stress,
      final int hope,
      final int evasion,
      final int level,
      final List<String> startingItems,
      final Map<String, String> backgroundAnswers,
      final Map<String, String> connectionAnswers}) = _$CharacterDraftImpl;

  factory _CharacterDraft.fromJson(Map<String, dynamic> json) =
      _$CharacterDraftImpl.fromJson;

  @override
  String get name; // Le scelte principali
  @override
  DaggerheartClass? get selectedClass;
  @override
  Subclass? get subclass;
  @override
  Ancestry? get ancestry;
  @override
  Community? get community;
  @override
  Weapon? get primaryWeapon;
  @override
  Weapon? get secondaryWeapon;
  @override
  Armor? get selectedArmor; // Carte Dominio (Nuovo campo)
  @override
  List<DomainCard> get selectedDomainCards; // Attributi (Stats)
  @override
  int get agility;
  @override
  int get strength;
  @override
  int get finesse;
  @override
  int get instinct;
  @override
  int get presence;
  @override
  int get knowledge; // Stato di gioco
  @override
  int get maxHp;
  @override
  int get currentHp;
  @override
  int get stress;
  @override
  int get hope;
  @override
  int get evasion; // Livello
  @override
  int get level; // NUOVI CAMPI PER BACKGROUND & LORE
  @override
  List<String> get startingItems; // L'oggetto scelto dall'inventario
  @override
  Map<String, String> get backgroundAnswers; // Domanda -> Risposta
  @override
  Map<String, String> get connectionAnswers;

  /// Create a copy of CharacterDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterDraftImplCopyWith<_$CharacterDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
