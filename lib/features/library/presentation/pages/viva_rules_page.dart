import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/viva_library_provider.dart';

class VivaRulesPage extends ConsumerWidget {
  const VivaRulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(vivaRulesProvider);

    return rulesAsync.when(
      data: (config) {
        Color dosColor = const Color(0xFF057857);
        Color dosBgColor = const Color(0xFFECFDF5);
        try {
          if (config.dos.color.isNotEmpty) {
            final hex = config.dos.color.replaceAll('#', '');
            dosColor = Color(int.parse('FF$hex', radix: 16));
          }
          if (config.dos.bgColor.isNotEmpty) {
            final hex = config.dos.bgColor.replaceAll('#', '');
            dosBgColor = Color(int.parse('FF$hex', radix: 16));
          }
        } catch (_) {}

        Color dontsColor = const Color(0xFFDC2626);
        Color dontsBgColor = const Color(0xFFFEF2F2);
        try {
          if (config.donts.color.isNotEmpty) {
            final hex = config.donts.color.replaceAll('#', '');
            dontsColor = Color(int.parse('FF$hex', radix: 16));
          }
          if (config.donts.bgColor.isNotEmpty) {
            final hex = config.donts.bgColor.replaceAll('#', '');
            dontsBgColor = Color(int.parse('FF$hex', radix: 16));
          }
        } catch (_) {}

        IconData generalTipIcon = Icons.tips_and_updates_outlined;
        if (config.generalTip.icon == 'tips_and_updates_outlined') {
          generalTipIcon = Icons.tips_and_updates_outlined;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'বোর্ড আচরণবিধি (Viva Rules)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: <Widget>[
              _RuleBlock(
                title: config.dos.title,
                icon: config.dos.icon == 'check_circle_rounded' ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                rules: config.dos.rules,
                themeColor: dosColor,
                bgColor: dosBgColor,
              ),
              const SizedBox(height: 20),
              
              _RuleBlock(
                title: config.donts.title,
                icon: config.donts.icon == 'cancel_rounded' ? Icons.cancel_rounded : Icons.cancel_outlined,
                rules: config.donts.rules,
                themeColor: dontsColor,
                bgColor: dontsBgColor,
              ),
              const SizedBox(height: 20),
              
              if (config.generalTip.content.isNotEmpty)
                _GeneralTipCard(
                  title: config.generalTip.title,
                  icon: generalTipIcon,
                  content: config.generalTip.content,
                ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text(
            'বোর্ড আচরণবিধি (Viva Rules)',
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
            'বোর্ড আচরণবিধি (Viva Rules)',
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
                  'নিয়মাবলী লোড করা সম্ভব হয়নি: $err',
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

class _RuleBlock extends StatelessWidget {
  const _RuleBlock({
    required this.title,
    required this.icon,
    required this.rules,
    required this.themeColor,
    required this.bgColor,
  });

  final String title;
  final IconData icon;
  final List<String> rules;
  final Color themeColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Icon(icon, color: themeColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final rule in rules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.arrow_right_alt_rounded,
                            size: 16,
                            color: themeColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rule,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralTipCard extends StatelessWidget {
  const _GeneralTipCard({
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
