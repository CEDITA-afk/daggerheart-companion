// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weapon _$WeaponFromJson(Map<String, dynamic> json) => Weapon(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      trait: json['trait'] as String? ?? '',
      range: json['range'] as String? ?? '',
      damage: json['damage'] as String? ?? '',
      hands: json['hands'] as String? ?? 'One-Handed',
    );

Map<String, dynamic> _$WeaponToJson(Weapon instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'trait': instance.trait,
      'range': instance.range,
      'damage': instance.damage,
      'hands': instance.hands,
    };

Armor _$ArmorFromJson(Map<String, dynamic> json) => Armor(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      armorScore: (json['armorScore'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ArmorToJson(Armor instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'armorScore': instance.armorScore,
    };
