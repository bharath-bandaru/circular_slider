import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';

/// A beautiful circular slider widget with gradient progress and auto-fitting text.
class GradientCircularSlider extends StatefulWidget {
  /// Minimum value of the slider
  final double minValue;

  /// Maximum value of the slider
  final double maxValue;

  /// Initial value of the slider
  final double initialValue;

  /// Colors for the circular sweep gradient
  final List<Color> gradientColors;

  /// Stroke width of the circle
  final double ringThickness;

  /// Symbol before number (e.g., '$', '�', '%')
  final String prefix;

  /// Ratio of prefix font size to main font
  final double prefixScale;

  /// Text shown on the top arc
  final String? labelText;

  /// Enables tactile feedback
  final bool enableHaptics;

  /// Color for central text
  final Color textColor;

  /// Custom TextStyle for label
  final TextStyle? labelStyle;

  /// Decimal places for displayed value
  final int decimalPrecision;

  /// Callback when value changes
  final ValueChanged<double>? onChanged;

  /// Callback when dragging starts
  final VoidCallback? onChangeStart;

  /// Callback when dragging ends
  final VoidCallback? onChangeEnd;

  /// Shadow or glow effect behind the knob
  final List<BoxShadow>? knobShadows;

  /// Size of the draggable knob
  final double knobRadius;

  /// Color of the knob
  final Color? knobColor;

  /// Background color of the ring
  final Color? ringBackgroundColor;

  /// Animation duration for programmatic changes
  final Duration animationDuration;

  /// Animation curve for value changes
  final Curve animationCurve;

  GradientCircularSlider({
    super.key,
    this.minValue = 0,
    this.maxValue = 100,
    required this.initialValue,
    this.gradientColors = const [Colors.blue, Colors.green],
    this.ringThickness = 20.0,
    this.prefix = r'$',
    this.prefixScale = 0.6,
    this.labelText,
    this.enableHaptics = true,
    this.textColor = Colors.white,
    this.labelStyle,
    this.decimalPrecision = 2,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.knobShadows,
    this.knobRadius = 15,
    this.knobColor,
    this.ringBackgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  })  : assert(minValue < maxValue, 'minValue must be less than maxValue'),
        assert(initialValue >= minValue && initialValue <= maxValue,
            'initialValue must be between minValue and maxValue'),
        assert(ringThickness > 0, 'ringThickness must be positive'),
        assert(prefixScale > 0 && prefixScale <= 1,
            'prefixScale must be between 0 and 1'),
        assert(decimalPrecision >= 0, 'decimalPrecision must be non-negative'),
        assert(knobRadius > 0, 'knobRadius must be positive') {
    // Runtime validation for gradient colors
    if (gradientColors.length < 2) {
      throw ArgumentError('gradientColors must have at least 2 colors');
    }
  }

  @override
  State<GradientCircularSlider> createState() => _GradientCircularSliderState();
}

