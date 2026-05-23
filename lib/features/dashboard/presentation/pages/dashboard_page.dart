import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../library/presentation/pages/pdf_viewer_page.dart';
import '../../../library/presentation/providers/viva_library_provider.dart';
import '../widgets/dashboard_feature_card.dart';

final dashboardLayoutProvider = StateProvider<bool>((ref) => true); // true = grid (default), false = list

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGridView = ref.watch(dashboardLayoutProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // 1. Curved Green Header (Scrolls naturally with content to prevent overlapping cards)
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Top Curved Gradient Header background decoration
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: const _CurvedHeader(),
                ),
                
                // Column of welcome appbar, profile, and progress card
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(context, ref),
                        const SizedBox(height: 12),
                        _buildProfileWelcome(),
                        const SizedBox(height: 20),
                        const _PrepProgressCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Main Scrollable Dashboard Content
          isGridView
              ? _buildGridDashboard(context, ref)
              : _buildListDashboard(context, ref),
        ],
      ),
    );
  }

  Widget _buildListDashboard(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 24, top: 12),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Section: Latest Circulars & Results Updates (Slider)
          _SectionTitle(
            title: 'বিজ্ঞপ্তি ও ফলাফল আপডেট',
            actionLabel: 'সব দেখুন',
            onAction: () {
              context.push(AppRoutes.jobUpdates);
            },
          ),
          const SizedBox(height: 8),
          const _UpdatesSlider(),
          const SizedBox(height: 24),

          // Section 1: Viva Practice
          _SectionTitle(
            title: 'ভাইভা প্র্যাকটিস',
            actionLabel: 'ফর্ম পূরণ করুন',
            onAction: () => context.push(AppRoutes.vivaForm),
          ),
          const SizedBox(height: 8),
          DashboardFeatureCard(
            title: 'AI Conversation',
            subtitle: 'এআই-এর সাথে সরাসরি মক ভাইভা অনুশীলন',
            icon: Icons.smart_toy_outlined,
            onTap: () => context.push(AppRoutes.aiConversation),
            gradientColors: const [Color(0xFF0F766E), Color(0xFF0D9488)],
          ),
          DashboardFeatureCard(
            title: 'Live Viva',
            subtitle: 'বিষয়ভিত্তিক লাইভ ভাইভা সেশন',
            icon: Icons.videocam_outlined,
            onTap: () => context.push(AppRoutes.liveViva),
            gradientColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
          ),
          DashboardFeatureCard(
            title: 'Report & Analysis',
            subtitle: 'দক্ষতা ও দুর্বলতা বিশ্লেষণ রিপোর্ট',
            icon: Icons.analytics_outlined,
            onTap: () => context.push(AppRoutes.reportAnalysis),
            gradientColors: const [Color(0xFF0D9488), Color(0xFF2DD4BF)],
          ),
          const SizedBox(height: 20),
          
          // Section 2: Library & Learning
          const _SectionTitle(title: 'লাইব্রেরি ও প্রস্তুতি'),
          const SizedBox(height: 8),
          DashboardFeatureCard(
            title: 'Viva Library',
            subtitle: 'বিষয়ভিত্তিক নমুনা ও পূর্ববর্তী প্রশ্নব্যাংক',
            icon: Icons.library_books_outlined,
            onTap: () => context.push(AppRoutes.vivaLibrary),
            gradientColors: const [Color(0xFFB45309), Color(0xFFD97706)],
          ),
          DashboardFeatureCard(
            title: 'Viva Advice',
            subtitle: 'ভাইভাতে সফল হওয়ার কৌশল ও পরামর্শ',
            icon: Icons.tips_and_updates_outlined,
            onTap: () => context.push(AppRoutes.vivaAdvice),
            gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
          ),
          DashboardFeatureCard(
            title: 'Viva Rules',
            subtitle: 'ভাইভা বোর্ডের আচরণবিধি ও পোশাক নির্বাচন',
            icon: Icons.gavel_outlined,
            onTap: () => context.push(AppRoutes.vivaRules),
            gradientColors: const [Color(0xFFB45309), Color(0xFFF59E0B)],
          ),
          const SizedBox(height: 20),
          
          // Section 3: Archive & History
          const _SectionTitle(title: 'আর্কাইভ'),
          const SizedBox(height: 8),
          DashboardFeatureCard(
            title: 'Your Viva History',
            subtitle: 'পূর্ববর্তী সেশন রেকর্ড, স্কোর এবং অগ্রগতি ট্র্যাকার',
            icon: Icons.history_outlined,
            onTap: () => context.push(AppRoutes.vivaHistory),
            gradientColors: const [Color(0xFF475569), Color(0xFF64748B)],
          ),
        ]),
      ),
    );
  }

  Widget _buildGridDashboard(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Taller aspect ratio for narrow viewports to avoid text overflows; wider for tablets to prevent blockiness
    final double gridAspectRatio = screenWidth < 360 ? 1.12 : (screenWidth > 600 ? 1.38 : 1.22);

    return SliverPadding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 24, top: 12),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Section: Latest Updates (Full width Slider)
          _SectionTitle(
            title: 'বিজ্ঞপ্তি ও ফলাফল আপডেট',
            actionLabel: 'সব দেখুন',
            onAction: () {
              context.push(AppRoutes.jobUpdates);
            },
          ),
          const SizedBox(height: 8),
          const _UpdatesSlider(),
          const SizedBox(height: 24),

          // Section 1: ভাইভা প্র্যাকটিস (AI, Live, Report, and Stats) -> 2 Column Grid
          _SectionTitle(
            title: 'ভাইভা প্র্যাকটিস',
            actionLabel: 'ফর্ম পূরণ করুন',
            onAction: () => context.push(AppRoutes.vivaForm),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: gridAspectRatio,
            children: [
              _buildGridCard(
                title: 'AI Conversation',
                subtitle: 'এআই মক ভাইভা অনুশীলন',
                acronym: 'AI',
                icon: Icons.smart_toy_outlined,
                brandColor: const Color(0xFF0F766E),
                badgeText: 'AI Live',
                onTap: () => context.push(AppRoutes.aiConversation),
              ),
              _buildGridCard(
                title: 'Live Viva',
                subtitle: 'লাইভ ভাইভা সেশন',
                acronym: 'LV',
                icon: Icons.videocam_outlined,
                brandColor: const Color(0xFF0D9488),
                badgeText: 'LIVE',
                onTap: () => context.push(AppRoutes.liveViva),
              ),
              _buildGridCard(
                title: 'Report & Analysis',
                subtitle: 'দক্ষতা বিশ্লেষণ রিপোর্ট',
                acronym: 'RP',
                icon: Icons.analytics_outlined,
                brandColor: const Color(0xFF047857),
                onTap: () => context.push(AppRoutes.reportAnalysis),
              ),
              _buildStatsGridCard(ref),
            ],
          ),
          const SizedBox(height: 28),

          // Section 2: লাইব্রেরি ও প্রস্তুতি -> 2 Column Grid
          const _SectionTitle(title: 'লাইব্রেরি ও প্রস্তুতি'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: gridAspectRatio,
            children: [
              _buildGridCard(
                title: 'Viva Library',
                subtitle: 'প্রশ্নব্যাংক ও নমুনা',
                acronym: 'LB',
                icon: Icons.library_books_outlined,
                brandColor: const Color(0xFFB45309),
                badgeText: 'NEW',
                onTap: () => context.push(AppRoutes.vivaLibrary),
              ),
              _buildGridCard(
                title: 'Viva Advice',
                subtitle: 'কৌশল ও পরামর্শ',
                acronym: 'AD',
                icon: Icons.tips_and_updates_outlined,
                brandColor: const Color(0xFFD97706),
                onTap: () => context.push(AppRoutes.vivaAdvice),
              ),
              _buildGridCard(
                title: 'Viva Rules',
                subtitle: 'আচরণবিধি ও পোশাক',
                acronym: 'RL',
                icon: Icons.gavel_outlined,
                brandColor: const Color(0xFFC2410C),
                onTap: () => context.push(AppRoutes.vivaRules),
              ),
              _buildGridCard(
                title: 'History Archive',
                subtitle: 'ভাইভা আর্কাইভ ও রেকর্ড',
                acronym: 'HS',
                icon: Icons.history_outlined,
                brandColor: const Color(0xFF475569),
                onTap: () => context.push(AppRoutes.vivaHistory),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildGridCard({
    required String title,
    required String subtitle,
    required String acronym,
    required IconData icon,
    required Color brandColor,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Circular Acronym Avatar & Soft Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: brandColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                acronym,
                                style: TextStyle(
                                  color: brandColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            icon,
                            color: brandColor.withOpacity(0.6),
                            size: 18,
                          ),
                        ],
                      ),
                      // Bottom Column: Text info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Badge on top right of the card
            if (badgeText != null)
              Positioned(
                top: 0,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: badgeText.toLowerCase() == 'live' 
                        ? const Color(0xFFEF4444) // Bright red for live
                        : const Color(0xFF0F766E), // Deep teal for others
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGridCard(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFF137333),
                    size: 16,
                  ),
                ),
                const Text(
                  'অগ্রগতি',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '৮৫%',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'প্রস্তুতি স্কোর (BCS)',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final isGridView = ref.watch(dashboardLayoutProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'সেরা ভাইভা',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          children: [
            // Layout switcher toggle button
            IconButton(
              onPressed: () {
                ref.read(dashboardLayoutProvider.notifier).state = !isGridView;
              },
              icon: Icon(
                isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: Colors.white,
                size: 20,
              ),
              tooltip: isGridView ? 'তালিকা ভিউ' : 'গ্রিড ভিউ',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                padding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              tooltip: 'লগআউট',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileWelcome() {
    return Row(
      children: [
        // Beautiful profile avatar placeholder
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'MC',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        
        // Welcome candidate details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'স্বাগতম, ভাইভা পরীক্ষার্থী',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'বিসিএস ও ব্যাংক চাকরিপ্রত্যাশী',
                style: TextStyle(
                  color: Color(0xFFCCFBF1), // soft pale teal
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }}

class _CurvedHeader extends StatelessWidget {
  const _CurvedHeader();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeaderPainter(),
    );
  }
}

class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double baseHeight = size.height - 60; // Leave 60 pixels for the card to overlap the boundary
    final rect = Offset.zero & Size(size.width, baseHeight);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F766E), // Deep Teal
          Color(0xFF0D9488), // Medium Teal
          Color(0xFF047857), // Emerald Green
        ],
      ).createShader(rect);

    // Draw curved/organic bottom for the green background itself!
    final path = Path();
    path.lineTo(0, baseHeight - 40);
    path.quadraticBezierTo(
      size.width * 0.3,
      baseHeight,
      size.width * 0.65,
      baseHeight - 25,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      baseHeight - 45,
      size.width,
      baseHeight - 15,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Dynamic wave curves inside header
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, baseHeight * 0.7);
    path1.quadraticBezierTo(size.width * 0.3, baseHeight * 0.9, size.width * 0.6, baseHeight * 0.75);
    path1.quadraticBezierTo(size.width * 0.85, baseHeight * 0.6, size.width, baseHeight * 0.8);
    path1.lineTo(size.width, baseHeight);
    path1.lineTo(0, baseHeight);
    path1.close();

    // Clip and draw wave
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path1, wavePaint);

    final path2 = Path();
    path2.moveTo(0, baseHeight * 0.85);
    path2.quadraticBezierTo(size.width * 0.5, baseHeight * 0.65, size.width, baseHeight * 0.9);
    path2.lineTo(size.width, baseHeight);
    path2.lineTo(0, baseHeight);
    path2.close();
    canvas.drawPath(path2, wavePaint..color = Colors.white.withOpacity(0.03));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PrepProgressCard extends StatelessWidget {
  const _PrepProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          // Circular progress arc
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ProgressArcPainter(
                      progress: 0.85,
                      color: const Color(0xFF0F766E),
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    '৮৫%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          
          // Analytics text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ভাইভা প্রস্তুতি সূচক',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'আপনার প্রস্তুতি সঠিক পথে এগোচ্ছে। ৩/৪ টি ক্ষেত্রে চমৎকার অগ্রগতি হয়েছে!',
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
    );
  }
}

class _ProgressArcPainter extends CustomPainter {
  _ProgressArcPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 4;
    
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: Text(
              actionLabel!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0F766E),
            ),
          ),
      ],
    );
  }
}

