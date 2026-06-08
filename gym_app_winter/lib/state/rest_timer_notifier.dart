import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app_winter/main.dart';

class RestTimerNotifier extends ChangeNotifier {
  static final RestTimerNotifier _instance = RestTimerNotifier._internal();
  factory RestTimerNotifier() => _instance;
  RestTimerNotifier._internal();

  int _totalTime = 90;
  int _remainingTime = 90;
  bool _isRunning = false;
  Timer? _timer;

  int get totalTime => _totalTime;
  int get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;

  void start() {
    _totalTime = 90;
    _remainingTime = 90;
    _isRunning = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void _tick(Timer timer) {
    if (_remainingTime > 0) {
      _remainingTime--;
      notifyListeners();
    }
    
    if (_remainingTime == 0) {
      _finish();
    }
  }

  void adjust(int seconds) {
    if (!_isRunning) return;
    _remainingTime = max(5, _remainingTime + seconds);
    notifyListeners();
  }

  void _finish() async {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
    
    // Double haptic feedback pattern
    HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.vibrate();
    
    SystemSound.play(SystemSoundType.alert);

    // Show 1-second toast
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Text(
          "Rest complete!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF5048D4),
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(48, 0, 48, 80),
        elevation: 6,
      ),
    );
  }

  void cancel() {
    _timer?.cancel();
    _remainingTime = 90;
    _totalTime = 90;
    _isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
