# Architecture Decision Records

## ADR #1: State Management -> Riverpod

Context: Both apps need reactive cross-widget state for auth, chat streams, schedule requests, sessions, and call state.

Options: Bloc, Provider, GetX, Riverpod.

Decision: Use Riverpod 3.3 with generated providers where provider families and notifiers are useful.

Rationale: Riverpod is compile-safe, testable, independent from `BuildContext`, and fits a shared package used by two apps.

Consequences: Build runner is required for generated providers. New contributors need basic Riverpod familiarity.

## ADR #2: Storage -> Drift + Firebase

Context: Two separate apps need shared data while still keeping a local-first cache strategy.

Options: Hive, Isar, SharedPreferences, Drift, Firebase-only.

Decision: Use Firestore for cross-app sync and Drift for local cache tables.

Rationale: Mobile OS sandboxing prevents two independent apps from sharing one local SQLite file. Firestore provides real-time sync across both apps. Drift provides typed tables and reactive local streams.

Consequences: The storage layer is more complex than Firebase-only, but it supports local resilience and a clean repository boundary.

## ADR #3: RTC Strategy -> 100ms Room Codes

Context: The assessment requires 100ms video calling with trainer/member roles and minimal backend work.

Options: Token server for every join, room codes, embedded static tokens.

Decision: Use room codes for client joins and a Node token server for room creation and token fallback.

Rationale: Room-code auth is the recommended developer flow in the 100ms Flutter SDK. It reduces runtime dependency on our server during joins while keeping a server path for room creation.

Consequences: Production would harden token issuance, room-code storage, auth rules, and 100ms dashboard templates.
