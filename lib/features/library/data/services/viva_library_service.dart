import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/job_circular_model.dart';
import '../models/job_result_model.dart';
import '../models/viva_advice_model.dart';
import '../models/viva_exam_config_model.dart';
import '../models/viva_experience_model.dart';
import '../models/viva_rules_model.dart';

class VivaLibraryService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  
  // Central dynamic configuration hosted on GitHub raw CDN
  static const String centralConfigUrl = 'https://raw.githubusercontent.com/nadim-anamul/shera-viva-json/master/viva_exams_config.json';
  static const String circularsConfigUrl = 'https://raw.githubusercontent.com/nadim-anamul/shera-viva-json/master/job_circulars.json';
  static const String resultsConfigUrl = 'https://raw.githubusercontent.com/nadim-anamul/shera-viva-json/master/job_results.json';
  static const String adviceConfigUrl = 'https://raw.githubusercontent.com/nadim-anamul/shera-viva-json/master/viva_advice.json';
  static const String rulesConfigUrl = 'https://raw.githubusercontent.com/nadim-anamul/shera-viva-json/master/viva_rules.json';

  // Loads dynamic list of job circulars with remote caching & local fallback
  Future<List<JobCircularModel>> loadCirculars() async {
    const String cacheKey = 'cached_job_circulars';
    const String localAssetPath = 'assets/data/job_circulars.json';

    // 1. Try to fetch from remote GitHub raw CDN
    try {
      final response = await _dio.get<dynamic>(circularsConfigUrl);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is String) {
          list = jsonDecode(data) as List;
        } else if (data is List) {
          list = data;
        }

        // Cache the successful remote result locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(list));

        return list
            .map((e) => JobCircularModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching remote circulars ($circularsConfigUrl): $e. Falling back to cache/assets.');
    }

    // 2. Try to fetch from SharedPreferences offline cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> list = jsonDecode(cachedData) as List;
        return list
            .map((e) => JobCircularModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading circulars from offline cache: $e');
    }

    // 3. Absolute offline fallback: Load from local Flutter assets
    try {
      final String assetData = await rootBundle.loadString(localAssetPath);
      final List<dynamic> list = jsonDecode(assetData) as List;
      return list
          .map((e) => JobCircularModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Critical error loading local circulars asset: $e');
      return [];
    }
  }

  // Loads dynamic list of job results with remote caching & local fallback
  Future<List<JobResultModel>> loadResults() async {
    const String cacheKey = 'cached_job_results';
    const String localAssetPath = 'assets/data/job_results.json';

    // 1. Try to fetch from remote GitHub raw CDN
    try {
      final response = await _dio.get<dynamic>(resultsConfigUrl);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is String) {
          list = jsonDecode(data) as List;
        } else if (data is List) {
          list = data;
        }

        // Cache the successful remote result locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(list));

        return list
            .map((e) => JobResultModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching remote results ($resultsConfigUrl): $e. Falling back to cache/assets.');
    }

    // 2. Try to fetch from SharedPreferences offline cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> list = jsonDecode(cachedData) as List;
        return list
            .map((e) => JobResultModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading results from offline cache: $e');
    }

    // 3. Absolute offline fallback: Load from local Flutter assets
    try {
      final String assetData = await rootBundle.loadString(localAssetPath);
      final List<dynamic> list = jsonDecode(assetData) as List;
      return list
          .map((e) => JobResultModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Critical error loading local results asset: $e');
      return [];
    }
  }

  // Loads the dynamic config list of active viva exams with remote caching & local fallback
  Future<List<VivaExamConfigModel>> loadExamsConfig() async {
    const String cacheKey = 'cached_viva_exams_config';
    const String localAssetPath = 'assets/data/viva_exams_config.json';

    // 1. Try to fetch from remote GitHub raw CDN
    try {
      final response = await _dio.get<dynamic>(centralConfigUrl);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is String) {
          list = jsonDecode(data) as List;
        } else if (data is List) {
          list = data;
        }

        // Cache the successful remote result locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(list));

        return list
            .map((e) => VivaExamConfigModel.fromJson(e as Map<String, dynamic>))
            .where((element) => element.isActive)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching remote config ($centralConfigUrl): $e. Falling back to cache/assets.');
    }

    // 2. Try to fetch from SharedPreferences offline cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> list = jsonDecode(cachedData) as List;
        return list
            .map((e) => VivaExamConfigModel.fromJson(e as Map<String, dynamic>))
            .where((element) => element.isActive)
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading config from offline cache: $e');
    }

    // 3. Absolute offline fallback: Load from local Flutter assets
    try {
      final String assetData = await rootBundle.loadString(localAssetPath);
      final List<dynamic> list = jsonDecode(assetData) as List;
      return list
          .map((e) => VivaExamConfigModel.fromJson(e as Map<String, dynamic>))
          .where((element) => element.isActive)
          .toList();
    } catch (e) {
      debugPrint('Critical error loading local config asset: $e');
      return [];
    }
  }

  // Loads candidate experiences from a specific dynamic raw URL
  Future<List<VivaExperienceModel>> loadExperiences(String examType, String dataUrl) async {
    final String cacheKey = 'cached_viva_library_${examType.toLowerCase()}';
    final String localAssetPath = 'assets/data/${examType.toLowerCase()}_viva_library.json';

    // 1. Try to fetch from dynamic remote URL
    if (dataUrl.isNotEmpty) {
      try {
        final response = await _dio.get<dynamic>(dataUrl);
        if (response.statusCode == 200) {
          final dynamic data = response.data;
          List<dynamic> list = [];
          if (data is String) {
            list = jsonDecode(data) as List;
          } else if (data is List) {
            list = data;
          }
          
          // Cache the successful remote result locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, jsonEncode(list));
          
          return list.map((e) => VivaExperienceModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Error fetching from remote URL ($dataUrl): $e. Falling back to cache/assets.');
      }
    }

    // 2. Try to fetch from SharedPreferences offline cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> list = jsonDecode(cachedData) as List;
        return list.map((e) => VivaExperienceModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error reading experiences from offline cache: $e');
    }

    // 3. Absolute offline fallback: Load from local Flutter assets
    try {
      final String assetData = await rootBundle.loadString(localAssetPath);
      final List<dynamic> list = jsonDecode(assetData) as List;
      return list.map((e) => VivaExperienceModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Critical error loading local experiences assets for $examType: $e');
      return [];
    }
  }

  // Loads dynamic list of advice categories with remote caching & local fallback
  Future<List<VivaAdviceCategoryModel>> loadAdvice() async {
    const String cacheKey = 'cached_viva_advice';
    const String localAssetPath = 'assets/data/viva_advice.json';

    // 1. Try to fetch from remote GitHub raw CDN
    try {
      final response = await _dio.get<dynamic>(adviceConfigUrl);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is String) {
          list = jsonDecode(data) as List;
        } else if (data is List) {
          list = data;
        }

        // Cache the successful remote result locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(list));

        return list
            .map((e) => VivaAdviceCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching remote advice ($adviceConfigUrl): $e. Falling back to cache/assets.');
    }

    // 2. Try to fetch from SharedPreferences offline cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> list = jsonDecode(cachedData) as List;
        return list
            .map((e) => VivaAdviceCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading advice from offline cache: $e');
    }

    // 3. Absolute offline fallback: Load from local Flutter assets
    try {
      final String assetData = await rootBundle.loadString(localAssetPath);
      final List<dynamic> list = jsonDecode(assetData) as List;
      return list
          .map((e) => VivaAdviceCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Critical error loading local advice asset: $e');
      return [];
    }
  }

  // Loads dynamic list of rules and etiquette with remote caching & local fallback
  Future<VivaRulesConfigModel> loadRules() async {
    const String cacheKey = 'cached_viva_rules';
    const String localAssetPath = 'assets/data/viva_rules.json';

    // 1. Try to fetch from remote GitHub raw CDN
    try {
      final response = await _dio.get<dynamic>(rulesConfigUrl);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        Map<String, dynamic> map = {};
        if (data is String) {
          map = jsonDecode(data) as Map<String, dynamic>;
        } else if (data is Map) {
          map = data as Map<String, dynamic>;
        }

        // Cache the successful remote result locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(map));

        return VivaRulesConfigModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('Error fetching remote rules ($rulesConfigUrl): $e. Falling back to cache/assets.');
    }

    // 2. Try to fetch from SharedPreferences offline cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(cachedData) as Map<String, dynamic>;
        return VivaRulesConfigModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('Error reading rules from offline cache: $e');
    }

    // 3. Absolute offline fallback: Load from local Flutter assets
    try {
      final String assetData = await rootBundle.loadString(localAssetPath);
      final Map<String, dynamic> map = jsonDecode(assetData) as Map<String, dynamic>;
      return VivaRulesConfigModel.fromJson(map);
    } catch (e) {
      debugPrint('Critical error loading local rules asset: $e');
      // Return empty fallback model
      return const VivaRulesConfigModel(
        dos: VivaRuleBlockModel(title: 'যা করবেন (Do)', icon: 'check_circle_rounded', color: '#057857', bgColor: '#ECFDF5', rules: []),
        donts: VivaRuleBlockModel(title: 'যা বর্জন করবেন (Don\'t)', icon: 'cancel_rounded', color: '#DC2626', bgColor: '#FEF2F2', rules: []),
        generalTip: VivaGeneralTipModel(title: 'বিশেষ পরামর্শ', icon: 'tips_and_updates_outlined', content: ''),
      );
    }
  }
}
