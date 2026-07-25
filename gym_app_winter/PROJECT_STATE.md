# Project State — gym_app_winter

> Last updated: 2026-07-25 (session 14)
> Branch: `vibecode-supreme` | Version: `1.0.1+2` | DB schema: v12

---

## What this file is

A living tracker of what's been built, what's in progress, and what's planned. Update it as work lands. It is not an architecture reference — see `CODEBASE_ROADMAP.md` for that.

---

## Current Branch Work (`vibecode-supreme`)

| Area | Status | Notes |
|---|---|---|
| Stats dashboard — modular insight widgets | ✅ Done | `personal_records_card`, `top_exercises_card`, `muscle_group_focus_card`, `muscle_volume_heatmap`, `progress_chart` |
| Time column in `ExerciseLogs` schema (v11 migration) | ✅ Done | Migration moves timed exercise data from `weight` to `time` column |
| `shared_preferences` plugin registered | ✅ Done | Used for theme persistence in `main.dart` |
| Custom exercise creation — bug fixes | ✅ Done | 7 bugs fixed: dead route (`/add` → `/add_exercise`), stale `exerciseType` on Time-based toggle, `_isSaving` not reset on success, `maxLength: 50` on name field, soft-deleted name bypass warning, ID collision (`ms + random`), perf (targeted query + cached JSON) |
| Custom exercise creation — soft-delete collision fix | ✅ Done | `isSoftDeleted` check was matching `isDeleted=true, isTracked=false` (hidden limbo state) — fixed to require `isTracked=true` to match what's actually visible in Recently Deleted |
| Custom exercise delete — two-step choice dialog | ✅ Done | Replaces generic "Are you sure?" for custom exercises. First dialog: "Remove from catalogue" (soft-delete → Recently Deleted, history intact) or "Delete permanently". Permanent path shows a second dialog explaining logs will be relabelled `"[Name] (Deleted)"`. `ExerciseTile` gained `onSoftDelete` callback; `add_exercise_screen` wires both paths. |
| Responsive sizing system | ✅ Done | `ResponsiveHelper` applied across UI; theme constants updated |
| Auto-scroll for newly added exercises | ✅ Done | Active workout + routine screens |
| UI colour consistency pass | ✅ Done | "Add Exercise" button aligned to `WorkoutButtonTop` style (`primary`/`onPrimary`, `elevation: 0`, `cornerRadius: 12`). Routine tile play button switched to tonal `primaryContainer`/`primary` to match icon badges. Dark mode backgrounds made OLED black: `AppColors.backgroundGrey` → `0xFF000000`; `workout_page.dart` scaffold fixed from `surfaceWhite` to `scaffoldBackgroundColor`. |
| Haptic feedback — Start New Workout | ✅ Done | `HapticFeedback.mediumImpact()` on the main `WorkoutButtonTop` tap and the "Start new workout" button inside the active-workout conflict dialog (`workout_button_top.dart`). |
| Splash screen logo + animation polish | ✅ Done | Replaced generic icon with `app_icon_nobg.png` (light) / `app_icon_nobg_white.png` (dark). Removed title text, tagline, and pulse dots. Added mirrored exit animation: `easeInBack` scale-down + fade-out before navigating. |
| Active workout Settings button — Coming Soon placeholder | ✅ Done | Both Settings button instances in `active_workout_screen.dart` now open a modal bottom sheet with a "Coming Soon" message instead of doing nothing. |
| Onboarding flow — name + bodyweight + welcome | ✅ Done | 3-step PageView (`onboarding_screen.dart`): name (with shake+red-border error on empty) → bodyweight in kg (with back button) → animated welcome screen (staggered icon/glow/text entrance, pulsing glow ring, "Start Training" CTA). Shown once on first launch (`hasCompletedOnboarding` pref). Splash routes to `/onboarding` or `/`. Profile tab gains Bodyweight row (`userBodyweightKg` double pref, editable). Profile Danger Zone gains "Reset Onboarding" row for testing. |
| Bodyweight exercise volume calc | ✅ Done | `calcSetVolume()` utility in `lib/utils/volume_utils.dart`. Formula: `(bodyweightKg + additionalWeight) × reps` for bodyweight exercises. Applied to `WorkoutManager.totalVolume` (loads bw from prefs on `startWorkout`), `WorkoutSummaryCard`, `TopExercisesCard`, `MuscleVolumeHeatmap`, and Weekly Volume Trend bars in `StatsTab` (converted to `StatefulWidget`, loads bw in `initState`). |
| Exercise notes (per exercise, per session) | ✅ Done | `notes` nullable TEXT column in `ExerciseLogs` (schema v12). One note per exercise per workout (not per set). Tappable "Add note..." row in `LogSetCard` header (active workout only); opens bottom sheet (200-char, Save/Clear). `WorkoutManager` stores notes in `_exerciseNotes: Map<String, String>` — cleared on start/discard/finish, transferred on replace. Note written to set 1's `notes` column in DB. Displayed in: workout history screen (inline under each exercise's sets line) and exercise history `HistoryTile` (italic + notes icon below sets, capped at 2 lines). History tile height bumped to 280. Set data maps changed from `Map<String, int>` to `Map<String, dynamic>` throughout. |
| Rest timer notification | ✅ Done | `flutter_local_notifications ^22.0.1` added. `NotificationService` singleton (`lib/services/notification_service.dart`) initialized in `main()`. Fires local push notification on timer completion alongside existing haptic + snackbar. Android: `POST_NOTIFICATIONS` permission in manifest + runtime request for API 33+. iOS: permission requested on first launch via `DarwinInitializationSettings`. Requires full cold build (not hot restart) after adding the plugin. ⚠️ Needs finetuning — see Known Issues. |
| Rest timer button UI wobble | ✅ Done | Label wrapped in `SizedBox(width: 36)` with `FontFeature.tabularFigures()` and `textAlign: center`. Button no longer resizes when switching between "Rest" and time display, and digit widths are stable as the countdown changes. |
| Workout history — minimized-by-default cards | ✅ Done | `workout_history_screen.dart` refactored: per-item `Container` extracted into a new `_WorkoutHistoryCard` `StatefulWidget` with local `_expanded` state, defaulting to `false`. Header (date/time/duration) is always visible and tappable to toggle; a rotating chevron indicates state. Full exercise/set breakdown (previously always rendered) now lives inside an `AnimatedSize` that only builds when expanded. Delete icon still works independently via its own `GestureDetector`. |
| Export workout history (CSV/JSON) | ✅ Done | New "DATA" section in `profile_tab.dart` → "Export Workout History" row → `/export_history` route (`export_history_screen.dart`). Flow: scope (All Workouts vs. Specific Exercise, with a searchable bottom-sheet exercise picker) → format (CSV/JSON) → "Export & Share" triggers `lib/services/export_service.dart`, which builds the file from `watchAllLogsWithWorkoutAndExercise()` and hands it to the native share sheet via `share_plus`. CSV uses the `csv` package (`Csv().encode(...)`, `\r\n` line endings) for correct quoting/escaping of notes; JSON nests sets under exercises under workouts. File written to a temp dir via `path_provider` before sharing. New deps: `path_provider`, `share_plus`, `csv`. |
| `LogSetCard` set-row delete affordance | ✅ Done | Swipe-to-delete on a set row wasn't discoverable, so a visible delete control was added. Landed in two iterations: first a three-dot menu (mark complete/incomplete + delete), then simplified per feedback — weighted/bodyweight rows now show a plain `remove_circle_outline` icon in `colorScheme.primary` (trailing column, sets after the first only) that deletes on tap; manual "mark as complete" toggle was removed entirely for these variants (`_SetData.isCompleted` no longer has a UI control — `WorkoutManager._isSetLogged` already falls back to checking weight/reps/time > 0, so nothing downstream broke). Timed rows keep their play/stop button (drives the stopwatch, couldn't be replaced) and get the same minus button placed under the set number instead. Leading number/PR column factored into shared `_buildSetNumberColumn`; delete button factored into `_buildRemoveSetButton`. |
| Bodyweight exercises missing from weekly volume — bug fix | ✅ Done | Root cause: `WorkoutManager.finishWorkout()` re-saved an existing exercise's DB row using its *own* stored `exerciseType`/`trackingType` instead of the active session's — so any exercise first logged before that metadata existed (or otherwise saved null) stayed `null` forever, making `calcSetVolume` treat it as a plain weighted exercise (volume = 0 for sets with no added weight). Fixed in two parts: (1) `finishWorkout()` now backfills from the active session's exercise when the existing value is null. (2) `AppDatabase.backfillExerciseMetadata()` (new, `database.dart`) does a one-time repair pass over all `Exercises` rows with null `exerciseType`/`trackingType`, matching by name against `assets/exercises.json`; run once at startup via `main.dart` (fire-and-forget, same pattern as notification init) so already-logged exercises self-correct without needing to be re-logged. |
| Stats tab — dynamic font sizing for large numbers | ✅ Done | `WorkoutSummaryCard`'s `_StatItem` value text (Volume/Heaviest/Average/etc.) wrapped in a `FittedBox(fit: BoxFit.scaleDown)` so the font shrinks to fit instead of clipping/overflowing when weight/volume numbers grow more digits. |
| Exercise page progress chart — dark mode contrast fixes | ✅ Done | `progress_chart.dart`: (1) Metric/timeframe dropdown chevrons were hardcoded to `brandPrimary` (pure black), invisible against the dark card — now `iconEnabledColor` switches to `0xFF9F92EC` (the existing dark-mode dropdown text purple) when `isDark`. (2) Tap-to-view datapoint tooltip used fl_chart's default `Colors.blueGrey.darken(15)` background with brand-purple text — both mid/dark tones, poor contrast in both themes. Now sets explicit `getTooltipColor` (near-black `0xFF3A3A3A` in dark mode, white in light mode) with white/near-black (`0xFF111111`) text respectively. |
| Exercise page progress chart — bodyweight volume bug + irrelevant "Time" metric | ✅ Done | `ProgressChart` previously computed Volume as raw `reps * weight` with no knowledge of exercise type, so bodyweight exercises (whose logged `weight` is just *added* weight) showed ~0 volume. `ProgressChart` now takes `variant: LogSetCardVariant` and `bodyweightKg` params (passed from `exercise_page.dart`, which loads `userBodyweightKg` via `SharedPreferences` the same way `stats_tab.dart` does) and uses `calcSetVolume()` from `lib/utils/volume_utils.dart` for the Volume metric. Metric dropdown (`Volume`/`Max Weight`/`Reps`/`Time`) was unconditional — now gated by variant via `_availableMetrics` (timed exercises only see `Time`; all others only see `Volume`/`Max Weight`/`Reps`), with `_selectedMetric` reset if it falls outside the available set. |
| Timed sets — prevent zero/null time entries | ✅ Done | `log_set_card.dart`: stopping a timer (`_toggleTimer`), the manual time-adjustment sheet, and "copy previous" all set `isCompleted = true` unconditionally, even at 0 seconds — this bypassed `WorkoutManager._isSetLogged`'s empty-set filter (which short-circuits `true` on `isCompleted`) and let 0-duration rows reach the DB. Now `isCompleted` is only set true when duration ≥ 1000ms. Also added a timed-variant branch to the pre-submit validation on the standalone "Log Exercise" button (mirrors existing weighted/bodyweight checks), rejecting sets with `durationMs < 1000` with a snackbar instead of silently allowing them through — this closes the equivalent hole in the standalone per-exercise flow (`exercise_page.dart`), which has no `_isSetLogged`-style filter of its own. |
| Timed sets — paused-state button + row highlight | ✅ Done | `log_set_card.dart`: the paused/stopped state of a timed set previously showed a green checkmark button that only toggled `isCompleted` back to `false` without resetting the recorded duration (so resuming continued from the old time). Swapped for a restart icon (`Icons.restart_alt`) wired to the pre-existing but previously-unused `_SetData.resetTimer()`, which zeroes `durationMs`/`timeBeforeStartMs` and returns the row to its play-ready state. Also removed the whole-row green highlight (`rowColor`) for timed sets specifically — it's still used for completed weighted/bodyweight sets, but for timed rows it read as misleading "success" styling on a merely-paused timer. |

