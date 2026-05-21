import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_conversation/presentation/pages/ai_conversation_page.dart';
import '../../features/archive/presentation/pages/viva_history_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
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
    ],
  );
});
