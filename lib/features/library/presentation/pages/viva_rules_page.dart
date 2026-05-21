import 'package:flutter/material.dart';

class VivaRulesPage extends StatelessWidget {
  const VivaRulesPage({super.key});

  static const List<String> _dos = <String>[
    'বোর্ড রুমে প্রবেশের পূর্বে সালাম বা সম্মানসূচক অভিবাদন দিন।',
    'বসার পর উত্তর দেওয়ার সময় প্রতিটি বোর্ড মেম্বারের সাথে চোখ মিলিয়ে (eye contact) কথা বলুন।',
    'যা জানেন না, অতিরিক্ত না বাড়িয়ে স্পষ্টভাবে বলুন: "এই মুহূর্তে বিষয়টি আমার জানা নেই"।',
    'উত্তরে প্রাসঙ্গিক তথ্য, পরিসংখ্যান ও বাস্তব উদাহরণ দেওয়ার চেষ্টা করুন।',
    'মার্জিত ও পরিষ্কার ফরমাল পোশাক পরিধান করুন।',
  ];

  static const List<String> _donts = <String>[
    'অতিরিক্ত হাত নেড়ে বা চেয়ারে হেলে কথা বলা এড়িয়ে চলুন।',
    'বোর্ড সদস্যের কথা শেষ হওয়ার পূর্বে কোনোভাবেই উত্তর শুরু করবেন না।',
    'রাজনৈতিক বা সংবেদনশীল প্রশ্নে চরম কোনো ব্যক্তিগত অবস্থান নেবেন না।',
    'মোবাইল ফোন সম্পূর্ণ সাইলেন্ট বা বন্ধ না রেখে কোনোভাবেই রুমে প্রবেশ করবেন না।',
    'জানার ভান করে ভুল বা বিভ্রান্তিকর তথ্য বোর্ডকে দেওয়ার চেষ্টা করবেন না।',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'বোর্ড আচরণবিধি (Viva Rules)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: const <Widget>[
          // DOs Section
          _RuleBlock(
            title: 'যা করবেন (Do)',
            icon: Icons.check_circle_rounded,
            rules: _dos,
            themeColor: Color(0xFF057857), // emerald-700
            bgColor: Color(0xFFECFDF5), // emerald-50
          ),
          SizedBox(height: 20),
          
          // DONTs Section
          _RuleBlock(
            title: 'যা বর্জন করবেন (Don\'t)',
            icon: Icons.cancel_rounded,
            rules: _donts,
            themeColor: Color(0xFFDC2626), // red-600
            bgColor: Color(0xFFFEF2F2), // red-50
          ),
          SizedBox(height: 20),
          
          // Interactive Board Tip Card
          _GeneralTipCard(),
        ],
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
          // Header Bar
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
          
          // Rules List
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
  const _GeneralTipCard();

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
          const Icon(Icons.tips_and_updates_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'বিশেষ পরামর্শ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'মনে রাখবেন, ভাইভা বোর্ড আপনার জ্ঞানের গভীরতা যেমন দেখে, তার চেয়ে বেশি আপনার ব্যক্তিত্ব, বিচার-বিবেচনা, তাৎক্ষণিক সিদ্ধান্ত গ্রহণের ক্ষমতা ও মার্জিত আচরণ মূল্যায়ন করে। আত্মবিশ্বাসী থাকুন!',
                  style: TextStyle(
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
