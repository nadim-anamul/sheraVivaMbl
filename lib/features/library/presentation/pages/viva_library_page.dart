import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/viva_exam_config_model.dart';
import '../../data/models/viva_experience_model.dart';
import '../providers/viva_library_provider.dart';
import 'pdf_viewer_page.dart';
import 'viva_transcript_page.dart';

class VivaLibraryPage extends ConsumerWidget {
  const VivaLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedExam = ref.watch(selectedExamTypeProvider);
    final activeTab = ref.watch(libraryActiveTabProvider);

    String getTitle() {
      if (selectedExam != null) {
        return ref.watch(vivaExamsConfigProvider).maybeWhen(
          data: (List<VivaExamConfigModel> configs) {
            final config = configs.firstWhere(
              (c) => c.id.toUpperCase() == selectedExam.toUpperCase(),
              orElse: () => configs.firstWhere((c) => c.id == selectedExam, orElse: () => configs.first),
            );
            return config.title;
          },
          orElse: () => selectedExam == 'BCS'
              ? 'বিসিএস ভাইভা অভিজ্ঞতা'
              : 'প্রাইমারি ভাইভা অভিজ্ঞতা',
        );
      }
      switch (activeTab) {
        case 1:
          return 'চাকরির সার্কুলার (Circulars)';
        case 2:
          return 'পরীক্ষার ফলাফল (Results)';
        default:
          return 'ভাইভা লাইব্রেরি (Viva Library)';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: selectedExam != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1E293B)),
                onPressed: () {
                  ref.read(selectedExamTypeProvider.notifier).state = null;
                  resetLibraryFilters(ref);
                },
              )
            : null,
        title: Text(
          getTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      body: selectedExam != null
          ? _buildExperiencesFeed(context, ref, selectedExam)
          : Column(
              children: [
                _buildSlidingTabBar(context, ref, activeTab),
                Expanded(
                  child: IndexedStack(
                    index: activeTab,
                    children: [
                      _buildExamSelectionDashboard(context, ref),
                      _buildCircularsTab(context, ref),
                      _buildResultsTab(context, ref),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // --- 1. EXAM SELECTION DASHBOARD ---
  Widget _buildExamSelectionDashboard(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(vivaExamsConfigProvider);

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting & Intro
            const Text(
              'স্বাগতম ভাইভা লাইব্রেরিতে!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F766E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'সফল প্রার্থীদের বাস্তব ভাইভা অভিজ্ঞতা এবং প্রশ্নোত্তর পড়ে নিজেকে প্রস্তুত করুন। পরীক্ষাটি সিলেক্ট করে এগিয়ে যান:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Dynamic Config Exam Cards
            configAsync.when(
              data: (List<VivaExamConfigModel> configs) {
                if (configs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'কোনো সচল পরীক্ষা ভাইভা ক্যাটাগরি খুঁজে পাওয়া যায়নি।',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  );
                }
                return Column(
                  children: configs.map((config) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildSelectionCard(
                        context: context,
                        title: config.title,
                        subtitle: config.subtitle,
                        description: config.description,
                        stats: config.stats,
                        icon: config.iconData,
                        gradientColors: [config.startColor, config.endColor],
                        onTap: () {
                          ref.read(selectedExamTypeProvider.notifier).state = config.id;
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                  ),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'কনফিগারেশন লোড করা সম্ভব হয়নি: $err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom advice card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Color(0xFF15803D),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'একটি প্রিমিয়াম টিপস!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ভাইভা সফল করতে প্রার্থীদের প্রশ্নের ধরন, উত্তর দেওয়ার কৌশল ও মেন্টাল প্রস্তুতি বিশ্লেষণ করুন।',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required String stats,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          canRequestFocus: false,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        stats,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'লাইব্রেরিতে প্রবেশ করুন',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 2. EXPERIENCES FEED WITH SEARCH & FILTERS ---
  Widget _buildExperiencesFeed(BuildContext context, WidgetRef ref, String examType) {
    final filteredAsync = ref.watch(filteredExperiencesProvider);
    final searchController = TextEditingController(text: ref.read(librarySearchQueryProvider));
    
    // Dynamic Filter lists from raw loaded values
    final subjects = ref.watch(availableSubjectsProvider);
    final years = ref.watch(availableYearsProvider);
    final cadres = ref.watch(availableCadresProvider);
    final districts = ref.watch(availableDistrictsProvider);

    // Active selected values
    final activeSubject = ref.watch(selectedSubjectFilterProvider);
    final activeYear = ref.watch(selectedYearFilterProvider);
    final activeCadre = ref.watch(selectedCadreFilterProvider);
    final activeDistrict = ref.watch(selectedDistrictFilterProvider);

    final bool hasActiveFilters = ref.watch(librarySearchQueryProvider).isNotEmpty ||
        activeSubject != null ||
        activeYear != null ||
        activeCadre != null ||
        activeDistrict != null;

    // Get configuration to resolve custom labels dynamically
    final List<VivaExamConfigModel> configs = ref.read(vivaExamsConfigProvider).value ?? [];
    final config = configs.firstWhere(
      (c) => c.id.toUpperCase() == examType.toUpperCase(),
      orElse: () => configs.firstWhere((c) => c.id == examType, orElse: () => configs.first),
    );

    return Column(
      children: [
        // Top Search and Filter Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Search input
              TextField(
                controller: searchController,
                onChanged: (val) {
                  ref.read(librarySearchQueryProvider.notifier).state = val;
                },
                decoration: InputDecoration(
                  hintText: 'বিষয়, বোর্ড, বা প্রশ্ন খুঁজুন...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                          onPressed: () {
                            searchController.clear();
                            ref.read(librarySearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Dropdowns
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // Reset Button
                    if (hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        key: const ValueKey('reset-btn'),
                        child: TextButton.icon(
                          onPressed: () {
                            searchController.clear();
                            resetLibraryFilters(ref);
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFEF4444)),
                          label: const Text(
                            'রিসেট',
                            style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            backgroundColor: const Color(0xFFFEE2E2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                    // Subject Dropdown
                    if (subjects.isNotEmpty) ...[
                      _buildFilterDropdown(
                        label: 'বিষয়',
                        value: activeSubject,
                        items: subjects,
                        onChanged: (val) => ref.read(selectedSubjectFilterProvider.notifier).state = val,
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Year Dropdown
                    if (years.isNotEmpty) ...[
                      _buildFilterDropdown(
                        label: config.yearFilterLabel ?? 'বছর',
                        value: activeYear,
                        items: years,
                        onChanged: (val) => ref.read(selectedYearFilterProvider.notifier).state = val,
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Cadre/Choice Dropdown
                    if (cadres.isNotEmpty) ...[
                      _buildFilterDropdown(
                        label: config.choicesFilterLabel ?? 'পছন্দক্রম',
                        value: activeCadre,
                        items: cadres,
                        onChanged: (val) => ref.read(selectedCadreFilterProvider.notifier).state = val,
                      ),
                      const SizedBox(width: 8),
                    ],

                    // District Dropdown
                    if (districts.isNotEmpty) ...[
                      _buildFilterDropdown(
                        label: config.districtFilterLabel ?? 'জেলা',
                        value: activeDistrict,
                        items: districts,
                        onChanged: (val) => ref.read(selectedDistrictFilterProvider.notifier).state = val,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Experiences list
        Expanded(
          child: filteredAsync.when(
            data: (experiences) {
              if (experiences.isEmpty) {
                return _buildEmptyState(hasActiveFilters, ref, searchController);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: experiences.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final experience = experiences[index];
                  return _buildExperienceCard(context, ref, experience);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
              ),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'উফ! ডাটা লোড করতে সমস্যা হয়েছে।\n$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget for custom Filter Dropdown
  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: value != null ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: value != null ? const Color(0xFF15803D) : const Color(0xFF64748B),
            fontWeight: value != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: value != null ? const Color(0xFF15803D) : const Color(0xFF64748B),
        ),
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('সব $label'),
          ),
          ...items.map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  // Clean empty state layout
  Widget _buildEmptyState(bool hasFilters, WidgetRef ref, TextEditingController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Color(0xFF94A3B8),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'কোনো অভিজ্ঞতা খুঁজে পাওয়া যায়নি!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'অনুগ্রহ করে সার্চ কোয়েরি বা ফিল্টার পরিবর্তন করে পুনরায় চেষ্টা করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  controller.clear();
                  resetLibraryFilters(ref);
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('সকল ফিল্টার রিসেট করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- 3. CANDIDATE EXPERIENCE CARD ---
  Widget _buildExperienceCard(BuildContext context, WidgetRef ref, VivaExperienceModel experience) {
    // Find the configuration to get the dynamic color & labels
    final List<VivaExamConfigModel> configs = ref.read(vivaExamsConfigProvider).value ?? [];
    final config = configs.firstWhere(
      (c) => c.id.toUpperCase() == experience.examType.toUpperCase(),
      orElse: () => configs.firstWhere((c) => c.id == experience.examType, orElse: () => configs.first),
    );
    final themeColor = config.startColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header strip of Card
            Container(
              color: themeColor.withOpacity(0.04),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: themeColor.withOpacity(0.1),
                    child: Icon(
                      experience.examType == 'BCS' ? Icons.badge_rounded : Icons.person_rounded,
                      color: themeColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experience.candidateName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (experience.edition.isNotEmpty)
                          Text(
                            '${config.yearFilterLabel ?? "সংস্করণ"}: ${experience.edition}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          )
                        else if (experience.district.isNotEmpty)
                          Text(
                            '${config.districtFilterLabel ?? "জেলা"}: ${experience.district}${experience.upazila.isNotEmpty ? ", উপজেলা: ${experience.upazila}" : ""}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: const Text(
                      'সফল',
                      style: TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info Pills Grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetaChip(
                        icon: Icons.book_rounded,
                        label: 'বিষয়: ${experience.subject}',
                        bgColor: const Color(0xFFF1F5F9),
                        textColor: const Color(0xFF475569),
                      ),
                      _buildMetaChip(
                        icon: Icons.timer_rounded,
                        label: 'সময়: ${experience.duration}',
                        bgColor: const Color(0xFFF1F5F9),
                        textColor: const Color(0xFF475569),
                      ),
                      if (experience.board.isNotEmpty)
                        _buildMetaChip(
                          icon: Icons.assignment_ind_rounded,
                          label: 'বোর্ড: ${experience.board}',
                          bgColor: const Color(0xFFF1F5F9),
                          textColor: const Color(0xFF475569),
                        ),
                      if (experience.result.isNotEmpty && experience.result != 'ফলাফল পাওয়া যায়নি')
                        _buildMetaChip(
                          icon: Icons.emoji_events_rounded,
                          label: experience.result,
                          bgColor: const Color(0xFFFEF3C7),
                          textColor: const Color(0xFFB45309),
                        ),
                    ],
                  ),

                  // Display choices if available
                  if (experience.choices.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '${config.choicesFilterLabel ?? "পছন্দক্রম"}:',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: experience.choices.map((choice) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            choice,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Display total dialogue count
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.forum_rounded, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            '${experience.transcript.length} টি কথোপকথন ভিউ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => VivaTranscriptPage(experience: experience),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chrome_reader_mode_rounded, size: 16),
                        label: const Text('ভাইভা ডায়ালগ দেখুন'),
                        style: TextButton.styleFrom(
                          foregroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: themeColor.withOpacity(0.2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SLIDING TAB BAR ---
  Widget _buildSlidingTabBar(BuildContext context, WidgetRef ref, int activeTab) {
    final tabs = ['ভাইভা লাইব্রেরি', 'নতুন সার্কুলার', 'পরীক্ষার ফলাফল'];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 3;
          return Stack(
            children: [
              // Sliding background capsule
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                alignment: Alignment(
                  activeTab == 0 ? -1.0 : (activeTab == 1 ? 0.0 : 1.0),
                  0.0,
                ),
                child: Container(
                  width: tabWidth - 2,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tab items
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = activeTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(libraryActiveTabProvider.notifier).state = index;
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                            fontFamily: 'Inter',
                          ),
                          child: Text(tabs[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CIRCULARS TAB ---
  Widget _buildCircularsTab(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredJobCircularsProvider);
    final searchController = TextEditingController(text: ref.read(circularsSearchQueryProvider));

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                ref.read(circularsSearchQueryProvider.notifier).state = val;
              },
              decoration: InputDecoration(
                hintText: 'সার্কুলার বা প্রতিষ্ঠান খুঁজুন...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 18),
                        onPressed: () {
                          searchController.clear();
                          ref.read(circularsSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                ),
              ),
            ),
          ),

          // List content
          Expanded(
            child: filteredAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'কোনো সার্কুলার খুঁজে পাওয়া যায়নি',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'অনুগ্রহ করে অন্য শব্দ দিয়ে চেষ্টা করুন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildDocCard(
                      context: context,
                      title: item.title,
                      org: item.organization,
                      date: item.publishDate,
                      size: item.fileSize,
                      desc: item.description,
                      pdfUrl: item.pdfUrl,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                  ),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'সার্কুলার লোড করা সম্ভব হয়নি: $err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- RESULTS TAB ---
  Widget _buildResultsTab(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredJobResultsProvider);
    final searchController = TextEditingController(text: ref.read(resultsSearchQueryProvider));

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                ref.read(resultsSearchQueryProvider.notifier).state = val;
              },
              decoration: InputDecoration(
                hintText: 'পরীক্ষার নাম বা প্রতিষ্ঠান খুঁজুন...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 18),
                        onPressed: () {
                          searchController.clear();
                          ref.read(resultsSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                ),
              ),
            ),
          ),

          // List content
          Expanded(
            child: filteredAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'কোনো ফলাফল খুঁজে পাওয়া যায়নি',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'অনুগ্রহ করে অন্য শব্দ দিয়ে চেষ্টা করুন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildDocCard(
                      context: context,
                      title: item.title,
                      org: item.organization,
                      date: item.publishDate,
                      size: item.fileSize,
                      desc: item.description,
                      pdfUrl: item.pdfUrl,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                  ),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'ফলাফল লোড করা সম্ভব হয়নি: $err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DOCUMENT CARD WIDGET ---
  Widget _buildDocCard({
    required BuildContext context,
    required String title,
    required String org,
    required String date,
    required String size,
    required String desc,
    required String pdfUrl,
  }) {
    Color tagBgColor = const Color(0xFFF0FDF4);
    Color tagTextColor = const Color(0xFF15803D);
    if (org.contains('BPSC') || org.contains('পিএসসি')) {
      tagBgColor = const Color(0xFFECFDF5);
      tagTextColor = const Color(0xFF047857);
    } else if (org.contains('Bank') || org.contains('ব্যাংক') || org.contains('BSCC')) {
      tagBgColor = const Color(0xFFEEF2FF);
      tagTextColor = const Color(0xFF4338CA);
    } else if (org.contains('DPE') || org.contains('প্রাথমিক')) {
      tagBgColor = const Color(0xFFEFF6FF);
      tagTextColor = const Color(0xFF1D4ED8);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => PdfViewerPage(
                  title: title,
                  pdfUrl: pdfUrl,
                  organization: org,
                  publishDate: date,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        org,
                        style: TextStyle(
                          color: tagTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        Text(
                          size,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          'পিডিএফ দেখুন',
                          style: TextStyle(
                            color: Color(0xFF0F766E),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Color(0xFF0F766E),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
