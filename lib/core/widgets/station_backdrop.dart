import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppImages {
  static const station = 'assets/images/station_background.jpg';
  static const trainHeader = 'assets/images/train_header_art.jpg';
}

/// Full-bleed station photograph with a dark scrim so white type stays readable.
class StationBackdrop extends StatelessWidget {
  final Widget child;
  final Alignment alignment;

  const StationBackdrop({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.station,
            fit: BoxFit.cover,
            alignment: alignment,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x990F1115),
                  Color(0x2E0F1115),
                  Color(0xB30F1115),
                  Color(0xF70F1115),
                ],
                stops: [0.0, 0.34, 0.68, 1.0],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