---

## What's Been Shipped (merged to `main`)

### Core Workout Flow
- [x] Active workout session with live timer (`WorkoutManager` singleton)
- [x] Minimize/maximize workout — global `MinimizedWorkoutBar` persists across navigation
- [x] Set logging — weight/reps/time variants (`log_set_card.dart`, `log_set_card_bonus.dart`)
- [x] Rest timer with interactive overlay (`RestTimerNotifier`, `rest_timer_button.dart`)
- [x] Bodyweight and timed exercise tracking (separate input UI per type)
- [x] Copy previous session's logs into a new set row
- [x] PR (personal record) badge detection and display on set cards
- [x] Reorder exercises within an active workout
- [x] Discard workout confirmation dialog
- [x] Resume/discard dialog when returning to an in-progress workout

### Saving & History
- [x] Save workout screen (rename, adjust date/duration manually)
- [x] Workout summary screen (post-session review)
- [x] Workout history screen with delete + undo
- [x] Per-workout detail view (`workout_page.dart`)
- [x] Clear all workout history
- [x] Preserve exercise log history when deleting a custom exercise template (renames to `"(Deleted)"`)

### Exercises
- [x] Exercise catalog (loaded from `assets/exercises.json`)
- [x] Custom exercise creation (name, type, tracking type, muscle group selection)
- [x] Soft-delete custom exercises → "Recently Deleted" screen
- [x] Restore or permanently delete from Recently Deleted
- [x] `isTracked` + `isDeleted` flags to distinguish hidden vs. truly gone exercises
- [x] Per-exercise detail page with progress chart and history (`exercise_page.dart`)
- [x] "See All History" screen for a specific exercise
- [x] Duplicate validation (asset catalog + DB, active + soft-deleted, with correct `isTracked` guard)
- [x] Two-step delete dialog for custom exercises — "Remove from catalogue" vs "Delete permanently" with explicit history warning

