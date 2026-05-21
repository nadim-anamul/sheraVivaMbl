import 'dart:math' as math;
import 'package:flutter/material.dart';

class ReportAnalysisPage extends StatelessWidget {
  const ReportAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ভাইভা দক্ষতা বিশ্লেষণ রিপোর্ট',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Overall Score Header Card
            _buildOverallScoreCard(),
            const SizedBox(height: 20),

            // 2. Performance Bar Chart
            _buildPerformanceChartCard(),
            const SizedBox(height: 20),

            // 3. Sub-Skills Progress Section
            _buildSkillsBreakdownSection(),
            const SizedBox(height: 24),

            // 4. Key Feedback (Strengths and Weaknesses)
            _buildFeedbackSection(),
            const SizedBox(height: 24),

            // 5. Recommended Study Action Items
            _buildActionPlanTimeline(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          // Glowing radial circular score display
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _OverallCircularScorePainter(
                      scoreFraction: 0.78,
                    ),
                  ),
                ),
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '৭৮',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '১০০ তে',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Overview text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'সর্বশেষ ভাইভা ফলাফল',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'উত্তম অগ্রগতি (Good Progress)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'বিগত সেশন থেকে আপনার বাচনভঙ্গি ও আত্মবিশ্বাস ৫% বৃদ্ধি পেয়েছে।',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ভাইভা স্কোর ট্র্যাকার',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                // Legend badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Color(0xFF0F766E)),
                      SizedBox(width: 6),
                      Text(
                        'সেশন স্কোর',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Bar Chart Canvas
            const SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _BarChartPainter(
                  scores: [62, 70, 68, 75, 78],
                  labels: ['মক ১', 'এআই ২', 'মক ৩', 'এআই ৪', 'মক ৫'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'দক্ষতা বিশ্লেষণ (Sub-Skills Breakdown)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        
        // Horizontal Scroll or Grid of subskills
        Row(
          children: [
            Expanded(
              child: _buildSkillArcGauge(
                title: 'যোগাযোগ',
                value: 80,
                color: const Color(0xFF0F766E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSkillArcGauge(
                title: 'আত্মবিশ্বাস',
                value: 75,
                color: const Color(0xFFD97706), // amber
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSkillArcGauge(
                title: 'বিষয় জ্ঞান',
                value: 85,
                color: const Color(0xFF10B981), // emerald
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillArcGauge({
    required String title,
    required double value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          // Circular Arc Custom Paint
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SkillGaugeArcPainter(
                      progress: value / 100,
                      color: color,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1: Strengths
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'সবল দিক',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBulletPoint('চমৎকার বাচনভঙ্গি ও শব্দ চয়ন', const Color(0xFF047857)),
                _buildBulletPoint('কূটনৈতিক পরিস্থিতিতে যৌক্তিক উত্তর', const Color(0xFF047857)),
                _buildBulletPoint('আইন শৃঙ্খলা ব্যবস্থার চমৎকার জ্ঞান', const Color(0xFF047857)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Column 2: Weaknesses
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'উন্নয়ন ক্ষেত্র',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBulletPoint('প্রশ্ন সম্পূর্ণ হওয়ার পূর্বে উত্তরদান পরিহার', const Color(0xFFB91C1C)),
                _buildBulletPoint('ভয়েস মডুলেশন মাঝেমধ্যে দ্রুত হয়ে যায়', const Color(0xFFB91C1C)),
                _buildBulletPoint('অর্থনৈতিক পরিভাষাগুলোর চর্চা প্রয়োজন', const Color(0xFFB91C1C)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlanTimeline() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'পরবর্তী প্রস্তুতি রোডম্যাপ (Recommended Action Items)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),

          // Action 1
          _buildTimelineStep(
            stepNumber: '১',
            title: 'মাঠ প্রশাসনের কাঠামো পর্যালোচনা',
            subtitle: 'উপজেলা ও জেলা প্রশাসনের কার্যাবলী গভীরভাবে আয়ত্ত করুন।',
            isCompleted: false,
          ),
          
          _buildTimelineDivider(),

          // Action 2
          _buildTimelineStep(
            stepNumber: '২',
            title: 'কারেন্ট অ্যাফেয়ার্স প্র্যাকটিস',
            subtitle: 'বাংলাদেশ বাজেট ও নতুন পঞ্চবার্ষিকী পরিকল্পনা সম্বলিত তথ্য পড়ুন।',
            isCompleted: false,
          ),
          
          _buildTimelineDivider(),

          // Action 3
          _buildTimelineStep(
            stepNumber: '৩',
            title: 'এআই স্পিচ প্র্যাকটিস',
            subtitle: 'স্পিচ পজ কমাতে ড্যাশবোর্ডের এআই দিয়ে ২ বার ট্রায়াল দিন।',
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0F766E), width: 1.5),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Color(0xFF0F766E),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 13.5, top: 4, bottom: 4),
      height: 18,
      width: 1.5,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class _OverallCircularScorePainter extends CustomPainter {
  _OverallCircularScorePainter({required this.scoreFraction});

  final double scoreFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 4;

    final basePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, basePaint);

    final scorePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * scoreFraction,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OverallCircularScorePainter oldDelegate) {
    return oldDelegate.scoreFraction != scoreFraction;
  }
}

class _SkillGaugeArcPainter extends CustomPainter {
  _SkillGaugeArcPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 4;

    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SkillGaugeArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({required this.scores, required this.labels});

  final List<double> scores;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 1. Draw horizontal baseline and grid indicators
    final linePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;
    
    // Draw 3 horizontal grid lines (at 50%, 75%, 100%)
    for (int j = 1; j <= 3; j++) {
      final y = size.height - (size.height - 24) * (j / 3.0) - 20;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      
      textPainter.text = TextSpan(
        text: '${(j * 33).toInt()}',
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 10));
    }

    final barCount = scores.length;
    final spacing = size.width / (barCount + 1);
    final maxBarHeight = size.height - 40;

    for (int i = 0; i < barCount; i++) {
      final score = scores[i];
      final label = labels[i];
      
      // Calculate coordinates
      final x = (i + 1) * spacing;
      final barHeight = maxBarHeight * (score / 100.0);
      final top = size.height - barHeight - 20;
      final bottom = size.height - 20;
      
      // Setup beautiful gradient fill
      final rect = Rect.fromLTRB(x - 10, top, x + 10, bottom);
      paint.shader = const LinearGradient(
        colors: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

      // Draw rounded rectangular bar
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
      canvas.drawRRect(rrect, paint);

      // 2. Draw Score Text Label above bar
      textPainter.text = TextSpan(
        text: '${score.toInt()}',
        style: const TextStyle(
          color: Color(0xFF0F766E),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, top - 14));

      // 3. Draw X-axis Bottom Labels
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, bottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}
