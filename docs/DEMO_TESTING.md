# Demo Testing Guide

Use this demo mode now, then replace API contracts later.

## Demo Login
- Email: demo@seraviva.com
- Password: 123456

## Current Demo Coverage
- Auth flow (login/logout/session restore scaffold)
- Dashboard navigation cards
- Viva Form validation and submit success flow
- Live Viva placeholder start action
- AI Conversation placeholder start action

## Run Commands
```bash
flutter pub get
flutter analyze lib test
flutter test
flutter run -d chrome
```

For Android (when emulator/device is available):
```bash
flutter run -d <android-device-id>
```

## Next API Integration Step
Replace placeholder endpoints and DTO mapping in:
- lib/core/network/api_config.dart
- lib/features/auth/data/datasources/auth_remote_datasource.dart
- lib/features/viva_form/data/repositories/viva_form_repository_impl.dart

Reference contract checklist:
- docs/API_CONTRACT_PLACEHOLDER.md