class _SliderItem {
  final String id;
  final String title;
  final String organization;
  final String publishDate;
  final String pdfUrl;
  final String fileSize;
  final String description;
  final bool isCircular;

  _SliderItem({
    required this.id,
    required this.title,
    required this.organization,
    required this.publishDate,
    required this.pdfUrl,
    required this.fileSize,
    required this.description,
    required this.isCircular,
  });
}

String _banglaToEnglish(String input) {
  const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String output = input;
  for (int i = 0; i < banglaDigits.length; i++) {
    output = output.replaceAll(banglaDigits[i], englishDigits[i]);
  }
  return output;
}

class _UpdatesSlider extends ConsumerWidget {
  const _UpdatesSlider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circularsAsync = ref.watch(jobCircularsProvider);
    final resultsAsync = ref.watch(jobResultsProvider);

    return circularsAsync.when(
      data: (circulars) {
        return resultsAsync.when(
          data: (results) {
            final List<_SliderItem> items = [];
            items.addAll(circulars.map((e) => _SliderItem(
              id: e.id,
              title: e.title,
              organization: e.organization,
              publishDate: e.publishDate,
              pdfUrl: e.pdfUrl,
              fileSize: e.fileSize,
              description: e.description,
              isCircular: true,
            )));
            items.addAll(results.map((e) => _SliderItem(
              id: e.id,
              title: e.title,
              organization: e.organization,
              publishDate: e.publishDate,
              pdfUrl: e.pdfUrl,
              fileSize: e.fileSize,
              description: e.description,
              isCircular: false,
            )));

            // Sort by date descending
            items.sort((a, b) {
              final dateA = _banglaToEnglish(a.publishDate);
              final dateB = _banglaToEnglish(b.publishDate);
              return dateB.compareTo(dateA);
            });

            if (items.isEmpty) {
              return Container(
                height: 155,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'কোন আপডেট পাওয়া যায়নি',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                padding: const EdgeInsets.only(right: 6),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _SliderCard(item: item);
                },
              ),
            );
          },
          loading: () => const _SliderSkeleton(),
          error: (err, stack) => const _SliderError(),
        );
      },
      loading: () => const _SliderSkeleton(),
      error: (err, stack) => const _SliderError(),
    );
  }
}

