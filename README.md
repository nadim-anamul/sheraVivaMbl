# Sera Viva (Flutter Android)

Sera Viva is a Bangladeshi job mock viva platform. This repository contains a clean-architecture Flutter app baseline for Android, with demo-mode data and auth to validate UX and flows before wiring production APIs.

## Project Status

### Completed
- Flutter project scaffold with Android + Web support.
- Material 3 app shell and centralized theming.
- Riverpod-based state management.
- GoRouter navigation with auth-aware route redirect.
- Dashboard UI with requested 3 rows/cards:
	- Viva: AI Conversation, Live Viva, Report & Analysis
	- Library: Viva Library, Viva Advice, Viva Rules
	- Archive: Your Viva History
- Viva Form feature (Exam Type, Cadre Choice, Home District) with validation and submit flow.
- Authentication layer skeleton (email/password + JWT-ready contracts) with demo login support.
- LiveKit integration boundaries/placeholders for AI Conversation and Live Viva modules.
- Android permissions configured in main manifest:
	- INTERNET
	- CAMERA
	- RECORD_AUDIO
- Demo content implemented for:
	- Viva Library
	- Viva Advice
	- Viva Rules
- Tooling and quality baseline:
	- strict analysis options
	- passing analyzer (lib/test scope)
	- passing tests

### Remaining
- Replace demo/mock API calls with real Next.js endpoint integration.
- Finalize DTO request/response models per backend contract.
- Add token refresh/expiry handling from real backend behavior.
- Integrate real LiveKit SDK operations (room connect/disconnect, media track controls).
- Implement runtime permission flow with a plugin (currently preflight is placeholder logic).
- Add richer test coverage (unit/widget/integration) for all core feature paths.

## How The Project Works

### Architecture
Feature-first, clean architecture layering:
- presentation: UI pages, widgets, state/controllers
- domain: entities, repository contracts, use-cases
- data: datasource and repository implementations

Core shared layers:
- app: app entry composition, router, theme
- core: network client/config, result/error contracts
- shared: reusable UI primitives

### High-Level Flow
1. App boots with Riverpod ProviderScope.
2. Router starts on login route and redirects based on auth state.
3. User logs in with demo credentials.
4. Dashboard opens and routes to feature modules.
5. Viva Form validates and submits through repository/use-case boundary.
6. Live Viva / AI Conversation screens call placeholder LiveKit gateway methods.

## Folder Structure (Main)

```text
lib/
	app/
		app.dart
		router/app_router.dart
		theme/app_theme.dart
	core/
		errors/failure.dart
		network/{api_client.dart, api_config.dart, network_providers.dart}
		result/result.dart
	features/
		auth/
		dashboard/
		viva_form/
		library/
		live_viva/
		ai_conversation/
		report/
		archive/
	shared/
		presentation/widgets/placeholder_page.dart
	main.dart
```

## Demo Credentials
- Email: demo@seraviva.com
- Password: 123456

## Setup & Run

### Prerequisites
- Flutter stable (Dart bundled)
- Android SDK (for Android run)
- Chrome (for quick web smoke test)

### Install dependencies
```bash
flutter pub get
```

### Quality checks
```bash
flutter analyze lib test
flutter test
```

### Run on web (quick test)
```bash
flutter run -d chrome
```

### Run on Android device/emulator
```bash
flutter devices
flutter run -d <android-device-id>
```

## Key Files
- App entry: lib/main.dart
- App shell: lib/app/app.dart
- Router: lib/app/router/app_router.dart
- Dashboard: lib/features/dashboard/presentation/pages/dashboard_page.dart
- Viva Form page: lib/features/viva_form/presentation/pages/viva_form_page.dart
- Auth providers/controller: lib/features/auth/presentation/providers/auth_providers.dart
- Demo library pages:
	- lib/features/library/presentation/pages/viva_library_page.dart
	- lib/features/library/presentation/pages/viva_advice_page.dart
	- lib/features/library/presentation/pages/viva_rules_page.dart
- Android manifest permissions: android/app/src/main/AndroidManifest.xml

## API Integration Handoff
When backend endpoints are ready, replace placeholders in:
- lib/core/network/api_config.dart
- lib/features/auth/data/datasources/auth_remote_datasource.dart
- lib/features/viva_form/data/repositories/viva_form_repository_impl.dart

Reference:
- docs/API_CONTRACT_PLACEHOLDER.md
- docs/DEMO_TESTING.md
