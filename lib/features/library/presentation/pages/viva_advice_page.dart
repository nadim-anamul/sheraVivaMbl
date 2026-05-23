import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/viva_library_provider.dart';

class VivaAdvicePage extends ConsumerWidget {
  const VivaAdvicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adviceAsync = ref.watch(vivaAdviceProvider);

    return adviceAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'ভাইভা পরামর্শ (Viva Advice)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: const Center(
              child: Text(
                'কোনো পরামর্শ পাওয়া যায়নি।',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'ভাইভা পরামর্শ (Viva Advice)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                labelColor: const Color(0xFF0F766E),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFF0F766E),
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: categories.map((cat) {
                  IconData iconData = Icons.timer_outlined;
                  if (cat.icon == 'psychology_outlined') {
                    iconData = Icons.psychology_outlined;
                  } else if (cat.icon == 'assignment_turned_in_outlined') {
                    iconData = Icons.assignment_turned_in_outlined;
                  }
                  return Tab(text: cat.title, icon: Icon(iconData, size: 20));
                }).toList(),
              ),
            ),
            body: TabBarView(
              children: categories.map((cat) {
                Color sectionColor = const Color(0xFF0F766E);
                try {
                  if (cat.color.isNotEmpty) {
                    final hex = cat.color.replaceAll('#', '');
                    sectionColor = Color(int.parse('FF$hex', radix: 16));
                  }
                } catch (_) {}

                return _AdviceList(tips: cat.tips, sectionColor: sectionColor);
              }).toList(),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text(
            'ভাইভা পরামর্শ (Viva Advice)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'ভাইভা পরামর্শ (Viva Advice)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                Text(
                  'পরামর্শ লোড করা সম্ভব হয়নি: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdviceList extends StatelessWidget {
  const _AdviceList({required this.tips, required this.sectionColor});

  final List<String> tips;
  final Color sectionColor;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: sectionColor.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: sectionColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    tips[index],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
