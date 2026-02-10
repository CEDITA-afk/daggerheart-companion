// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DomainCard _$DomainCardFromJson(Map<String, dynamic> json) => DomainCard(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      domain: json['domain'] as String,
      level: (json['level'] as num).toInt(),
      type: json['type'] as String? ?? 'Ability',
      recallCost: (json['recallCost'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DomainCardToJson(DomainCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'domain': instance.domain,
      'level': instance.level,
      'type': instance.type,
      'recallCost': instance.recallCost,
    };
