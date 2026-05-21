import 'package:flutter/material.dart';

class VivaHistoryPage extends StatelessWidget {
  const VivaHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock history items for high-fidelity simulation
    final List<_MockHistoryItem> historyList = [
      _MockHistoryItem(
        title: 'লাইভ ক্যাডার ভাইভা বোর্ড #৩',
        dateTime: 'আজ, ১০:১৫ AM',
        isAi: false,
        score: 78,
        grade: 'A-',
        topic: 'প্রশাসন ক্যাডার (মাঠ প্রশাসন)',
        feedback: 'উত্তরদানে বেশ সাবলীল ও আত্মবিশ্বাসী ছিলেন। ম্যাজিস্ট্রেসির ব্যাখ্যা চমৎকার হয়েছে, তবে আইনের ধারাগুলো আরও নির্দিষ্ট করে উল্লেখ করতে পারলে ভালো হতো।',
      ),
      _MockHistoryItem(
        title: 'এআই মক সেশন #৪',
        dateTime: 'গতকাল, ০৫:৩০ PM',
        isAi: true,
        score: 75,
        grade: 'B+',
        topic: 'পুলিশ ক্যাডার (সাইবার সিকিউরিটি)',
        feedback: 'সাইবার সিকিউরিটি অ্যাক্ট নিয়ে প্রশ্নগুলোর যৌক্তিক ব্যাখ্যা দিয়েছেন। স্পিচ পজ কিছুটা স্বাভাবিকের চেয়ে বেশি ছিল, পরবর্তী সেশনে গতি বজায় রাখুন।',
      ),
      _MockHistoryItem(
        title: 'লাইভ সাবজেক্ট ভাইভা বোর্ড #২',
        dateTime: '১৫ মে ২০২৬, ১১:০০ AM',
        isAi: false,
        score: 68,
        grade: 'B-',
        topic: 'পররাষ্ট্র ক্যাডার (দ্বিপাক্ষিক সম্পর্ক)',
        feedback: 'কূটনৈতিক উত্তর শৈলী চমৎকার ছিল। তবে সাম্প্রতিক রোহিঙ্গা সংকটের অর্থনৈতিক প্রভাব সম্পর্কিত প্রশ্নে আরেকটু বিশদ হওয়া বাঞ্ছনীয় ছিল।',
      ),
      _MockHistoryItem(
        title: 'এআই মক সেশন #৩',
        dateTime: '১০ মে ২০২৬, ০৪:১৫ PM',
        isAi: true,
        score: 70,
        grade: 'B',
        topic: 'প্রশাসন ক্যাডার (সেন্ট্রাল এডমিন)',
        feedback: 'সচিবালয়ের গঠনতন্ত্র সংক্রান্ত সব প্রশ্নের সঠিক উত্তর দিয়েছেন। চোখের কন্টাক্ট এবং বাচনভঙ্গিতে আরও জড়তা দূর করতে হবে।',
      ),
      _MockHistoryItem(
        title: 'লাইভ প্রিলিমিনারি ভাইভা #১',
        dateTime: '০২ মে ২০২৬, ০৯:৪৫ AM',
        isAi: false,
        score: 62,
        grade: 'C+',
        topic: 'সাধারণ জ্ঞান (মুক্তিযুদ্ধ ও বাংলাদেশ)',
        feedback: 'মুক্তিযুদ্ধ ভিত্তিক সাধারণ তথ্যে ভালো দখল আছে। সংবিধানের অনুচ্ছেদগুলো রিভিশন দেওয়া প্রয়োজন। আত্মবিশ্বাস বাড়াতে নিয়মিত অনুশীলন করুন।',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ভাইভা ইতিহাস ও আর্কাইভ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Top Summary Stats Card
          _buildSummaryStatsCard(),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'বিগত ভাইভা সেশনসমূহ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),

          // Scrollable Timeline List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];
                final isLast = index == historyList.length - 1;
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Timeline Indicator
                    _buildTimelineConnector(item.isAi, isLast),
                    
                    // Right Content Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _buildHistoryItemCard(context, item),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatsCard() {
    return Container(
      margin: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem('মোট ভাইভা', '৫টি', Icons.video_camera_back_outlined),
          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
          _buildSummaryItem('গড় স্কোর', '৭২%', Icons.star_outline_rounded),
          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
          _buildSummaryItem('সবশেষ গ্রেড', 'A-', Icons.assignment_turned_in_outlined),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF0F766E)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F766E),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(bool isAi, bool isLast) {
    return Column(
      children: [
        // Timeline Dot representing session type
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isAi ? const Color(0xFF0F766E).withOpacity(0.1) : const Color(0xFFD97706).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isAi ? const Color(0xFF0F766E) : const Color(0xFFD97706),
              width: 2.0,
            ),
          ),
          child: Center(
            child: Icon(
              isAi ? Icons.smart_toy_outlined : Icons.videocam_rounded,
              size: 16,
              color: isAi ? const Color(0xFF0F766E) : const Color(0xFFD97706),
            ),
          ),
        ),
        
        // Vertical connecting line
        if (!isLast)
          Container(
            width: 2.0,
            height: 155, // Approximate card height offset
            color: const Color(0xFFE2E8F0),
          ),
      ],
    );
  }

  Widget _buildHistoryItemCard(BuildContext context, _MockHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(left: 14),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Session title, grade bubble, score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.dateTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Score grade bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.score >= 75 
                          ? [const Color(0xFF0F766E), const Color(0xFF2DD4BF)]
                          : [const Color(0xFFD97706), const Color(0xFFFBBF24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.grade} (${item.score})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Subject Tag Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.assignment_outlined, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    item.topic,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Feedback summary
            Text(
              item.feedback,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
            
            const SizedBox(height: 14),
            
            // Bottom play/feedback buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('অডিও ব্যাকআপ লোড হচ্ছে...')),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 14),
                  label: const Text('রেকর্ড শুনুন', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('বিস্তারিত ফলাফল লোড হচ্ছে...')),
                    );
                  },
                  icon: const Icon(Icons.assessment_outlined, size: 14),
                  label: const Text('বিস্তারিত রিপোর্ট', style: TextStyle(fontSize: 11)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MockHistoryItem {
  _MockHistoryItem({
    required this.title,
    required this.dateTime,
    required this.isAi,
    required this.score,
    required this.grade,
    required this.topic,
    required this.feedback,
  });

  final String title;
  final String dateTime;
  final bool isAi;
  final double score;
  final String grade;
  final String topic;
  final String feedback;
}
