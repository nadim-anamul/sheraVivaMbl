import 'package:flutter/material.dart';

class VivaExamConfigModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String stats;
  final String iconName;
  final String gradientStart;
  final String gradientEnd;
  final String dataUrl;
  final bool isActive;
  final String? yearFilterLabel;
  final String? choicesFilterLabel;
  final String? districtFilterLabel;

  VivaExamConfigModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.stats,
    required this.iconName,
    required this.gradientStart,
    required this.gradientEnd,
    required this.dataUrl,
    required this.isActive,
    this.yearFilterLabel,
    this.choicesFilterLabel,
    this.districtFilterLabel,
  });

  factory VivaExamConfigModel.fromJson(Map<String, dynamic> json) {
    return VivaExamConfigModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      stats: json['stats'] as String? ?? '',
      iconName: json['icon'] as String? ?? 'school_rounded',
      gradientStart: json['gradientStart'] as String? ?? '0xFF0F766E',
      gradientEnd: json['gradientEnd'] as String? ?? '0xFF134E4A',
      dataUrl: json['dataUrl'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      yearFilterLabel: json['yearFilterLabel'] as String?,
      choicesFilterLabel: json['choicesFilterLabel'] as String?,
      districtFilterLabel: json['districtFilterLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'stats': stats,
      'icon': iconName,
      'gradientStart': gradientStart,
      'gradientEnd': gradientEnd,
      'dataUrl': dataUrl,
      'isActive': isActive,
      'yearFilterLabel': yearFilterLabel,
      'choicesFilterLabel': choicesFilterLabel,
      'districtFilterLabel': districtFilterLabel,
    };
  }

  // Convert hexadecimal color string to Flutter Color object
  Color get startColor {
    return _parseColor(gradientStart, const Color(0xFF0F766E));
  }

  Color get endColor {
    return _parseColor(gradientEnd, const Color(0xFF134E4A));
  }

  static Color _parseColor(String colorStr, Color defaultColor) {
    try {
      String cleanStr = colorStr.trim();
      if (cleanStr.startsWith('0xFF') || cleanStr.startsWith('0xff')) {
        return Color(int.parse(cleanStr));
      } else if (cleanStr.startsWith('#')) {
        cleanStr = cleanStr.replaceFirst('#', '');
        if (cleanStr.length == 6) {
          cleanStr = 'FF$cleanStr';
        }
        return Color(int.parse('0x$cleanStr'));
      }
      return Color(int.parse(cleanStr));
    } catch (_) {
      return defaultColor;
    }
  }

  // Convert icon name into material IconData
  IconData get iconData {
    switch (iconName) {
      case 'school_rounded':
      case 'school':
        return Icons.school_rounded;
      case 'menu_book_rounded':
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'account_balance_rounded':
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'work_rounded':
      case 'work':
        return Icons.work_rounded;
      case 'business_center_rounded':
      case 'business_center':
        return Icons.business_center_rounded;
      case 'import_contacts_rounded':
      case 'import_contacts':
        return Icons.import_contacts_rounded;
      case 'gavel_rounded':
      case 'gavel':
        return Icons.gavel_rounded;
      case 'security_rounded':
      case 'security':
        return Icons.security_rounded;
      case 'local_hospital_rounded':
      case 'local_hospital':
        return Icons.local_hospital_rounded;
      case 'language_rounded':
      case 'language':
        return Icons.language_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}
