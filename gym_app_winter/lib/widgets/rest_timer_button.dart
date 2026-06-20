import 'dart:math';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:flutter/material.dart';
import 'package:gym_app_winter/state/rest_timer_notifier.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class RestTimerButton extends StatefulWidget {
  const RestTimerButton({super.key});

  @override
  State<RestTimerButton> createState() => _RestTimerButtonState();
}

class _RestTimerButtonState extends State<RestTimerButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isPopupOpen = false;

  void _togglePopup() {
    if (_isPopupOpen) {
      _closePopup();
    } else {
      _openPopup();
    }
  }

  void _openPopup() {
    if (_isPopupOpen) return;
    
    // Start timer if not running
    if (!RestTimerNotifier().isRunning) {
      RestTimerNotifier().start();
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isPopupOpen = true;
    });
  }

  void _closePopup() {
    if (!_isPopupOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isPopupOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Transparent barrier to detect outside taps
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closePopup,
                child: Container(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(-200, 50), // Adjust to bottom-left align roughly
              child: Material(
                color: Colors.transparent,
                child: ListenableBuilder(
                  listenable: RestTimerNotifier(),
                  builder: (context, _) {
                    final notifier = RestTimerNotifier();
                    return _RestTimerPopupContent(
                      onClose: () {
                        notifier.cancel();
                        _closePopup();
                      },
                      onAdd: () => notifier.adjust(15),
                      onSubtract: () => notifier.adjust(-15),
                      remainingTime: notifier.remainingTime,
                      totalTime: notifier.totalTime,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RestTimerNotifier(),
      builder: (context, _) {
        final notifier = RestTimerNotifier();
        final isRunning = notifier.isRunning;
        final timerTheme = context.timerTheme;
        
        final bgColor = isRunning ? timerTheme.buttonActiveBg : timerTheme.buttonInactiveBg;
        final fgColor = isRunning ? timerTheme.buttonActiveTextColor : timerTheme.buttonInactiveTextColor;
        
        String label = "Rest";
        if (isRunning) {
          final mins = notifier.remainingTime ~/ 60;
          final secs = notifier.remainingTime % 60;
          label = "$mins:${secs.toString().padLeft(2, '0')}";
        }

        return CompositedTransformTarget(
          link: _layerLink,
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: FilledButton.icon(
              onPressed: _togglePopup,
              style: FilledButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                shape: const StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16)),
              ),
              icon: Icon(Icons.timer_outlined, size: ResponsiveHelper.w(20)),
              label: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RestTimerPopupContent extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;
  final int remainingTime;
  final int totalTime;

  const _RestTimerPopupContent({
    required this.onClose,
    required this.onAdd,
    required this.onSubtract,
    required this.remainingTime,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final mins = remainingTime ~/ 60;
    final secs = remainingTime % 60;
    final timeStr = "$mins:${secs.toString().padLeft(2, '0')}";
    final timerTheme = context.timerTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16), vertical: ResponsiveHelper.h(12)),
      decoration: BoxDecoration(
        color: timerTheme.popupBg,
        borderRadius: BorderRadius.circular(ResponsiveHelper.w(24)),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Arc
          SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(
              painter: _TimerArcPainter(
                fraction: remainingTime / (totalTime > 0 ? totalTime : 1),
                trackColor: timerTheme.trackColor ?? Colors.transparent,
                arcColor: timerTheme.arcColor ?? Colors.transparent,
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.w(16)),
          // Time Label
          SizedBox(
            width: 50,
            child: Text(
              timeStr,
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(18),
                fontWeight: FontWeight.w500,
                color: timerTheme.popupTextColor,
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.w(12)),
          // -15s Button
          _AdjustButton(
            label: "-15s",
            onPressed: onSubtract,
          ),
          SizedBox(width: ResponsiveHelper.w(8)),
          // +15s Button
          _AdjustButton(
            label: "+15s",
            onPressed: onAdd,
          ),
          SizedBox(width: ResponsiveHelper.w(8)),
          // Close Button
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant),
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AdjustButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final timerTheme = context.timerTheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: timerTheme.adjustBtnBg,
        foregroundColor: timerTheme.adjustBtnTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
        ),
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(12), vertical: ResponsiveHelper.h(8)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TimerArcPainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color arcColor;

  _TimerArcPainter({
    required this.fraction,
    required this.trackColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final Paint arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    canvas.drawArc(rect, 0, 2 * pi, false, trackPaint);
    
    // Start from top (-pi/2) and draw clockwise
    canvas.drawArc(rect, -pi / 2, 2 * pi * fraction, false, arcPaint);
  }

  @override
  bool shouldRepaint(_TimerArcPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
