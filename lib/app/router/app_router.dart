import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_conversation/presentation/pages/ai_conversation_page.dart';
import '../../features/archive/presentation/pages/viva_history_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/library/presentation/pages/job_updates_page.dart';
import '../../features/library/presentation/pages/viva_advice_page.dart';
import '../../features/library/presentation/pages/viva_library_page.dart';
import '../../features/library/presentation/pages/viva_rules_page.dart';
import '../../features/live_viva/presentation/pages/live_viva_page.dart';
import '../../features/report/presentation/pages/report_analysis_page.dart';
import '../../features/viva_form/presentation/pages/viva_form_page.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const vivaForm = '/viva-form';
  static const aiConversation = '/ai-conversation';
  static const liveViva = '/live-viva';
  static const reportAnalysis = '/report-analysis';
  static const vivaLibrary = '/viva-library';
  static const vivaAdvice = '/viva-advice';
  static const vivaRules = '/viva-rules';
  static const vivaHistory = '/viva-history';
  static const jobUpdates = '/job-updates';
}

final appRouterProvider = Provider<GoRouter>((Ref ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLogin = state.fullPath == AppRoutes.login;

      if (!isAuthenticated && !isLogin) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isLogin) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShellLayout(
            state: state,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.vivaForm,
            builder: (context, state) => const VivaFormPage(),
          ),
          GoRoute(
            path: AppRoutes.aiConversation,
            builder: (context, state) => const AIConversationPage(),
          ),
          GoRoute(
            path: AppRoutes.liveViva,
            builder: (context, state) => const LiveVivaPage(),
          ),
          GoRoute(
            path: AppRoutes.reportAnalysis,
            builder: (context, state) => const ReportAnalysisPage(),
          ),
          GoRoute(
            path: AppRoutes.vivaLibrary,
            builder: (context, state) => const VivaLibraryPage(),
          ),
          GoRoute(
            path: AppRoutes.vivaAdvice,
            builder: (context, state) => const VivaAdvicePage(),
          ),
          GoRoute(
            path: AppRoutes.vivaRules,
            builder: (context, state) => const VivaRulesPage(),
          ),
          GoRoute(
            path: AppRoutes.vivaHistory,
            builder: (context, state) => const VivaHistoryPage(),
          ),
          GoRoute(
            path: AppRoutes.jobUpdates,
            builder: (context, state) => const JobUpdatesPage(),
          ),
        ],
      ),
    ],
  );
});

class MainShellLayout extends StatelessWidget {
  const MainShellLayout({
    required this.child,
    required this.state,
    super.key,
  });

  final Widget child;
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    final location = state.uri.path;
    
    // Determine active index based on route location path
    int activeIndex = 0;
    if (location == AppRoutes.dashboard) {
      activeIndex = 0;
    } else if (location == AppRoutes.aiConversation) {
      activeIndex = 1;
    } else if (location == AppRoutes.liveViva) {
      activeIndex = 2;
    } else if (location == AppRoutes.vivaLibrary || location == AppRoutes.vivaAdvice || location == AppRoutes.vivaRules || location == AppRoutes.jobUpdates) {
      activeIndex = 3;
    } else if (location == AppRoutes.reportAnalysis || location == AppRoutes.vivaHistory) {
      activeIndex = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context, activeIndex),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int activeIndex) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        height: 66,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              context: context,
              icon: Icons.home_rounded,
              label: 'হোম',
              isActive: activeIndex == 0,
              onTap: () => context.go(AppRoutes.dashboard),
            ),
            _buildBottomNavItem(
              context: context,
              icon: Icons.smart_toy_rounded,
              label: 'এআই ভাইভা',
              isActive: activeIndex == 1,
              onTap: () => context.go(AppRoutes.aiConversation),
            ),
            _buildBottomNavItem(
              context: context,
              icon: Icons.videocam_rounded,
              label: 'লাইভ ভাইভা',
              isActive: activeIndex == 2,
              onTap: () => context.go(AppRoutes.liveViva),
              hasLiveBadge: true,
            ),
            _buildBottomNavItem(
              context: context,
              icon: Icons.menu_book_rounded,
              label: 'লাইব্রেরি',
              isActive: activeIndex == 3,
              onTap: () => context.go(AppRoutes.vivaLibrary),
            ),
            _buildBottomNavItem(
              context: context,
              icon: Icons.analytics_rounded,
              label: 'রিপোর্ট',
              isActive: activeIndex == 4,
              onTap: () => context.go(AppRoutes.reportAnalysis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool hasLiveBadge = false,
  }) {
    final Color activeColor = const Color(0xFF0F766E); // Deep Teal
    final Color inactiveColor = const Color(0xFF94A3B8); // Cool Slate

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isActive ? activeColor : inactiveColor,
                    size: 24,
                  ),
                  if (hasLiveBadge)
                    Positioned(
                      top: -2,
                      right: -3,
                      child: Container(
                        height: 7,
                        width: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444), // Bright red dot
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : inactiveColor,
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