### Muscle Group System
- [x] `MuscleGroups` + `ExerciseMuscleGroups` junction table (schema v3+)
- [x] Multi-muscle selection with role (Primary = first selected, Secondary = rest)
- [x] Muscle group focus card in stats

### Routines
- [x] Create routine screen (build + save)
- [x] Explore routines screen (browse + load)
- [x] Pre-built default routines seeded on `beforeOpen`
- [x] Start a workout from a saved routine

### Stats Tab
- [x] Modular insight card shell (`insight_card.dart`)
- [x] Personal records card
- [x] Top exercises card (by volume)
- [x] Muscle group focus card
- [x] Muscle volume heatmap
- [x] Progress chart (line/bar via `fl_chart`)

### UI / UX
- [x] Dark / light mode with `SharedPreferences` persistence
- [x] Material 3 with custom `ThemeExtension` for `RestTimerTheme`
- [x] DM Sans font via `google_fonts`
- [x] `ResponsiveHelper` for adaptive sizing
- [x] `BouncingButton` animation on interactive elements
- [x] Auto-scroll to newly added exercises
- [x] App icon (Android + iOS via `flutter_launcher_icons`)

---

## Known Issues / Tech Debt

| Area | Issue | Severity |
|---|---|---|
| `MuscleGroup` ID generation | Uses `ms_hashCode` — not guaranteed unique across concurrent inserts in `addExerciseWithMuscles` | Low |
| `watchAllLogsWithWorkoutAndExercise` | Deduplication done in-memory via `Map` — could be done at query level | Low |
| `exercises_tab_landing` vs `exercise_tab_copy_landing` | Two near-identical tab files exist; copy variant's purpose is unclear | Medium |
| Schema migration v8/v9 | Both migrations drop + recreate routines tables identically — one is redundant | Low |
| No unit or widget tests | Zero test coverage across the codebase | High |
| `ExerciseLogs` join on `exerciseName` (string) | History joins use name-matching, not a foreign key — rename-on-delete workaround required | Medium |
| Rest timer notification | Notification fires correctly but needs finetuning: notification copy, sound choice, and behaviour when app is foregrounded (currently shows banner even in-app since `presentAlert: true`) should all be revisited | Low |