class _GradientCircularSliderState extends State<GradientCircularSlider>
    with SingleTickerProviderStateMixin {
  late double _currentValue;
  late AnimationController _animationController;
  late Animation<double> _valueAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _valueAnimation = Tween<double>(
      begin: _currentValue,
      end: _currentValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void didUpdateWidget(GradientCircularSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && !_isDragging) {
      _animateToValue(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateToValue(double newValue) {
    _valueAnimation = Tween<double>(
      begin: _currentValue,
      end: newValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    _animationController.forward(from: 0).then((_) {
      setState(() {
        _currentValue = newValue;
      });
    });
  }

  double _normalizeValue(double value) {
    return (value - widget.minValue) / (widget.maxValue - widget.minValue);
  }

  double _denormalizeValue(double normalizedValue) {
    return normalizedValue * (widget.maxValue - widget.minValue) +
        widget.minValue;
  }

  void _handlePanUpdate(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final angle = math.atan2(
      localPosition.dy - center.dy,
      localPosition.dx - center.dx,
    );

    // Convert angle to 0-1 range
    // Starting from top (12 o'clock position) and going clockwise
    double normalizedAngle = (angle + math.pi / 2) / (2 * math.pi);
    if (normalizedAngle < 0) normalizedAngle += 1;

    final currentValueNormalized = _normalizeValue(_currentValue);

    // Prevent dragging left (counter-clockwise) when at 0%
    if (currentValueNormalized <= 0.01 && normalizedAngle > 0.5) {
      return;
    }

    // Prevent dragging right (clockwise) when at 100%
    if (currentValueNormalized >= 0.99 && normalizedAngle < 0.5) {
      return;
    }

    // Snap to 0% or 100% when very close to the start/end
    if (normalizedAngle > 0.99) {
      normalizedAngle = 1.0;
    } else if (normalizedAngle < 0.01) {
      normalizedAngle = 0.0;
    }

    final newValue = _denormalizeValue(normalizedAngle);

    setState(() {
      _currentValue = newValue;
    });

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    widget.onChanged?.call(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final minDimension = math.min(size.width, size.height);

        return SizedBox(
          width: minDimension,
          height: minDimension,
          child: AnimatedBuilder(
            animation: _valueAnimation,
            builder: (context, child) {
              final animatedValue =
                  _isDragging ? _currentValue : _valueAnimation.value;

              return GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isDragging = true;
                  });
                  widget.onChangeStart?.call();
                  _handlePanUpdate(
                      details.localPosition, Size(minDimension, minDimension));
                },
                onPanUpdate: (details) {
                  _handlePanUpdate(
                      details.localPosition, Size(minDimension, minDimension));
                },
                onPanEnd: (_) {
                  _valueAnimation = AlwaysStoppedAnimation(_currentValue);

                  setState(() {
                    _isDragging = false;
                  });
                  widget.onChangeEnd?.call();
                },
                child: CustomPaint(
                  size: Size(minDimension, minDimension),
                  painter: _CircularSliderPainter(
                    value: _normalizeValue(animatedValue),
                    gradientColors: widget.gradientColors,
                    ringThickness: widget.ringThickness,
                    knobRadius: widget.knobRadius,
                    knobColor: widget.knobColor ?? Colors.white,
                    knobShadows: widget.knobShadows ??
                        [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                    ringBackgroundColor:
                        widget.ringBackgroundColor ?? Colors.grey.shade300,
                    labelText: widget.labelText,
                    labelStyle: widget.labelStyle ??
                        const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                  ),
                  child: Center(
                    child: _buildCenterText(animatedValue),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCenterText(double value) {
    final displayValue = value.toStringAsFixed(widget.decimalPrecision);
    final fontSize = _calculateFontSize();

    return Padding(
      padding: EdgeInsets.all(widget.ringThickness + widget.knobRadius + 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.prefix,
            style: TextStyle(
              color: widget.textColor,
              fontSize: fontSize * widget.prefixScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: AutoSizeText(
              displayValue,
              style: TextStyle(
                color: widget.textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              minFontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateFontSize() {
    // Use a default font size - will be properly sized by AutoSizeText
    return 48; // Base size, AutoSizeText will scale it down as needed
  }
}

class _CircularSliderPainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final List<Color> gradientColors;
  final double ringThickness;
  final double knobRadius;
  final Color knobColor;
  final List<BoxShadow> knobShadows;
  final Color ringBackgroundColor;
  final String? labelText;
  final TextStyle labelStyle;

  _CircularSliderPainter({
    required this.value,
    required this.gradientColors,
    required this.ringThickness,
    required this.knobRadius,
    required this.knobColor,
    required this.knobShadows,
    required this.ringBackgroundColor,
    this.labelText,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - knobRadius;

    // Draw background ring
    final backgroundPaint = Paint()
      ..color = ringBackgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringThickness
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw gradient ring
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw gradient arc only if value > 0
    if (value > 0) {
      // Create a gradient that maps to the actual drawn arc length
      final List<Color> adjustedColors = [];
      final List<double> adjustedStops = [];

      // Calculate how to distribute the gradient across the arc
      final colorCount = gradientColors.length;

      // Add gradient colors distributed across the value range
      for (int i = 0; i < colorCount; i++) {
        final stop = i / (colorCount - 1) * value;
        adjustedStops.add(stop);
        adjustedColors.add(gradientColors[i]);
      }

      // Fill the rest with the last color to avoid gradient wrapping
      if (value < 1.0) {
        adjustedStops.add(value + 0.001);
        adjustedColors.add(gradientColors.last);
        adjustedStops.add(1.0);
        adjustedColors.add(gradientColors.last);
      }

      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: adjustedColors,
          stops: adjustedStops,
          startAngle: -math.pi / 2, // Start at top
          endAngle: -math.pi / 2 +
              (2 * math.pi), // Full circle for gradient calculation
          tileMode: TileMode.clamp,
        ).createShader(rect);

      // Draw only the portion of the arc based on the value
      canvas.drawArc(
        rect,
        -math.pi / 2, // Start at top
        2 * math.pi * value, // Draw arc based on value (0 to 100%)
        false,
        gradientPaint,
      );
    }

    // Calculate knob position
    // Start at top (-π/2) and move clockwise
    // When value is 0, knob is at top. When value is 1 (100%), knob returns to top after full circle
    final angle = -math.pi / 2 + (2 * math.pi * value);
    final knobX = center.dx + radius * math.cos(angle);
    final knobY = center.dy + radius * math.sin(angle);
    final knobOffset = Offset(knobX, knobY);

    // Draw knob shadows
    for (final shadow in knobShadows) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);

      canvas.drawCircle(
        knobOffset + shadow.offset,
        knobRadius,
        shadowPaint,
      );
    }

    // Draw knob
    final knobPaint = Paint()
      ..color = knobColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(knobOffset, knobRadius, knobPaint);

    // Draw knob border
    final knobBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(knobOffset, knobRadius, knobBorderPaint);

    // Draw circular arc label
    if (labelText != null && labelText!.isNotEmpty) {
      _drawCircularText(canvas, size, center, radius);
    }
  }

  void _drawCircularText(
      Canvas canvas, Size size, Offset center, double radius) {
    // Calculate text arc parameters
    final textRadius = radius - ringThickness - 25;
    final textAngleStart = -math.pi * 0.7; // Start angle for text arc
    final textAngleSpan = math.pi * 0.4; // Total span of text arc

    // Split text into characters
    final chars = labelText!.split('');
    final charCount = chars.length;

    if (charCount == 0) return;

    final anglePerChar = textAngleSpan / (charCount - 1);

    canvas.save();

    for (int i = 0; i < charCount; i++) {
      final angle = textAngleStart + (anglePerChar * i);

      final textPainter = TextPainter(
        text: TextSpan(
          text: chars[i],
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();

      // Calculate position for this character
      final charX = center.dx + textRadius * math.cos(angle);
      final charY = center.dy + textRadius * math.sin(angle);

      // Translate to character position
      canvas.translate(charX, charY);

      // Rotate to align with circle
      canvas.rotate(angle + math.pi / 2);

      // Draw character centered
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CircularSliderPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.ringThickness != ringThickness ||
        oldDelegate.knobRadius != knobRadius ||
        oldDelegate.knobColor != knobColor ||
        oldDelegate.labelText != labelText;
  }
}
