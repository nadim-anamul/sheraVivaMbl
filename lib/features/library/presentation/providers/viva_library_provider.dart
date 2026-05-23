import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/job_circular_model.dart';
import '../../data/models/job_result_model.dart';
import '../../data/models/viva_advice_model.dart';
import '../../data/models/viva_exam_config_model.dart';
import '../../data/models/viva_experience_model.dart';
import '../../data/models/viva_rules_model.dart';
import '../../data/services/viva_library_service.dart';

// Tab selection: 0 = ভাইভা লাইব্রেরি, 1 = নতুন সার্কুলার, 2 = পরীক্ষার ফলাফল
final libraryActiveTabProvider = StateProvider<int>((ref) => 0);

// Job circulars search query
final circularsSearchQueryProvider = StateProvider<String>((ref) => '');

// Job results search query
final resultsSearchQueryProvider = StateProvider<String>((ref) => '');

// Job circulars fetch provider
final jobCircularsProvider = FutureProvider<List<JobCircularModel>>((ref) async {
  final service = ref.watch(vivaLibraryServiceProvider);
  return service.loadCirculars();
});

// Job results fetch provider
final jobResultsProvider = FutureProvider<List<JobResultModel>>((ref) async {
  final service = ref.watch(vivaLibraryServiceProvider);
  return service.loadResults();
});

