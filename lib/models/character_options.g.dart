// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DaggerheartClass _$DaggerheartClassFromJson(Map<String, dynamic> json) =>
    DaggerheartClass(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startingHitPoints: (json['startingHitPoints'] as num?)?.toInt() ?? 6,
      startingEvasion: (json['startingEvasion'] as num?)?.toInt() ?? 10,
      domains: (json['domains'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$DaggerheartClassToJson(DaggerheartClass instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'startingHitPoints': instance.startingHitPoints,
      'startingEvasion': instance.startingEvasion,
      'domains': instance.domains,
      'features': instance.features,
    };

Ancestry _$AncestryFromJson(Map<String, dynamic> json) => Ancestry(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$AncestryToJson(Ancestry instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'features': instance.features,
    };

Community _$CommunityFromJson(Map<String, dynamic> json) => Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CommunityToJson(Community instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'features': instance.features,
    };

Subclass _$SubclassFromJson(Map<String, dynamic> json) => Subclass(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      relatedClass: json['class'] as String,
      foundationFeatures: (json['foundationFeatures'] as List<dynamic>)
          .map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList(),
      specializationFeatures: (json['specializationFeatures'] as List<dynamic>)
          .map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList(),
      masteryFeatures: (json['masteryFeatures'] as List<dynamic>)
          .map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubclassToJson(Subclass instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'class': instance.relatedClass,
      'foundationFeatures': instance.foundationFeatures,
      'specializationFeatures': instance.specializationFeatures,
      'masteryFeatures': instance.masteryFeatures,
    };

Feature _$FeatureFromJson(Map<String, dynamic> json) => Feature(
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };
