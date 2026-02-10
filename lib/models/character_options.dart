import 'package:json_annotation/json_annotation.dart';
import 'common.dart';

part 'character_options.g.dart';

/// MODELLO PER LE CLASSI
@JsonSerializable()
class DaggerheartClass extends GameEntity {
  @JsonKey(defaultValue: 6)
  final int startingHitPoints;
  
  @JsonKey(defaultValue: 10)
  final int startingEvasion;

  @JsonKey(defaultValue: [])
  final List<String> domains;

  @JsonKey(defaultValue: [])
  final List<Feature> features;

  DaggerheartClass({
    required super.id,
    required super.name,
    required super.description,
    required this.startingHitPoints,
    required this.startingEvasion,
    required this.domains,
    required this.features,
  });

  factory DaggerheartClass.fromJson(Map<String, dynamic> json) {
    // GESTIONE NOME
    String name;
    if (json['name'] is String) {
      name = json['name'] as String;
    } else {
      name = LocalizedString.fromJson(json['name'] ?? {}).text;
    }

    // GESTIONE DESCRIZIONE
    String desc;
    if (json['description'] is String) {
      desc = json['description'];
    } else {
      desc = DescriptionParser.parse(json['description'] as List?);
    }
    
    return DaggerheartClass(
      id: json['id'] as String,
      name: name,
      description: desc,
      startingHitPoints: json['startingHitPoints'] as int? ?? 6,
      startingEvasion: json['startingEvasion'] as int? ?? 10,
      domains: (json['domains'] as List?)?.map((e) => e.toString()).toList() ?? [],
      features: _parseClassFeatures(json),
    );
  }

  Map<String, dynamic> toJson() => _$DaggerheartClassToJson(this);

  static List<Feature> _parseClassFeatures(Map<String, dynamic> json) {
    List<Feature> list = [];
    if (json['hopeFeature'] != null) {
      list.add(Feature.fromJson(json['hopeFeature']));
    }
    if (json['classFeatures'] is List) {
      list.addAll((json['classFeatures'] as List)
          .map((e) => Feature.fromJson(e as Map<String, dynamic>)));
    } else if (json['features'] is List) {
      list.addAll((json['features'] as List)
          .map((e) => Feature.fromJson(e as Map<String, dynamic>)));
    }
    return list;
  }
}

/// MODELLO PER ANCESTRY
@JsonSerializable()
class Ancestry extends GameEntity {
  @JsonKey(defaultValue: [])
  final List<Feature> features;

  Ancestry({
    required super.id,
    required super.name,
    required super.description,
    required this.features,
  });

  factory Ancestry.fromJson(Map<String, dynamic> json) {
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

    return Ancestry(
      id: json['id'] as String,
      name: name,
      description: desc,
      features: (json['features'] as List?)
          ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => _$AncestryToJson(this);
}

/// MODELLO PER COMMUNITY
@JsonSerializable()
class Community extends GameEntity {
  @JsonKey(defaultValue: [])
  final List<Feature> features;

  Community({
    required super.id,
    required super.name,
    required super.description,
    required this.features,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
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

    return Community(
      id: json['id'] as String,
      name: name,
      description: desc,
      features: (json['features'] as List?)
          ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => _$CommunityToJson(this);
}

/// MODELLO PER SUBCLASS
@JsonSerializable()
class Subclass extends GameEntity {
  @JsonKey(name: 'class') 
  final String relatedClass;

  final List<Feature> foundationFeatures;
  final List<Feature> specializationFeatures;
  final List<Feature> masteryFeatures;

  Subclass({
    required super.id,
    required super.name,
    required super.description,
    required this.relatedClass,
    required this.foundationFeatures,
    required this.specializationFeatures,
    required this.masteryFeatures,
  });

  List<Feature> get features => foundationFeatures;

  factory Subclass.fromJson(Map<String, dynamic> json) {
    List<Feature> extract(String key) {
      if (json[key] != null && json[key]['features'] is List) {
        return (json[key]['features'] as List)
            .map((e) => Feature.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

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

    return Subclass(
      id: json['id'] as String,
      name: name,
      description: desc,
      relatedClass: json['class'] as String? ?? "Unknown",
      foundationFeatures: extract('foundation'),
      specializationFeatures: extract('specialization'),
      masteryFeatures: extract('mastery'),
    );
  }

  Map<String, dynamic> toJson() => _$SubclassToJson(this);
}

/// Helper per le Feature
@JsonSerializable()
class Feature {
  final String name;
  final String description;

  Feature({required this.name, required this.description});

  factory Feature.fromJson(Map<String, dynamic> json) {
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

    return Feature(
      name: name,
      description: desc,
    );
  }

  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}