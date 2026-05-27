# WTF Gym Flutter Platform

A Flutter monorepo containing two production-style applications with shared architecture, offline-first caching, Firestore synchronization, and realtime 100ms video-call integration.

## Applications

### `apps/guru_app`
Member-side Guru application for DK.

Features:
- onboarding flow
- profile setup
- scheduling
- chat
- session tracking
- realtime video sessions

### `apps/trainer_app`
Trainer-side portal for Aarav.

Features:
- trainer dashboard
- CRM/session management
- scheduling
- member interaction
- realtime video sessions

### `packages/shared`
Shared workspace package containing:
- models
- repositories
- Riverpod providers
- services
- Drift database/cache
- shared UI components
- Firestore sync logic
- 100ms integration utilities

### `token_server`
Node.js helper service for:
- 100ms room creation
- auth token generation
- room lifecycle support

---

# Tech Stack

- Flutter
- Dart
- Riverpod
- Drift (offline cache)
- Firebase Firestore
- 100ms Video SDK
- Melos Monorepo
- Node.js / Express

---

# Project Structure

```text
apps/
  guru_app/
  trainer_app/

packages/
  shared/

token_server/
```

---

# Prerequisites

- Flutter >= 3.24.0
- Dart >= 3.6.0
- Node.js >= 18
- npm
- Firebase CLI
- FlutterFire CLI

---

# Quick Start

## Install Dependencies

```bash
dart pub get
dart run melos bootstrap
```

## Analyze Project

```bash
dart run melos run analyze
```

## Run Shared Tests

```bash
cd packages/shared
flutter test
```

---

# Firebase Setup

Placeholder `firebase_options.dart` files are included so the apps compile successfully.

To enable real Firestore synchronization:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli

firebase login
firebase projects:create wtf-flutter-test --display-name "WTF Flutter Test"
```

Enable Firestore in test mode.

Then configure both apps:

```bash
cd apps/guru_app

flutterfire configure \
  --project=wtf-flutter-test \
  --platforms=android \
  --android-package-name=com.wtf.guru_app \
  --out=lib/firebase_options.dart
```

```bash
cd apps/trainer_app

flutterfire configure \
  --project=wtf-flutter-test \
  --platforms=android \
  --android-package-name=com.wtf.trainer_app \
  --out=lib/firebase_options.dart
```

---

# Token Server Setup

```bash
cd token_server

npm install
cp .env.example .env
npm run dev
```

Add the following values to `.env`:

```env
HMS_ACCESS_KEY=
HMS_SECRET=
```

Available endpoints:

- `POST /create-room`
- `GET /token`
- `GET /health`

---

# Running the Applications

## Guru App

```bash
cd apps/guru_app
flutter run
```

## Trainer App

```bash
cd apps/trainer_app
flutter run
```

---

# Testing

```bash
dart run melos run analyze
```

```bash
cd packages/shared
flutter test
```

```bash
cd apps/guru_app
flutter test
```

```bash
cd apps/trainer_app
flutter test
```

---

# Architecture

See:
- `ARCHITECTURE.md`
- `DECISIONS.md`
- `AI_LEDGER.md`

for architecture diagrams, design decisions, state management flow, and implementation notes.

---

# Notes

- Placeholder Firebase configuration is intentionally committed for compilation/demo purposes.
- Some post-call 100ms flows are partially implemented.
- Designed as a scalable Flutter monorepo architecture assessment.