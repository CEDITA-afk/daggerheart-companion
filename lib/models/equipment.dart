import 'package:json_annotation/json_annotation.dart';
import 'common.dart';

part 'equipment.g.dart';

/// MODELLO PER LE ARMI
@JsonSerializable()
class Weapon extends GameEntity {
  @JsonKey(defaultValue: "")
  final String trait; 
  @JsonKey(defaultValue: "")
  final String range; 
  @JsonKey(defaultValue: "")
  final String damage; 
  @JsonKey(defaultValue: "One-Handed")
  final String hands;

  Weapon({
    required super.id,
    required super.name,
    required super.description,
    required this.trait,
    required this.range,
    required this.damage,
    required this.hands,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    // FIX NOME
    String name;
    if (json['name'] is String) {
      name = json['name'];
    } else {
      name = LocalizedString.fromJson(json['name'] ?? {}).text;
    }

    // FIX DESCRIZIONE
    String desc;
    if (json['description'] is String) {
      desc = json['description'];
    } else {
      desc = DescriptionParser.parse(json['description'] as List?);
    }

    return Weapon(
      id: json['id'] as String,
      name: name,
      description: desc,
      trait: json['trait'] as String? ?? "Agility",
      range: json['range'] as String? ?? "Melee",
      damage: _parseDamage(json['damage']),
      hands: json['burden'] as String? ?? "ONE_HANDED",
    );
  }

  Map<String, dynamic> toJson() => _$WeaponToJson(this);

  static String _parseDamage(dynamic damageJson) {
    if (damageJson is Map) {
      String dice = damageJson['dice'] ?? "d6";
      String type = damageJson['type'] ?? "Physical";
      int modifier = damageJson['modifier'] ?? 0;
      String modString = modifier > 0 ? "+$modifier" : "";
      return "$dice$modString $type"; 
    }
    if (damageJson is String) return damageJson;
    return "d6 Physical";
  }
}

/// MODELLO PER LE ARMATURE
@JsonSerializable()
class Armor extends GameEntity {
  @JsonKey(defaultValue: 0)
  final int armorScore;

  Armor({
    required super.id,
    required super.name,
    required super.description,
    required this.armorScore,
  });

  factory Armor.fromJson(Map<String, dynamic> json) {
    // FIX NOME
    String name;
    if (json['name'] is String) {
      name = json['name'];
    } else {
      name = LocalizedString.fromJson(json['name'] ?? {}).text;
    }

    // FIX DESCRIZIONE
    String desc;
    if (json['description'] is String) {
      desc = json['description'];
    } else {
      desc = DescriptionParser.parse(json['description'] as List?);
    }

    return Armor(
      id: json['id'] as String,
      name: name,
      description: desc,
      armorScore: json['baseScore'] as int? ?? json['armorScore'] ?? 0, 
    );
  }

  Map<String, dynamic> toJson() => _$ArmorToJson(this);
}