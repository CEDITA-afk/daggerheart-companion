// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CharacterDraftImpl _$$CharacterDraftImplFromJson(Map<String, dynamic> json) =>
    _$CharacterDraftImpl(
      name: json['name'] as String? ?? "New Character",
      selectedClass: json['selectedClass'] == null
          ? null
          : DaggerheartClass.fromJson(
              json['selectedClass'] as Map<String, dynamic>),
      subclass: json['subclass'] == null
          ? null
          : Subclass.fromJson(json['subclass'] as Map<String, dynamic>),
      ancestry: json['ancestry'] == null
          ? null
          : Ancestry.fromJson(json['ancestry'] as Map<String, dynamic>),
      community: json['community'] == null
          ? null
          : Community.fromJson(json['community'] as Map<String, dynamic>),
      primaryWeapon: json['primaryWeapon'] == null
          ? null
          : Weapon.fromJson(json['primaryWeapon'] as Map<String, dynamic>),
      secondaryWeapon: json['secondaryWeapon'] == null
          ? null
          : Weapon.fromJson(json['secondaryWeapon'] as Map<String, dynamic>),
      selectedArmor: json['selectedArmor'] == null
          ? null
          : Armor.fromJson(json['selectedArmor'] as Map<String, dynamic>),
      selectedDomainCards: (json['selectedDomainCards'] as List<dynamic>?)
              ?.map((e) => DomainCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      agility: (json['agility'] as num?)?.toInt() ?? 0,
      strength: (json['strength'] as num?)?.toInt() ?? 0,
      finesse: (json['finesse'] as num?)?.toInt() ?? 0,
      instinct: (json['instinct'] as num?)?.toInt() ?? 0,
      presence: (json['presence'] as num?)?.toInt() ?? 0,
      knowledge: (json['knowledge'] as num?)?.toInt() ?? 0,
      maxHp: (json['maxHp'] as num?)?.toInt() ?? 6,
      currentHp: (json['currentHp'] as num?)?.toInt() ?? 6,
      stress: (json['stress'] as num?)?.toInt() ?? 0,
      hope: (json['hope'] as num?)?.toInt() ?? 2,
      evasion: (json['evasion'] as num?)?.toInt() ?? 10,
      level: (json['level'] as num?)?.toInt() ?? 1,
      startingItems: (json['startingItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      backgroundAnswers:
          (json['backgroundAnswers'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {},
      connectionAnswers:
          (json['connectionAnswers'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {},
    );

Map<String, dynamic> _$$CharacterDraftImplToJson(
        _$CharacterDraftImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'selectedClass': instance.selectedClass,
      'subclass': instance.subclass,
      'ancestry': instance.ancestry,
      'community': instance.community,
      'primaryWeapon': instance.primaryWeapon,
      'secondaryWeapon': instance.secondaryWeapon,
      'selectedArmor': instance.selectedArmor,
      'selectedDomainCards': instance.selectedDomainCards,
      'agility': instance.agility,
      'strength': instance.strength,
      'finesse': instance.finesse,
      'instinct': instance.instinct,
      'presence': instance.presence,
      'knowledge': instance.knowledge,
      'maxHp': instance.maxHp,
      'currentHp': instance.currentHp,
      'stress': instance.stress,
      'hope': instance.hope,
      'evasion': instance.evasion,
      'level': instance.level,
      'startingItems': instance.startingItems,
      'backgroundAnswers': instance.backgroundAnswers,
      'connectionAnswers': instance.connectionAnswers,
    };
