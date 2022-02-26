import 'package:flutter/material.dart';

class CustomSliderTheme extends StatelessWidget {
  final Widget child;

  const CustomSliderTheme({
    required this.child,
    Key ? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double thumbRadius = 6;
    const double tickMarkRadius = 6;

    final activeColor = Color(0xFF1976D2);
    final inactiveColor = Colors.grey;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,

        /// Thumb
        rangeThumbShape: RoundRangeSliderThumbShape(
          disabledThumbRadius: thumbRadius,
          enabledThumbRadius: thumbRadius,
        ),

        /// Tick Mark
        rangeTickMarkShape:
        RoundRangeSliderTickMarkShape(tickMarkRadius: tickMarkRadius),

        /// Inactive
        inactiveTickMarkColor: inactiveColor,
        inactiveTrackColor: inactiveColor,

        /// Active
        thumbColor: activeColor,
        activeTrackColor: activeColor,
        activeTickMarkColor: activeColor,
      ),
      child: child,
    );
  }
}