# CLAUDE.md — Python Quiz (Flutter)

Guidance for Claude Code working in this repository. Read this first.

## What this project is

A configurable, fully offline mobile quiz app built in Flutter. Quiz content is
data-driven from a bundled JSON asset, so the same app can become a quiz for any
topic by swapping the JSON plus a small compile-time config. Currently themed as
a **Python programming quiz**. It's a companion to YouTube tutorials and a
portfolio piece; the immediate goal is to publish it to **Google Play** as a
full end-to-end deploy dry-run.

Owner: Marko Buhovac (Nov Inicium SRL). Local dev on macOS, Flutter stable.
No backend — everything runs on-device, questions ship as an asset.

## Tech stack

- Flutter 3.44.x stable / Dart 3.12.x, Material 3.
- State: plain Dart classes + `setState` + `FutureBuilder`. No external state
  management library.
- Persistence: `shared_preferences`.
- Sharing: `share_plus`.
- Lints: `flutter_lints` via `analysis_options.yaml`.

## Commands

- Run: `flutter run` (choose a device)
- Static analysis: `flutter analyze` — must stay clean (currently "No issues found")
- Tests: `flutter test`
- Format: `dart format .`
- Release bundle for Play: `flutter build appbundle`
  (output: `build/app/outputs/bundle/release/app-release.aab`)

After any change, run `flutter analyze` and `flutter test` and keep both green.
Work one file at a time and verify after each step before moving on.

## Architecture (`lib/`)

- `config/` — compile-time app identity + category list.
  - `quiz_config.dart`: the `QuizConfig` type (appTitle, masteryTitle,
    beginnerTitle, quizSubjectName, categories).
  - `app_quiz_config.dart`: the single `appQuizConfig` instance. **This is the
    "which topic" switch** — re-theme the whole app by editing this.
- `domain/` — game logic, no Flutter imports (pure Dart, unit-testable).
  - `level_rules.dart`: 3 levels, 9 questions each, pass threshold 8.
  - `quiz_engine.dart`: `QuizEngine` state machine — `start → answer →
    nextQuestion → finish`.
  - `quiz_state.dart`: immutable `QuizState` (copyWith) + `QuizResult`.
- `models/`
  - `question.dart`: `Question` + `QuestionBank` (JSON parsing lives here).
  - `quiz_category.dart`: `QuizCategory`.
  - `app_progress.dart`: `AppProgress` (persisted progress + derived getters).
- `services/`
  - `question_loader.dart`: loads the JSON asset via `rootBundle`.
    **Path is hardcoded to `assets/questions/jerry.json`.**
  - `question_repository.dart`: caches the bank, validates on load,
    `forGame(level, categoryId, count)` shuffles + takes N.
  - `question_validator.dart`: per-question validation (see Data contract).
  - `progress_service.dart` / `progress_store.dart`: progress logic +
    `shared_preferences` read/write.
  - `share_text_builder.dart`: builds the share string from a `QuizResult`.
- `screens/` — `home`, `quiz`, `result`, `debug_questions` (dev-only diagnostics).
- `widgets/` — `answer_button`, `explanation_card`, `progress_bar`, `question_card`.

## Data contract (the quiz JSON)

Asset shape (`assets/questions/*.json`):

```
{
  "version": 1,
  "categories": [ { "id": 1, "title": "...", "description": "..." }, ... ],
  "questions": [ { ...Question... }, ... ]
}
```

`Question` fields: `id` (string, e.g. "C1-L1-01"), `categoryId` (1–5),
`level` (1–3), `type` (free string, e.g. concept/syntax), `questionFormat`
("text" | "code"), `question`, `codeLanguage`, `codeSnippet` (required when
`questionFormat == "code"`), `choices` (exactly 4), `correctIndex` (0–3),
`tags` (string[]), `sourceRef`, `explanation`, `migrationNotes` (present in the
JSON but currently ignored by the model).

Validator rules (`question_validator.dart`): non-empty id, categoryId 1–5,
level 1–3, non-empty question, format text|code, code questions need a
codeSnippet, exactly 4 non-empty choices, correctIndex 0–3.

Content requirement: `forGame` needs **at least 9 questions per (level,
category)** pair or it throws `StateError('Not enough questions ...')`. With
5 categories × 3 levels that is a minimum of 135 valid questions for full
coverage.

**Mismatch to be aware of:** `QuestionBank.fromJson` reads only `version` and
`questions`. The JSON's `categories` array is NOT read — categories come from
the compile-time `appQuizConfig`. Categories are therefore defined in two
places today. If extending the "any topic from JSON" goal, prefer sourcing
categories from the JSON too.

## Naming — currently inconsistent (clean up before publishing)

The app carries leftover names from an earlier "Seinfeld" version, and they do
not all agree:

- pubspec `name`: `novinicium_python_quiz`
- `appQuizConfig.appTitle` / MaterialApp title: "Python Quiz"
- Home screen AppBar + hero heading: hardcoded "CodeMind"
- Android `applicationId` & `namespace`: `com.example.seinfeld_quiz`
- Android `android:label`: "seinfeld_quiz"
- Quiz asset file: `assets/questions/jerry.json`

Pick one product name and align all of these before the first Play Store upload.

## Google Play readiness — blockers & TODO (in order)

1. **applicationId** — `com.example.*` is rejected by Google Play. Set a final,
   unique id (e.g. `be.novinicium.pythonquiz`). It CANNOT change after the first
   publish. Update `namespace`, the Kotlin package directory, and `android:label`
   to match.
2. **Release signing** — release currently signs with the debug key
   (`signingConfig = signingConfigs.getByName("debug")`). Create an upload
   keystore, wire a `key.properties`-based release `signingConfig`, and enable
   Play App Signing. Never commit the keystore or `key.properties` (add to
   `.gitignore`).
3. **App icon** — still the default Flutter launcher icon. Replace before publishing.
4. **App display name** — set the real name in `android:label`.
5. **versionCode** must increase on every upload; pubspec `version: x.y.z+build`
   drives it.
6. **Target API level** — confirm `flutter.targetSdkVersion` meets Google Play's
   current minimum target before building the release bundle.
7. **Privacy policy + Data safety form** — Play requires both. This app stores
   only local progress (`shared_preferences`), makes no network calls, and
   collects no personal data — reflect that accurately.
8. **Closed-testing gate** — a new *personal* Play developer account needs
   12 opted-in testers for 14 continuous days before production access. Publishing
   under the SRL as an *organization* account waives this.

## Known small issues / dead code (safe to fix)

- `share_text_builder.dart` branches on `result.level == 5`, but levels are only
  1–3 — that mastery string never fires. Mastery actually unlocks on passing
  level 3 (`fanMasterUnlocked`).
- Level labels disagree: `LevelRules.label` says "Medium" for level 2;
  `home_screen._levelLabel` says "Intermediate". Pick one.
- `home_screen._completedLevelsCount` contains a no-op line `total = total;`.
- `.DS_Store` files are tracked under `assets/` despite being in `.gitignore` —
  `git rm --cached` them.
- `question_loader.dart` path is hardcoded to `jerry.json`; rename the asset
  (e.g. `questions.json`) and/or make it config-driven to match the "any topic"
  design.

## Conventions & working style

- Implement one file at a time; verify (`flutter analyze` + relevant test) after
  each step before continuing.
- Prefer simple, pragmatic solutions over clever abstractions.
- Keep `domain/` free of Flutter imports (pure Dart, unit-testable).
- Keep `flutter analyze` at zero issues.
- Never commit secrets (keystore, `key.properties`, credentials).
- Ask before large refactors or renames that touch many files at once.