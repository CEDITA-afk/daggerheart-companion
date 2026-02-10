import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

@JsonSerializable()
class LocalizedString {
  @JsonKey(name: 'en-US')
  final String? en;

  LocalizedString({this.en});

  String get text => en ?? "Unknown";

  factory LocalizedString.fromJson(Map<String, dynamic> json) => _$LocalizedStringFromJson(json);
  Map<String, dynamic> toJson() => _$LocalizedStringToJson(this);
}

@JsonSerializable()
class DescriptionParser {
  static String parse(List<dynamic>? jsonList) {
    if (jsonList == null) return "";
    
    StringBuffer buffer = StringBuffer();

    for (var item in jsonList) {
      if (item is Map) {
        if (item.containsKey('paragraph')) {
          buffer.writeln(LocalizedString.fromJson(item['paragraph']).text);
          buffer.writeln(); 
        } 
        else if (item.containsKey('bullet')) {
          buffer.writeln("• ${LocalizedString.fromJson(item['bullet']).text}");
        }
        else if (item.containsKey('label')) {
           buffer.writeln("\n**${LocalizedString.fromJson(item['label']).text}**");
        }
        // --- AGGIUNTA GESTIONE LISTE ---
        else if (item.containsKey('list')) {
          final listItems = item['list'] as List;
          for (var li in listItems) {
             buffer.writeln("• ${LocalizedString.fromJson(li).text}");
          }
          buffer.writeln();
        }
      }
    }
    return buffer.toString().trim();
  }
}

class GameEntity {
  final String id;
  final String name;
  final String description;

  GameEntity({
    required this.id,
    required this.name,
    required this.description,
  });
}