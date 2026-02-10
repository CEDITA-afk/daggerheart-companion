import 'package:json_annotation/json_annotation.dart';
import 'common.dart';

part 'domain_card.g.dart';

@JsonSerializable()
class DomainCard extends GameEntity {
  final String domain;
  final int level;
  
  @JsonKey(defaultValue: "Ability")
  final String type;
  
  @JsonKey(defaultValue: 0)
  final int recallCost; 

  DomainCard({
    required super.id,
    required super.name,
    required super.description,
    required this.domain,
    required this.level,
    required this.type,
    required this.recallCost,
  });

  factory DomainCard.fromJson(Map<String, dynamic> json) {
    // --- FIX CRASH ---
    // Se è già una stringa, usala direttamente (è un dato salvato)
    if (json['description'] is String) {
      return DomainCard(
        id: json['id'] as String,
        name: json['name'] is String ? json['name'] : LocalizedString.fromJson(json['name'] ?? {}).text,
        description: json['description'],
        domain: json['domain'] as String? ?? "Unknown",
        level: json['level'] as int? ?? 1,
        type: (json['cardType'] ?? json['type']) as String? ?? "Ability",
        recallCost: json['recallCost'] as int? ?? 0,
      );
    }

    // Altrimenti costruiscila (è un dato originale)
    StringBuffer descBuffer = StringBuffer();
    if (json['description'] != null) {
      descBuffer.writeln(DescriptionParser.parse(json['description'] as List?));
    }
    if (json['features'] is List) {
      for (var f in json['features']) {
        if (f['name'] != null) {
          String fName = LocalizedString.fromJson(f['name']).text;
          descBuffer.writeln("\n**$fName**");
        }
        if (f['description'] != null) {
          descBuffer.writeln(DescriptionParser.parse(f['description'] as List?));
        }
      }
    }

    return DomainCard(
      id: json['id'] as String,
      name: LocalizedString.fromJson(json['name'] ?? {}).text,
      description: descBuffer.toString().trim(),
      domain: json['domain'] as String? ?? "Unknown",
      level: json['level'] as int? ?? 1,
      type: (json['cardType'] ?? json['type']) as String? ?? "Ability",
      recallCost: json['recallCost'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$DomainCardToJson(this);
  
  String get costString => recallCost > 0 ? "$recallCost Recall" : "";
}