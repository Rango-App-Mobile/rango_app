import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_primitives.dart';

/// Figma "User Location": ink dot with a cream border inside a sky halo that
/// breathes from 1 to 1.15 every 2 s, unless the person asked for less motion.
class UserLocationMarker extends StatefulWidget {
  const UserLocationMarker({super.key});

  static const size = 64.0;
  static const _dot = 16.0;

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  // Created in initState (not lazily) so dispose never builds a ticker.
  late final AnimationController _pulse;
  bool _pulsing = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _pulsing) {
      _pulse.stop();
      _pulsing = false;
    } else if (!reduceMotion && !_pulsing) {
      _pulse.repeat(reverse: true).ignore();
      _pulsing = true;
    }

    return Semantics(
      label: 'Você está aqui',
      child: SizedBox.square(
        dimension: UserLocationMarker.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.15).animate(_pulse),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPrimitives.sky.withValues(alpha: 0.5),
                  border: Border.all(
                    color: AppPrimitives.sky,
                    width: 1.5,
                  ),
                ),
                child: const SizedBox.square(
                  dimension: UserLocationMarker.size,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPrimitives.ink900,
                border: Border.all(color: AppPrimitives.cream, width: 3),
              ),
              child: const SizedBox.square(
                dimension: UserLocationMarker._dot + 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