// Filtered job circulars provider
final filteredJobCircularsProvider = Provider<AsyncValue<List<JobCircularModel>>>((ref) {
  final rawAsync = ref.watch(jobCircularsProvider);
  final searchQuery = ref.watch(circularsSearchQueryProvider).trim().toLowerCase();

  return rawAsync.when(
    data: (list) {
      if (searchQuery.isEmpty) return AsyncValue.data(list);
      
      final filtered = list.where((item) {
        final titleMatch = item.title.toLowerCase().contains(searchQuery);
        final orgMatch = item.organization.toLowerCase().contains(searchQuery);
        final descMatch = item.description.toLowerCase().contains(searchQuery);
        return titleMatch || orgMatch || descMatch;
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Filtered job results provider
final filteredJobResultsProvider = Provider<AsyncValue<List<JobResultModel>>>((ref) {
  final rawAsync = ref.watch(jobResultsProvider);
  final searchQuery = ref.watch(resultsSearchQueryProvider).trim().toLowerCase();

  return rawAsync.when(
    data: (list) {
      if (searchQuery.isEmpty) return AsyncValue.data(list);
      
      final filtered = list.where((item) {
        final titleMatch = item.title.toLowerCase().contains(searchQuery);
        final orgMatch = item.organization.toLowerCase().contains(searchQuery);
        final descMatch = item.description.toLowerCase().contains(searchQuery);
        return titleMatch || orgMatch || descMatch;
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Service provider
final vivaLibraryServiceProvider = Provider<VivaLibraryService>((ref) {
  return VivaLibraryService();
});

// Dynamic viva advice provider
final vivaAdviceProvider = FutureProvider<List<VivaAdviceCategoryModel>>((ref) async {
  final service = ref.watch(vivaLibraryServiceProvider);
  return service.loadAdvice();
});

// Dynamic viva board rules provider
final vivaRulesProvider = FutureProvider<VivaRulesConfigModel>((ref) async {
  final service = ref.watch(vivaLibraryServiceProvider);
  return service.loadRules();
});

// Central configuration provider
final vivaExamsConfigProvider = FutureProvider<List<VivaExamConfigModel>>((ref) async {
  final service = ref.watch(vivaLibraryServiceProvider);
  return service.loadExamsConfig();
});

// Current selected exam type state (e.g. 'BCS' or 'Primary' or null initially for selection dashboard)
final selectedExamTypeProvider = StateProvider<String?>((ref) => null);

// Full list of loaded experiences for the selected exam
final rawExperiencesProvider = FutureProvider.family<List<VivaExperienceModel>, String>((ref, examType) async {
  final service = ref.watch(vivaLibraryServiceProvider);
  
  // Await the dynamic exam config list to locate the correct target URL
  final configs = await ref.watch(vivaExamsConfigProvider.future);
  final config = configs.firstWhere(
    (c) => c.id.toUpperCase() == examType.toUpperCase(),
    orElse: () => throw Exception('Exam configuration for $examType not found'),
  );
  
  return service.loadExperiences(config.id, config.dataUrl);
});

// Search query filter state
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

// Filter states
final selectedSubjectFilterProvider = StateProvider<String?>((ref) => null);
final selectedYearFilterProvider = StateProvider<String?>((ref) => null);
final selectedCadreFilterProvider = StateProvider<String?>((ref) => null);
final selectedDistrictFilterProvider = StateProvider<String?>((ref) => null);

// Reset all filters
void resetLibraryFilters(WidgetRef ref) {
  ref.read(librarySearchQueryProvider.notifier).state = '';
  ref.read(selectedSubjectFilterProvider.notifier).state = null;
  ref.read(selectedYearFilterProvider.notifier).state = null;
  ref.read(selectedCadreFilterProvider.notifier).state = null;
  ref.read(selectedDistrictFilterProvider.notifier).state = null;
}

// Master filtered experiences provider
final filteredExperiencesProvider = Provider<AsyncValue<List<VivaExperienceModel>>>((ref) {
  final examType = ref.watch(selectedExamTypeProvider);
  if (examType == null) return const AsyncValue.data([]);

  final rawAsync = ref.watch(rawExperiencesProvider(examType));
  
  return rawAsync.when(
    data: (list) {
      final search = ref.watch(librarySearchQueryProvider).trim().toLowerCase();
      final subject = ref.watch(selectedSubjectFilterProvider);
      final year = ref.watch(selectedYearFilterProvider);
      final cadre = ref.watch(selectedCadreFilterProvider);
      final district = ref.watch(selectedDistrictFilterProvider);

      final List<VivaExperienceModel> filtered = list.where((item) {
        // Search filter
        if (search.isNotEmpty) {
          final titleMatch = item.title.toLowerCase().contains(search);
          final subjectMatch = item.subject.toLowerCase().contains(search);
          final boardMatch = item.board.toLowerCase().contains(search);
          final districtMatch = item.district.toLowerCase().contains(search);
          final candidateMatch = item.candidateName.toLowerCase().contains(search);
          
          // Check transcript dialogues
          final transcriptMatch = item.transcript.any((turn) =>
              turn.text.toLowerCase().contains(search));

          if (!titleMatch && !subjectMatch && !boardMatch && !districtMatch && !candidateMatch && !transcriptMatch) {
            return false;
          }
        }

        // Subject filter
        if (subject != null && item.subject != subject) {
          return false;
        }

        // Year/Edition filter
        if (year != null) {
          final matchesEdition = item.edition == year;
          final matchesYear = item.year == year;
          if (!matchesEdition && !matchesYear) {
            return false;
          }
        }

        // Cadre filter
        if (cadre != null && !item.choices.contains(cadre)) {
          return false;
        }

        // District filter
        if (district != null && item.district != district) {
          return false;
        }

        return true;
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Helper provider to extract all unique Subjects available in current raw list
final availableSubjectsProvider = Provider<List<String>>((ref) {
  final examType = ref.watch(selectedExamTypeProvider);
  if (examType == null) return [];
  
  final rawAsync = ref.watch(rawExperiencesProvider(examType));
  return rawAsync.maybeWhen(
    data: (list) {
      final subs = list.map((e) => e.subject).where((e) => e.isNotEmpty).toSet().toList();
      subs.sort();
      return subs;
    },
    orElse: () => [],
  );
});

// Helper provider to extract all unique Editions/Years available in current raw list
final availableYearsProvider = Provider<List<String>>((ref) {
  final examType = ref.watch(selectedExamTypeProvider);
  if (examType == null) return [];
  
  final rawAsync = ref.watch(rawExperiencesProvider(examType));
  return rawAsync.maybeWhen(
    data: (list) {
      final hasEditions = list.any((e) => e.edition.isNotEmpty);
      if (hasEditions) {
        final edns = list.map((e) => e.edition).where((e) => e.isNotEmpty).toSet().toList();
        edns.sort();
        return edns;
      } else {
        final yrs = list.map((e) => e.year).where((e) => e.isNotEmpty).toSet().toList();
        yrs.sort();
        return yrs;
      }
    },
    orElse: () => [],
  );
});

// Helper provider to extract all unique Cadres available in current raw list
final availableCadresProvider = Provider<List<String>>((ref) {
  final examType = ref.watch(selectedExamTypeProvider);
  if (examType == null) return [];
  
  final rawAsync = ref.watch(rawExperiencesProvider(examType));
  return rawAsync.maybeWhen(
    data: (list) {
      final cadres = list.expand((e) => e.choices).where((e) => e.isNotEmpty).toSet().toList();
      cadres.sort();
      return cadres;
    },
    orElse: () => [],
  );
});

// Helper provider to extract all unique Districts available in current raw list
final availableDistrictsProvider = Provider<List<String>>((ref) {
  final examType = ref.watch(selectedExamTypeProvider);
  if (examType == null) return [];
  
  final rawAsync = ref.watch(rawExperiencesProvider(examType));
  return rawAsync.maybeWhen(
    data: (list) {
      final dsts = list.map((e) => e.district).where((e) => e.isNotEmpty).toSet().toList();
      dsts.sort();
      return dsts;
    },
    orElse: () => [],
  );
});
