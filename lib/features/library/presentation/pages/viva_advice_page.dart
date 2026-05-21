import 'package:flutter/material.dart';

class VivaAdvicePage extends StatelessWidget {
  const VivaAdvicePage({super.key});

  static const List<String> _beforeViva = <String>[
    'ইন্টারভিউর আগের রাতে ৬-৭ ঘণ্টা গভীর ঘুম নিশ্চিত করুন।',
    'নিজের জেলা, বিশ্ববিদ্যালয় ও কাঙ্ক্ষিত ক্যাডার সম্পর্কে সাম্প্রতিক ডাটা আপডেট নিন।',
    '১ মিনিটে একটি আকর্ষণীয় ও সাবলীল আত্মপরিচয় অন্তত ৩ বার আয়নার সামনে অনুশীলন করুন।',
    'প্রয়োজনীয় সকল সার্টিফিকেট ও ডকুমেন্টস ফাইল করে গুছিয়ে রাখুন।',
  ];

  static const List<String> _duringViva = <String>[
    'বোর্ড রুমে প্রবেশের অনুমতি নিয়ে বিনয়ের সাথে সালাম বা সম্মানসূচক অভিবাদন জানান।',
    'কোনো প্রশ্নের উত্তর সরাসরি জানা না থাকলে অপ্রাসঙ্গিক ঘুরিয়ে কথা না বলে বিনীতভাবে "এই মুহূর্তে নিশ্চিত নই" বলুন।',
    'সংক্ষিপ্ত, কাঠামোবদ্ধ ও সরাসরি উত্তর দেওয়ার অভ্যাস করুন।',
    'মতামতভিত্তিক বা সংবেদনশীল প্রশ্নে সব সময় একটি ভারসাম্যপূর্ণ ও যুক্তিসঙ্গত দৃষ্টিভঙ্গি বজায় রাখুন।',
  ];

  static const List<String> _afterViva = <String>[
    'রুম থেকে বের হওয়ার সময় অবশ্যই ধন্যবাদ ও সালাম জানিয়ে বিনীতভাবে বের হন।',
    'বের হয়ে প্রথম ৫ মিনিটে কী কী ভালো হয়েছে এবং কোন জায়গায় দুর্বলতা ছিল তা সংক্ষেপে ডায়েরিতে লিখে রাখুন।',
    'যে প্রশ্নগুলোর উত্তর দিতে অসুবিধা হয়েছে, সেগুলোর সঠিক সমাধান এখনই খুঁজে শর্ট নোট তৈরি করুন।',
    'পরবর্তী মক সেশনের জন্য নির্দিষ্ট দুটি ক্ষেত্রকে চিহ্নিত করুন যেখানে উন্নতি করা প্রয়োজন।',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ভাইভা পরামর্শ (Viva Advice)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF0F766E),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF0F766E),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'ভাইভার পূর্বে', icon: Icon(Icons.timer_outlined, size: 20)),
              Tab(text: 'ভাইভা চলাকালীন', icon: Icon(Icons.psychology_outlined, size: 20)),
              Tab(text: 'ভাইভার পরবর্তীতে', icon: Icon(Icons.assignment_turned_in_outlined, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AdviceList(tips: _beforeViva, sectionColor: Color(0xFF0F766E)),
            _AdviceList(tips: _duringViva, sectionColor: Color(0xFFD97706)),
            _AdviceList(tips: _afterViva, sectionColor: Color(0xFF475569)),
          ],
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
                // Curved Number Index
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
                
                // Tip Content
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
