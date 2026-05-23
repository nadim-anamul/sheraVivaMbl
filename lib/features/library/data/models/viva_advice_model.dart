import 'package:equatable/equatable.dart';

class VivaAdviceCategoryModel extends Equatable {
  final String category;
  final String title;
  final String icon;
  final String color;
  final List<String> tips;

  const VivaAdviceCategoryModel({
    required this.category,
    required this.title,
    required this.icon,
    required this.color,
    required this.tips,
  });

  factory VivaAdviceCategoryModel.fromJson(Map<String, dynamic> json) {
    return VivaAdviceCategoryModel(
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'icon': icon,
      'color': color,
      'tips': tips,
    };
  }

  @override
  List<Object?> get props => [category, title, icon, color, tips];
}