---

## Planned / Backlog

> Add items here as they come up. No priority order implied.

- [ ] Weekly volume targets / goal setting
- [x] Exercise notes per session
- [ ] Superset / circuit support in the workout flow
- [ ] Workout templates (distinct from routines — pre-filled sets/reps)
- [x] Export workout history (CSV / JSON)
- [x] Notification for rest timer completion
- [x] Minimized card layout for workout history
- [ ] Search/filter on workout history screen
- [ ] Pagination or lazy loading for long exercise history lists
- [ ] Widget tests for `WorkoutManager` state transitions
- [ ] Consolidate `exercises_tab_landing` and `exercise_tab_copy_landing`
- [ ] Migrate `ExerciseLogs.exerciseName` join to use `exerciseId` FK

---

## DB Schema Quick Reference

| Table | Version added | Key columns |
|---|---|---|
| `Exercises` | v1 | `id`, `name`, `category`, `isDeleted`, `isTracked`, `exerciseType`, `trackingType` |
| `MuscleGroups` | v3 | `id`, `name (unique)` |
| `ExerciseMuscleGroups` | v3 | `(exerciseId, muscleGroupId)` PK, `role` (1=Primary, 2=Secondary) |
| `Workouts` | v1 | `id`, `startTime`, `endTime`, `isStandalone`, `description` |
| `ExerciseLogs` | v1 | `id`, `workoutId`, `exerciseName`, `setNumber`, `weight`, `reps`, `time` (v11), `notes` (v12) |
| `Routines` | v7 | `id`, `title` |
| `RoutineExercises` | v7 | `routineId`, `exerciseName`, `category`, `exerciseType`, `trackingType`, `exerciseOrder`, `sets` |

---

## Key Files to Know When Picking Up Work

| Task type | Start here |
|---|---|
| Workout logic / state | `lib/state/workout_manager.dart` |
| Adding a screen | `lib/navigation/app_router.dart` + new file in `lib/screens/` |
| DB schema change | `lib/database/database.dart` → bump `schemaVersion` → `dart run build_runner build` |
| New stats widget | Extend `lib/widgets/insight_card.dart`, add to `lib/screens/stats_tab.dart` |
| Theming / colours | `lib/palette/color_scheme.dart`, `lib/theme/app_theme.dart`, `main.dart` (RestTimerTheme) |
| Responsive sizing | `lib/utils/responsive_helper.dart` |
| Data export | `lib/services/export_service.dart` (CSV/JSON building + share), `lib/screens/export_history_screen.dart` (UI) |