class _SliderCard extends StatefulWidget {
  const _SliderCard({required this.item});

  final _SliderItem item;

  @override
  State<_SliderCard> createState() => _SliderCardState();
}

class _SliderCardState extends State<_SliderCard> {
  double _scale = 1.0;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    
    // Solid Header Banner Styling (inspired bypremium model test look)
    final Color headerBgColor = item.isCircular 
        ? const Color(0xFF0F766E) // Solid Deep Teal
        : const Color(0xFFD97706); // Solid Bright Amber/Orange
    final String headerText = item.isCircular 
        ? '📰 সার্কুলার / বিজ্ঞপ্তি' 
        : '📢 পরীক্ষার ফলাফল আপডেট';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => PdfViewerPage(
                title: item.title,
                pdfUrl: item.pdfUrl,
                organization: item.organization,
                publishDate: item.publishDate,
              ),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            width: 270,
            margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered 
                    ? headerBgColor.withOpacity(0.3) 
                    : const Color(0xFFE2E8F0),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withOpacity(_isHovered ? 0.08 : 0.03),
                  blurRadius: _isHovered ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Solid Curved Category Header Banner
                  Container(
                    height: 34,
                    color: headerBgColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      headerText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 2. White Details Body
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => PdfViewerPage(
                                title: item.title,
                                pdfUrl: item.pdfUrl,
                                organization: item.organization,
                                publishDate: item.publishDate,
                              ),
                            ),
                          );
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Bold Title
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  height: 1.35,
                                ),
                              ),
                              // Bottom Row with Calendar, Organization & PDF Size
                              Row(
                                children: [
                                  const Icon(
                                    Icons.business_center_outlined,
                                    size: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      item.organization.split('(').first.trim(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    item.publishDate,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    size: 12,
                                    color: Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    item.fileSize,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderSkeleton extends StatelessWidget {
  const _SliderSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        padding: const EdgeInsets.only(right: 6),
        itemBuilder: (context, index) {
          return Container(
            width: 270,
            margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 55,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Container(
                      width: 70,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 180,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SliderError extends StatelessWidget {
  const _SliderError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: const Center(
        child: Text(
          'আপডেট লোড করতে ত্রুটি হয়েছে',
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
