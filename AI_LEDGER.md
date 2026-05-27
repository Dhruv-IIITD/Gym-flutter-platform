# AI Ledger - WTF Flutter Assessment

## Summary

Total AI-assisted entries: 10
Tools used: Codex, local analyzer, build_runner

## Entries

### Prompt #1
- **Category**: Architecture
- **Intent**: Scaffold a Flutter monorepo with a shared package and two apps.
- **Output snippet**: `workspace: packages/shared, apps/guru_app, apps/trainer_app`
- **Commit**: `chore: initial project scaffolding with monorepo and shared package`

### Prompt #2
- **Category**: Coding
- **Intent**: Generate JSON models for user, message, call request, room metadata, and session log.
- **Output snippet**: `@JsonSerializable() class Message`
- **Commit**: `chore: initial project scaffolding with monorepo and shared package`

### Prompt #3
- **Category**: Coding
- **Intent**: Build mock auth, SharedPreferences persistence, and seeded trainer data.
- **Output snippet**: `AuthService.login(...)`
- **Commit**: `feat(auth): auth flow and onboarding for both apps`

### Prompt #4
- **Category**: Coding
- **Intent**: Create real-time chat repository and Riverpod chat actions.
- **Output snippet**: `watchMessages(chatId).snapshots()`
- **Commit**: `feat(chat): real-time chat with status indicators and typing`

### Prompt #5
- **Category**: UI
- **Intent**: Implement chat list, bubbles, quick replies, read ticks, and typing indicator.
- **Output snippet**: `ConversationScreen(chatId: ...)`
- **Commit**: `feat(chat): real-time chat with status indicators and typing`

### Prompt #6
- **Category**: Coding
- **Intent**: Create scheduling repository, service, conflict checks, and request screens.
- **Output snippet**: `ScheduleService.generateTimeSlots`
- **Commit**: `feat(schedule): call scheduling with conflict checks and system messages`

### Prompt #7
- **Category**: Coding
- **Intent**: Wrap 100ms SDK callbacks and expose call state to the UI.
- **Output snippet**: `class CallService implements HMSUpdateListener`
- **Commit**: `feat(rtc): 100ms video calling with pre-join and controls`

### Prompt #8
- **Category**: UI
- **Intent**: Create pre-join, in-call controls, and post-call sheets.
- **Output snippet**: `PreJoinScreen(roomCode: ...)`
- **Commit**: `feat(rtc): 100ms video calling with pre-join and controls`

### Prompt #9
- **Category**: Testing
- **Intent**: Add model serialization and validation unit tests.
- **Output snippet**: `expect(restored.status, MessageStatus.sent)`
- **Commit**: `test: unit tests for models and validation`

### Prompt #10
- **Category**: Documentation
- **Intent**: Finalize README, architecture notes, ADRs, and AI ledger.
- **Output snippet**: `ADR #2: Storage -> Drift + Firebase`
- **Commit**: `docs: finalize architecture, decisions, and AI ledger`
