# WTF Flutter Test

Two Flutter apps share a workspace package for models, repositories, services, providers, UI components, Drift cache setup, Firebase Firestore sync, and 100ms video-call integration. The apps are:

- `apps/guru_app`: member-side Guru app for DK.
- `apps/trainer_app`: trainer-side portal for Aarav.
- `token_server`: Node.js helper for 100ms room creation and auth-token generation.

## Quick Start

```bash
dart pub get
PATH="$PATH:$HOME/.pub-cache/bin" dart run melos bootstrap
PATH="$PATH:$HOME/.pub-cache/bin" dart run melos run analyze
cd packages/shared && flutter test
```

## Prerequisites

- Flutter >= 3.24.0
- Dart >= 3.6.0
- Node.js >= 18
- npm
- Firebase CLI
- FlutterFire CLI
- 100ms account with access key, secret, and roles `trainer` and `member`

## Firebase Setup

Placeholder `firebase_options.dart` files are committed so the apps compile. For real Firestore sync, run:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
firebase projects:create wtf-flutter-test --display-name "WTF Flutter Test"
```

Enable Firestore in test mode, then configure both apps:

```bash
cd apps/guru_app
flutterfire configure --project=wtf-flutter-test --platforms=android --android-package-name=com.wtf.guru_app --out=lib/firebase_options.dart
cd ../trainer_app
flutterfire configure --project=wtf-flutter-test --platforms=android --android-package-name=com.wtf.trainer_app --out=lib/firebase_options.dart
```

## Token Server Setup

```bash
cd token_server
npm install
cp .env.example .env
npm run dev
```

Set `HMS_ACCESS_KEY` and `HMS_SECRET` in `.env`. `POST /create-room` creates a 100ms room; `GET /token` returns a join token; `GET /health` verifies the service.

## Running Apps

```bash
cd apps/guru_app && flutter run
cd apps/trainer_app && flutter run
```

Guru starts with onboarding and DK profile setup. Trainer starts with mock login as Aarav.

## Architecture

See `ARCHITECTURE.md` for diagrams, layer rules, Firestore-to-Drift flow, Riverpod state, and 100ms lifecycle.

## Testing

```bash
PATH="$PATH:$HOME/.pub-cache/bin" dart run melos run analyze
cd packages/shared && flutter test
cd apps/guru_app && flutter test
cd apps/trainer_app && flutter test
```

## Demo Video Link

Placeholder: add the 3-minute walkthrough link after recording.
