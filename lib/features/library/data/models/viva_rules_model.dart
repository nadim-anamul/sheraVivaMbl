import 'package:equatable/equatable.dart';

class VivaRuleBlockModel extends Equatable {
  final String title;
  final String icon;
  final String color;
  final String bgColor;
  final List<String> rules;

  const VivaRuleBlockModel({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.rules,
  });

  factory VivaRuleBlockModel.fromJson(Map<String, dynamic> json) {
    return VivaRuleBlockModel(
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      bgColor: json['bgColor'] as String? ?? '',
      rules: (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'color': color,
      'bgColor': bgColor,
      'rules': rules,
    };
  }

  @override
  List<Object?> get props => [title, icon, color, bgColor, rules];
}

class VivaGeneralTipModel extends Equatable {
  final String title;
  final String icon;
  final String content;

  const VivaGeneralTipModel({
    required this.title,
    required this.icon,
    required this.content,
  });

  factory VivaGeneralTipModel.fromJson(Map<String, dynamic> json) {
    return VivaGeneralTipModel(
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'content': content,
    };
  }

  @override
  List<Object?> get props => [title, icon, content];
}

class VivaRulesConfigModel extends Equatable {
  final VivaRuleBlockModel dos;
  final VivaRuleBlockModel donts;
  final VivaGeneralTipModel generalTip;

  const VivaRulesConfigModel({
    required this.dos,
    required this.donts,
    required this.generalTip,
  });

  factory VivaRulesConfigModel.fromJson(Map<String, dynamic> json) {
    return VivaRulesConfigModel(
      dos: VivaRuleBlockModel.fromJson(json['dos'] as Map<String, dynamic>? ?? {}),
      donts: VivaRuleBlockModel.fromJson(json['donts'] as Map<String, dynamic>? ?? {}),
      generalTip: VivaGeneralTipModel.fromJson(json['generalTip'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dos': dos.toJson(),
      'donts': donts.toJson(),
      'generalTip': generalTip.toJson(),
    };
  }

  @override
  List<Object?> get props => [dos, donts, generalTip];
}
