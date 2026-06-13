import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app_winter/state/workout_manager.dart';

void main() {
  group('WorkoutManager State Tracking Tests', () {
    late WorkoutManager manager;

    setUp(() {
      manager = WorkoutManager();
      // Ensure it is in a clean state
      if (manager.isActive) {
        // We can't easily await discardWorkout in sync setUp if it calls DB, 
        // but startWorkout is sync and clears state.
        manager.startWorkout();
      }
    });

    test('startWorkout clears all tracking lists', () {
      manager.trackNewlyCreatedExercise('ex_1');
      manager.trackRestoredExercise('ex_2');
      expect(manager.newlyCreatedExerciseIds, contains('ex_1'));
      expect(manager.restoredExerciseIds, contains('ex_2'));

      manager.startWorkout();

      expect(manager.newlyCreatedExerciseIds, isEmpty);
      expect(manager.restoredExerciseIds, isEmpty);
      expect(manager.isActive, isTrue);
    });

    test('trackNewlyCreatedExercise adds unique IDs only', () {
      manager.startWorkout();
      manager.trackNewlyCreatedExercise('ex_1');
      manager.trackNewlyCreatedExercise('ex_1');
      manager.trackNewlyCreatedExercise('ex_2');

      expect(manager.newlyCreatedExerciseIds, hasLength(2));
      expect(manager.newlyCreatedExerciseIds, containsAll(['ex_1', 'ex_2']));
    });

    test('trackRestoredExercise adds unique IDs only', () {
      manager.startWorkout();
      manager.trackRestoredExercise('ex_1');
      manager.trackRestoredExercise('ex_1');
      manager.trackRestoredExercise('ex_2');

      expect(manager.restoredExerciseIds, hasLength(2));
      expect(manager.restoredExerciseIds, containsAll(['ex_1', 'ex_2']));
    });
  });
}
