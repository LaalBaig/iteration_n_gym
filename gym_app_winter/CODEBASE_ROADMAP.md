# Gym App Winter - Codebase Roadmap

Welcome to the `gym_app_winter` codebase roadmap! This document provides a comprehensive overview of the `lib` folder architecture, patterns, and conventions to help AI agents or orchestrators effectively navigate, understand, and modify the application.

## 📌 Project Overview
This project is a fitness tracking Flutter application. It allows users to track workouts, log exercises (sets, reps, weight, time), explore and create routines, browse exercises, and view workout history and stats. It features an active workout tracker that can be minimized while navigating the app, alongside custom exercise creation and rest timers.

### 🛠 Core Technologies
- **Framework:** Flutter (Dart)
- **Local Database:** [Drift](https://drift.simonbinder.eu/) (SQLite wrapper)
- **Routing:** `go_router`
- **State Management:** Singleton-based `ChangeNotifier` (`WorkoutManager`, `RestTimerNotifier`)
- **Theming:** Material 3 (with custom ThemeExtensions for components like RestTimer)

---

## 📂 Directory Structure (`lib/`)

### 1. `main.dart`
The entry point of the application. It initializes the app, configures responsive text scaling, handles theme switching via `SharedPreferences`, and sets up the `MaterialApp.router` using `go_router`. It wraps the app in a `Stack` to display the globally accessible `MinimizedWorkoutBar`, and defines `RestTimerTheme` as a `ThemeExtension` applied to both light and dark themes.

### 2. `database/`
Handles all local persistence.
- **`database.dart` & `database.g.dart`**: Contains the Drift database configuration, schema definitions, and generated code. The schema has **7 tables**: `Exercises`, `MuscleGroups`, `ExerciseMuscleGroups`, `Workouts`, `ExerciseLogs`, `Routines`, `RoutineExercises`. Also defines helper result classes (`ExerciseLogWithWorkout`, `LogWithWorkoutAndExercise`, `MuscleTarget`, `RoutineWithExercises`).
- **`database_service.dart`**: A singleton wrapper around `AppDatabase` to provide global access to database operations.

### 3. `datamodel/`
Contains plain Dart classes representing core in-memory business entities (independent of Drift schema classes).
- **`exercise.dart`**: Basic exercise data (name, muscle group, etc.) used in-session.
- **`ExerciseModel.dart`**: A richer exercise model used for UI state.
- **`ExerciseLog.dart`**: Represents a logged exercise in a session.
- **`ExerciseLogEntry.dart`**: Represents a single set entry within an exercise log.
- **`Workout.dart`**: Represents an active or completed workout session.
- **`enums.dart`**: Shared enums (e.g. muscle groups, set types).

### 4. `models/`
An additional models layer separate from `datamodel/`.
- **`catalog_exercise.dart`**: `CatalogExercise` — represents an exercise from the browseable exercise catalog (distinct from in-session or DB exercise representations).

### 5. `state/`
Centralized state management using Singletons extending `ChangeNotifier`.
- **`workout_manager.dart`**: The core engine during a workout. Manages the active session (time elapsed, sets completed, volume), minimize/maximize logic, and commits the final session to the database via `DatabaseService`. Key methods: `startWorkout()`, `addLogsForExercise()`, `finishWorkout()`.
- **`rest_timer_notifier.dart`**: Manages the rest countdowns between sets.

### 6. `navigation/`
Handles all routing logic.
- **`app_router.dart`**: Configures `GoRouter`. All named routes:

| Path | Screen |
|---|---|
| `/` | `MainScreen` |
| `/active_workout` | `ActiveWorkoutScreen` (slides up) |
| `/add_exercise` | `AddExerciseScreen` |
| `/workout_page` | `WorkoutPage` |
| `/workout_summary` | `WorkoutSummaryScreen` |
| `/workout_history` | `WorkoutHistoryScreen` |
| `/save_workout` | `SaveWorkoutScreen` |
| `/create_routine` | `CreateRoutineScreen` |
| `/explore_routines` | `ExploreRoutinesScreen` |
| `/custom` | `CustomExerciseScreen` |
| `/recently_deleted` | `RecentlyDeletedScreen` |
| `/exercise_page/:exerciseName` | `ExercisePage` |
| `/see_all_history/:exerciseName` | `SeeAllHistoryScreen` |

### 7. `screens/`
Top-level UI pages, one per route. Full list:
- **`main_screen.dart`**: Root shell with bottom nav; hosts the tab layout.
- **`workout_tab.dart`**: The Workouts tab — shows recent workouts, start options.
- **`exercises_tab_landing.dart`**: The Exercises tab — browseable exercise catalog.
- **`exercise_tab_copy_landing.dart`**: Variant of the exercises tab (used in specific flows).
- **`stats_tab.dart`**: Stats tab — workout analytics and volume charts.
- **`profile_tab.dart`**: Profile tab — user settings and preferences.
- **`active_workout_screen.dart`**: The live workout session view.
- **`add_exercise_screen.dart`**: Search and add exercises to an active workout.
- **`workout_summary_screen.dart`**: Post-workout review shown after finishing.
- **`save_workout_screen.dart`**: Intermediate screen for naming/saving a workout.
- **`workout_history_screen.dart`**: Past workout logs overview.
- **`see_all_history_screen.dart`**: Full history for a specific exercise.
- **`workout_page.dart`**: Detail view for a specific workout from history.
- **`exercise_page.dart`**: Detail view for a specific exercise (charts, PRs, history).
- **`explore_routines_screen.dart`**: Browse and load pre-built or saved routines.
- **`create_routine_screen.dart`**: UI to build and save a new routine.
- **`custom_exercise_screen.dart`**: UI to create a new custom exercise.
- **`recently_deleted_screen.dart`**: Recover soft-deleted workouts or exercises.

### 8. `widgets/`
Reusable UI components. Organized by concern:

**Active Workout / Logging**
- `log_set_card.dart` / `log_set_card_bonus.dart`: Complex set-logging forms (reps, weight, time).
- `rest_timer_button.dart`: Interactive button for starting/stopping the rest timer.
- `minimized_workout_bar.dart`: Floating bar shown when a workout is minimized.
- `confirm_log.dart`: Dialog/prompt to confirm logging a set.
- `discard_workout_dialog.dart`: Confirmation dialog for discarding an active workout.

**Stats / Insights**
- `insight_card.dart`: Shared card shell used by all stats insight widgets.
- `personal_records_card.dart`: Displays personal records per exercise.
- `top_exercises_card.dart`: Shows most-performed exercises by volume.
- `muscle_group_focus_card.dart`: Breakdown of training focus by muscle group.
- `muscle_volume_heatmap.dart`: Visual heatmap of muscle volume trained.
- `progress_chart.dart`: Line/bar chart for tracking progress over time.

**Lists / Tiles**
- `exercise_tile.dart`: Row widget for displaying a single exercise in a list.
- `history_tile.dart`: Row widget for displaying a past workout in history.
- `workout_summary_card.dart`: Card summarizing a completed workout.

**Layout / Shared**
- `app_card.dart`: Base card component with consistent styling used across the app.
- `bottom_navigation_bar.dart`: Custom bottom nav bar widget.
- `floating_button.dart`: Reusable floating action button.
- `workout_button_top.dart`: Top-of-screen workout action button.
- `bouncing_button.dart`: Button with a bounce animation.
- `search_bar.dart`: Search input widget used in exercise browsing.
- `empty_exercise_screen.dart`: Empty state UI when no exercises are found.
- `not_found.dart`: 404/not-found fallback widget.

### 9. `theme/` & `palette/` & `constants/`
Manages visual identity.
- **`theme/app_theme.dart`**: Responsive typography using DM Sans via `google_fonts`. Defines `getResponsiveTextTheme()`.
- **`palette/color_scheme.dart`**: Defines standard hex codes and color palettes.
- **`constants/spacing.dart`**: Constants for padding and margins for consistent UI density.

### 10. `utils/`
- **`responsive_helper.dart`**: Adapts UI components to different screen sizes and text scaling settings.

### 11. `compile_check.dart`
A scratch file used to verify that third-party packages (e.g. `figma_squircle`) compile correctly. Not part of the app logic — safe to ignore.

---

## 🧠 Architectural Patterns & Workflows

### The "Active Workout" Lifecycle
1. **Start:** User initiates a workout. `WorkoutManager().startWorkout()` is called. The timer begins.
2. **Minimize/Maximize:** The user can minimize the workout. `ActiveWorkoutScreen` pops, but `WorkoutManager` keeps running. The global `MinimizedWorkoutBar` in `main.dart` detects `WorkoutManager().isActive` and appears.
3. **Logging Sets:** As the user logs a set in `log_set_card.dart`, it updates local state in `WorkoutManager` via `addLogsForExercise()`.
4. **Finish:** User finishes. `WorkoutManager().finishWorkout()` writes the `Workout`, `Exercises`, and `ExerciseLogs` to the Drift database in a batch operation.

### Data Flow (UI -> State -> DB)
1. **Read:** Screens query the Drift database directly (via `FutureBuilder` or `StreamBuilder`) for history and catalog data, or read from `WorkoutManager` for live active-session data.
2. **Write:** UI interacts with `WorkoutManager` for temporary session data. Persistent changes (deleting history, saving routines, custom exercises) go through `DatabaseService().db.<method>`.

### Routines
Routines are stored in the `Routines` and `RoutineExercises` tables. Users can create them via `CreateRoutineScreen` or browse pre-built ones via `ExploreRoutinesScreen`. Loading a routine pre-populates the active workout session.

---

## 🤖 Agent Navigation Guide
- **Adding a new UI screen:** Create it in `/screens`, add its route to `app_router.dart`, navigate with `GoRouter.of(context).push('/your_route')`.
- **Altering the database schema:** Update table definitions in `database.dart`, then run `dart run build_runner build` to regenerate `database.g.dart`.
- **Adding a new workout metric or rule:** Modify `workout_manager.dart` — it is the centralized brain for all active workout logic.
- **Adding a stats insight widget:** Build it on top of `insight_card.dart` and place it in `stats_tab.dart`.
- **Styling new components:** Always use `Theme.of(context).colorScheme` and the `RestTimerTheme` extension from `main.dart` to support dark/light mode seamlessly.
