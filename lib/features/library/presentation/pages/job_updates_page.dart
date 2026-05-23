import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../providers/viva_library_provider.dart';
import 'pdf_viewer_page.dart';

class JobUpdatesPage extends ConsumerWidget {
  const JobUpdatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'বিজ্ঞপ্তি ও ফলাফল',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabAlignment: TabAlignment.fill,
            labelColor: Color(0xFF0F766E),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFF0F766E),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            tabs: [
              Tab(
                text: 'সার্কুলার ও বিজ্ঞপ্তি',
                icon: Icon(Icons.description_outlined, size: 20),
              ),
              Tab(
                text: 'পরীক্ষার ফলাফল',
                icon: Icon(Icons.assignment_turned_in_outlined, size: 20),
              ),
            ],
          ),
          shape: const Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        body: TabBarView(
          children: [
            _buildCircularsTab(context, ref),
            _buildResultsTab(context, ref),
          ],
        ),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
