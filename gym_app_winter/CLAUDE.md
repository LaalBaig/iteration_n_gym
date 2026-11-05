# CLAUDE.md

Flutter workout-tracking app (iPhone-only release target). Local-first: all data lives in a Drift/SQLite DB on device, no backend.

## Read these first

- **[PROJECT_STATE.md](PROJECT_STATE.md)** — what's built, in progress, known issues, backlog, DB schema reference. **Update it when work lands** (add a row to "Current Branch Work", bump "Last updated" + session number).
- **[CODEBASE_ROADMAP.md](CODEBASE_ROADMAP.md)** — architecture: `lib/` layout, route table, workout lifecycle, data flow.
- `../design.md` (outside this folder, next to the Figma mockups) — a reference design system. Not what the app currently implements; don't apply it unless asked.

The code is the source of truth. If a doc disagrees with the code, trust the code and fix the doc.

## Commands

```sh
flutter pub get
flutter analyze                    # baseline is ~13 infos/warnings, 0 errors — don't add new ones
flutter test                       # test/ — WorkoutManager, HistoryTile, widget smoke test
dart run build_runner build --delete-conflicting-outputs   # after ANY change to lib/database/database.dart
```

Adding a native plugin (e.g. notifications) needs a full cold rebuild, not hot restart.

## Repo layout gotcha

The git root is the **parent** directory (`iteration_n_gym/`), not this folder. Commit paths look like `gym_app_winter/lib/...`. `ios/build/` artifacts show up in `git status` — don't commit them.

## Architecture in one breath

- `lib/state/workout_manager.dart` — singleton `ChangeNotifier`, the brain of an active workout (start / log / minimize / finish → batch-writes to DB). Most workout-logic changes go here.
- `lib/database/database.dart` — Drift schema (currently **v12**) + all queries. `database_service.dart` exposes the singleton (`DatabaseService().db`). `database.g.dart` is generated — never hand-edit.
- `lib/navigation/app_router.dart` — every route. New screen = file in `lib/screens/` + route here.
- Screens read the DB directly via `StreamBuilder`/`FutureBuilder`; live session data comes from `WorkoutManager`.
- User prefs (theme, `userBodyweightKg`, `hasCompletedOnboarding`) live in `SharedPreferences`.

## Conventions

- **Colours:** use `Theme.of(context).colorScheme` and the `RestTimerTheme` extension (defined in `main.dart`). Every UI change must look right in **both light and dark mode** (dark is OLED black).
- **Sizing:** use `ResponsiveHelper` (`.w()`, `.h()`, `.sp()`) — design base is 390×844. It's safe to call without `init()` (returns identity), so widget tests can pump leaf widgets directly.
- **Volume:** always compute via `calcSetVolume()` in `lib/utils/volume_utils.dart` — bodyweight exercises add the user's bodyweight. Raw `reps * weight` is a known past bug.
- **Exercise variants:** weighted / bodyweight / timed (`LogSetCardVariant`). Features touching sets usually need a branch for each — check all three.
- **Set data maps** are `Map<String, dynamic>` (they carry notes), not `Map<String, int>`.
- **Schema change:** edit tables → bump `schemaVersion` → add a migration step in `onUpgrade` → run build_runner → update the schema table in PROJECT_STATE.md.
- Commits use conventional prefixes (`feat:`, `fix:`, `chore:`) with a body explaining the why.

## Known traps

- `ExerciseLogs` joins to exercises by **`exerciseName` string**, not FK. Renaming/deleting an exercise breaks history unless handled — permanent delete relabels logs to `"[Name] (Deleted)"`.
- Exercise visibility uses two flags: `isDeleted` + `isTracked`. "Recently Deleted" = `isDeleted && isTracked`; `isDeleted && !isTracked` is a hidden limbo state. Get this wrong and duplicate-name checks misfire.
- Timed sets: only mark `isCompleted` when duration ≥ 1000 ms, or zero-length sets leak into the DB.
- Exercise metadata (`exerciseType`/`trackingType`) can be null on old rows; `backfillExerciseMetadata()` repairs at startup — preserve that path.
