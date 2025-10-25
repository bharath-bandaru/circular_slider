import 'dart:math' as math;
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';

/// A beautiful circular slider widget with gradient progress and an editable value.
class GradientCircularSlider extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double initialValue;
  final List<Color> gradientColors;
  final double ringThickness;
  final String prefix;
  final double prefixScale;
  final bool enableHaptics;
  final Color textColor;
  final int decimalPrecision;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onChangeStart;
  final VoidCallback? onChangeEnd;
  final List<BoxShadow>? knobShadows;
  final double knobRadius;
  final Color? knobColor;
  final Color? ringBackgroundColor;
  final Duration animationDuration;
  final Curve animationCurve;
  final String? labelText;
  final TextStyle? labelStyle;

  // Added properties for the inner circular label text
  final String? innerLabelText;
  final TextStyle? innerLabelStyle;

  GradientCircularSlider({
    super.key,
    this.minValue = 0,
    this.maxValue = 100,
    required this.initialValue,
    this.gradientColors = const [Colors.lightBlueAccent, Colors.blue],
    this.ringThickness = 20.0,
    this.prefix = r'$',
    this.prefixScale = 0.6,
    this.enableHaptics = true,
    this.textColor = Colors.white,
    this.decimalPrecision = 2,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.knobShadows,
    this.knobRadius = 15,
    this.knobColor,
    this.ringBackgroundColor,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
    this.labelText,
    this.labelStyle,
    // Add to constructor
    this.innerLabelText,
    this.innerLabelStyle,
  })  : assert(minValue < maxValue, 'minValue must be less than maxValue'),
        assert(initialValue >= minValue && initialValue <= maxValue,
            'initialValue must be between minValue and maxValue'),
        assert(ringThickness > 0, 'ringThickness must be positive'),
        assert(prefixScale > 0 && prefixScale <= 1,
            'prefixScale must be between 0 and 1'),
        assert(decimalPrecision >= 0, 'decimalPrecision must be non-negative'),
        assert(knobRadius > 0, 'knobRadius must be positive') {
    if (gradientColors.length < 2) {
      throw ArgumentError('gradientColors must have at least 2 colors');
    }
  }

  @override
  State<GradientCircularSlider> createState() => _GradientCircularSliderState();
}

class _GradientCircularSliderState extends State<GradientCircularSlider>
    with TickerProviderStateMixin {
  late AnimationController _valueAnimationController;
  bool _isDragging = false;
  bool _isEditing = false;
  late AnimationController _sizeAnimationController;
  late Animation<double> _sizeAnimation;
  AnimationController? _knobScaleAnimationController;
  Animation<double>? _knobScaleAnimation;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isUpdatingTextProgrammatically = false;
  double _minDimension = 0.0;

  @override
  void initState() {
    super.initState();
    _valueAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _normalizeValue(widget.initialValue),
    );
    _sizeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
          parent: _sizeAnimationController, curve: Curves.easeOutBack),
    );
    _knobScaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _knobScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
          parent: _knobScaleAnimationController!, curve: Curves.easeOutBack),
    );
    _setText(_denormalizeValue(_valueAnimationController.value)
        .toStringAsFixed(widget.decimalPrecision));
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _toggleEditMode(forceState: false);
      }
    });
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
    _valueAnimationController.dispose();
    _sizeAnimationController.dispose();
    _knobScaleAnimationController?.dispose();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setText(String value) {
    _isUpdatingTextProgrammatically = true;
    _textController.text = value;
    _isUpdatingTextProgrammatically = false;
  }

  void _onTextChanged() {
    // This listener should ONLY update the underlying slider value in real-time.
    // It should NOT format or set the text back into the controller.
    if (_isUpdatingTextProgrammatically || !_isEditing) return;

    final newValue = double.tryParse(_textController.text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(widget.minValue, widget.maxValue);
      final normalizedValue = _normalizeValue(clampedValue);
      _valueAnimationController.value = normalizedValue;
    }
  }

  void _animateToValue(double denormalizedValue) {
    final clampedValue =
        denormalizedValue.clamp(widget.minValue, widget.maxValue);
    final normalizedValue = _normalizeValue(clampedValue);
    _valueAnimationController.animateTo(
      normalizedValue,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );
    _setText(clampedValue.toStringAsFixed(widget.decimalPrecision));
  }

  void _toggleEditMode({bool? forceState}) {
    setState(() {
      _isEditing = forceState ?? !_isEditing;
      if (_isEditing) {
        // --- PREPARE FOR EDITING ---
        _sizeAnimationController.forward();

        final currentValue = _denormalizeValue(_valueAnimationController.value);

        // Format the value cleanly for editing (e.g., "50" instead of "50.00").
        final String valueForEditing = (currentValue.truncate() == currentValue)
            ? currentValue.truncate().toString()
            : currentValue
                .toString()
                .replaceAll(RegExp(r'0*$'), '')
                .replaceAll(RegExp(r'\.$'), '');

        _setText(valueForEditing);
        _focusNode.requestFocus();

        // After the UI builds, select all text for easy replacement.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_focusNode.hasFocus) {
            _textController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _textController.text.length,
            );
          }
        });
      } else {
        // --- FINALIZE EDITING ---
        _sizeAnimationController.reverse();
        _focusNode.unfocus();

        // On submission, take the final text, parse it, clamp it to the
        // allowed range, and run the formal animation which will also
        // re-format the text for display. Call `onChanged` with the
        // clamped value so parent widgets won't receive an out-of-range
        // value that could trigger assertions in their constructors.
        final enteredValue = double.tryParse(_textController.text) ??
            _denormalizeValue(_valueAnimationController.value);
        final double clampedValue =
            (enteredValue).clamp(widget.minValue, widget.maxValue);
        _animateToValue(clampedValue);
        widget.onChanged?.call(clampedValue);
      }
    });
  }

  bool hapticAt100PercentFired = false;

  double _normalizeValue(double value) =>
      (value - widget.minValue) / (widget.maxValue - widget.minValue);
  double _denormalizeValue(double normalizedValue) =>
      normalizedValue * (widget.maxValue - widget.minValue) + widget.minValue;

  void _handlePanUpdate(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final angle =
        math.atan2(localPosition.dy - center.dy, localPosition.dx - center.dx);
    double normalizedAngle = (angle + math.pi / 2) / (2 * math.pi);
    if (normalizedAngle < 0) normalizedAngle += 1;
    final currentValue = _valueAnimationController.value;
    double newNormalizedValue = normalizedAngle;
    if (currentValue > 0.75 && newNormalizedValue < 0.25) {
      newNormalizedValue = 1.0;
    } else if (currentValue < 0.25 && newNormalizedValue > 0.75) {
      newNormalizedValue = 0.0;
    }
    if (newNormalizedValue == 1.0) {
      if (!hapticAt100PercentFired) {
        HapticFeedback.mediumImpact();
        hapticAt100PercentFired = true;
      }
    }
    if (newNormalizedValue < 1.0) {
      hapticAt100PercentFired = false;
    }

    // Snappy snap to 100% when reaching 95% or higher (Apple Pay style)
    if (newNormalizedValue >= 0.97 && newNormalizedValue < 1.0) {
      _valueAnimationController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );
      final denormalizedValue = _denormalizeValue(1.0);
      _setText(denormalizedValue.toStringAsFixed(widget.decimalPrecision));
      if (widget.enableHaptics) HapticFeedback.mediumImpact();
      widget.onChanged?.call(denormalizedValue);
      return;
    }

    _valueAnimationController.value = newNormalizedValue;
    final denormalizedValue = _denormalizeValue(newNormalizedValue);
    _setText(denormalizedValue.toStringAsFixed(widget.decimalPrecision));
    if (widget.enableHaptics) HapticFeedback.lightImpact();
    widget.onChanged?.call(denormalizedValue);
  }

// NEW, FINAL, AND CORRECT build() METHOD

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _minDimension = math.min(constraints.maxWidth, constraints.maxHeight);

        return SizedBox(
          width: _minDimension,
          height: _minDimension,
          child: Stack(
            // The Stack will contain both the circle and the text field
            children: [
              // Child 1: The animated circular slider.
              AnimatedBuilder(
                animation: Listenable.merge([
                  _valueAnimationController,
                  _sizeAnimationController,
                  _knobScaleAnimationController
                ]),
                builder: (context, child) {
                  final denormalizedValue =
                      _denormalizeValue(_valueAnimationController.value);

                  // This animates the alignment of the circle.
                  // When not editing, it's at the center.
                  // When editing, it moves to the TOP of the Stack.
                  final alignment = Alignment.lerp(
                    Alignment.center, // Start position
                    Alignment.topCenter, // End position
                    _sizeAnimationController.value,
                  )!;

                  return Align(
                    alignment: alignment,
                    child: Transform.scale(
                      scale: _sizeAnimation.value,
                      child: SizedBox(
                        width: _minDimension,
                        height: _minDimension,
                        child: GestureDetector(
                          onTapDown: _isEditing
                              ? null
                              : (_) => _knobScaleAnimationController?.forward(),
                          onTapUp: _isEditing
                              ? null
                              : (_) => _knobScaleAnimationController?.reverse(),
                          onTapCancel: _isEditing
                              ? null
                              : () => _knobScaleAnimationController?.reverse(),
                          onPanStart: _isEditing
                              ? null
                              : (d) {
                                  setState(() => _isDragging = true);
                                  _knobScaleAnimationController?.forward();
                                  widget.onChangeStart?.call();
                                  _handlePanUpdate(d.localPosition,
                                      Size(_minDimension, _minDimension));
                                },
                          onPanUpdate: _isEditing
                              ? null
                              : (d) => _handlePanUpdate(d.localPosition,
                                  Size(_minDimension, _minDimension)),
                          onPanEnd: _isEditing
                              ? null
                              : (_) {
                                  setState(() => _isDragging = false);
                                  _knobScaleAnimationController?.reverse();
                                  widget.onChangeEnd?.call();
                                },
                          child: CustomPaint(
                            size: Size(_minDimension, _minDimension),
                            painter: _CircularSliderPainter(
                              value: _valueAnimationController.value,
                              gradientColors: widget.gradientColors,
                              ringThickness: widget.ringThickness,
                              knobRadius: widget.knobRadius,
                              knobScale: _knobScaleAnimation?.value ?? 1.0,
                              isEditing: _isEditing,
                              knobColor: widget.knobColor ?? Colors.white,
                              knobShadows: widget.knobShadows,
                              ringBackgroundColor: widget.ringBackgroundColor ??
                                  Colors.grey.withOpacity(0.2),
                              labelText: widget.labelText,
                              labelStyle: widget.labelStyle,
                              innerLabelText: widget.innerLabelText,
                              innerLabelStyle: widget.innerLabelStyle,
                            ),
                            child: Center(
                                child: _buildCenterContent(denormalizedValue)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Child 2: The text input field.
              // This is permanently aligned to the BOTTOM of the Stack.
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildCustomInput(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenterContent(double value) {
    // CRITICAL FIX: Do not update the text controller's value from the slider
    // animation while the user is actively editing.
    if (!_isEditing && !_focusNode.hasFocus) {
      // This formatting logic should only run when the slider is in display mode.
      final formattedValue = value.toStringAsFixed(widget.decimalPrecision);
      // Only schedule an update if the text actually changed to prevent
      // unnecessary controller mutations during the build phase which can
      // indirectly trigger setState/markNeedsBuild exceptions.
      if (_textController.text != formattedValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Double-check conditions because build may have changed by the
          // time this callback runs.
          if (!mounted) return;
          if (_isEditing || _focusNode.hasFocus) return;
          _setText(formattedValue);
        });
      }
    }

    return GestureDetector(
      onTap: () => _toggleEditMode(),
      child: AnimatedOpacity(
        opacity: _isEditing ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: _buildCenterText(value),
      ),
    );
  }

  /// Calculates the appropriate font size based on the number of digits in the input
  /// Returns a smaller font size for longer numbers to prevent overflow
  double _getFontSizeForDigits(String text) {
    final int digitCount = text
        .replaceAll('.', '')
        .replaceAll('-', '')
        .length; // Count digits excluding decimal point and minus sign

    if (digitCount <= 3) {
      return 50.0;
    } else if (digitCount <= 5) {
      return 42.0;
    } else if (digitCount <= 7) {
      return 36.0;
    } else if (digitCount <= 9) {
      return 30.0;
    } else {
      return 24.0;
    }
  }

  Widget _buildCustomInput() {
    final fontSize = _getFontSizeForDigits(_textController.text);

    return AnimatedOpacity(
      opacity: _isEditing ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !_isEditing,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.prefix,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: fontSize * widget.prefixScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              IntrinsicWidth(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.left,
                  showCursor: false,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  // Use numberWithOptions for decimal input
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  // Add inputFormatters to allow only numbers and a single decimal point
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _toggleEditMode(forceState: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterText(double value) {
    /* ... Same as before ... */
    final displayValue = value.toStringAsFixed(widget.decimalPrecision);
    final fontSize = 48.0;
    return Padding(
      padding: EdgeInsets.all(widget.ringThickness + widget.knobRadius),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        textBaseline: TextBaseline.alphabetic,
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
}

class _CircularSliderPainter extends CustomPainter {
  final double value;
  final List<Color> gradientColors;
  final double ringThickness;
  final double knobRadius;
  final double knobScale;
  final Color knobColor;
  final List<BoxShadow>? knobShadows;
  final Color ringBackgroundColor;
  final String? labelText;
  final TextStyle? labelStyle;
  // Add inner label properties to painter
  final String? innerLabelText;
  final TextStyle? innerLabelStyle;
  final bool? isEditing;

  _CircularSliderPainter({
    required this.value,
    required this.gradientColors,
    required this.ringThickness,
    required this.knobRadius,
    required this.knobScale,
    required this.knobColor,
    this.knobShadows,
    required this.ringBackgroundColor,
    this.labelText,
    this.isEditing,
    this.labelStyle,
    // Add to constructor
    this.innerLabelText,
    this.innerLabelStyle,
  });

  Color _getColorAtValue(double value, List<Color> colors) {
    if (value <= 0.0) {
      return colors.first;
    }
    if (value >= 1.0) {
      return colors.last;
    }

    // Assumes colors are evenly distributed.
    // For more complex gradients with 'stops', the logic would be more involved.
    final position = value * (colors.length - 1);
    final fromIndex = position.floor();
    final toIndex = position.ceil();
    final t = position - fromIndex;

    if (fromIndex == toIndex) {
      return colors[fromIndex];
    }

    return Color.lerp(colors[fromIndex], colors[toIndex], t)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - knobRadius;

    // Draw the background ring
    final backgroundPaint = Paint()
      ..color = ringBackgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringThickness
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);

    // --- Conditional Painting Logic ---
    if (value > 0.001) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        // Use Butt, as we are drawing our own caps. This prevents the
        // default rounded cap from slightly overdrawing our custom ones.
        ..strokeCap = StrokeCap.butt;

      final fullSweep = 2 * math.pi * value;
      final gapAngle = math.min(0.12, (ringThickness / (radius + 1)) * 1.2);
      final sweepAngle =
          (value >= 0.999) ? math.max(0.0, fullSweep - gapAngle) : fullSweep;

      // --- FIX: Create a gradient that spans the full circle ---
      // This ensures the color is consistent at any angle, regardless of the sweep.
      // The rotation is adjusted to start the gradient at the top.
      final shader = SweepGradient(
        colors: gradientColors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
      arcPaint.shader = shader;

      // The start angle for drawing the arc remains at the top.
      const startAngle = -math.pi / 2;
      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

      // --- Draw circles at the start and end of the arc ---
      final endAngle = startAngle + sweepAngle;
      final startPoint = Offset(
        center.dx + radius * math.cos(startAngle),
        center.dy + radius * math.sin(startAngle),
      );
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      // The start color is always the first color in the list.
      final startCirclePaint = Paint()..color = gradientColors.first;

      // --- FIX: The end color is calculated based on the current value ---
      // This ensures the end cap color perfectly matches the gradient.
      final endCirclePaint = Paint()
        ..color = _getColorAtValue(value, gradientColors);

      canvas.drawCircle(startPoint, ringThickness / 2, startCirclePaint);
      canvas.drawCircle(endPoint, ringThickness / 2, endCirclePaint);
    }

    // --- The rest of the paint method remains the same ---

    final angle = -math.pi / 2 + (2 * math.pi * value);
    final knobOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    final scaledKnobRadius = knobRadius * knobScale;
    (knobShadows ??
            [
              BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 20,
                  offset: const Offset(0, 1))
            ])
        .forEach((shadow) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.solid, shadow.blurRadius);
      canvas.drawCircle(
          knobOffset + shadow.offset, scaledKnobRadius, shadowPaint);
    });
    final knobPaint = Paint()..color = knobColor;
    canvas.drawCircle(knobOffset, scaledKnobRadius, knobPaint);

    if (labelText != null && labelText!.isNotEmpty && !isEditing!) {
      _drawCircularText(canvas, size, center, radius);
    }
    if (innerLabelText != null && innerLabelText!.isNotEmpty && !isEditing!) {
      _drawInnerCircularText(canvas, size, center, radius);
    }
  }

  // Adaptive method for OUTER text
  void _drawCircularText(
      Canvas canvas, Size size, Offset center, double radius) {
    final style = labelStyle ??
        TextStyle(
            color: Colors.grey.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5);
    final textRadius = radius + ringThickness / 2 + 12;
    final chars = labelText!.split('');
    double totalArcWidth = 0;
    final List<TextPainter> painters = [];
    for (final char in chars) {
      final painter = TextPainter(
          text: TextSpan(text: char, style: style),
          textDirection: TextDirection.ltr)
        ..layout();
      painters.add(painter);
      totalArcWidth += painter.width;
    }
    final totalAngle = totalArcWidth / textRadius;
    final startAngle = -math.pi / 2 - totalAngle / 2;
    double currentAngle = startAngle;
    for (final painter in painters) {
      final charAngle = painter.width / textRadius;
      final angleForCharCenter = currentAngle + charAngle / 2;
      final position = Offset(
          center.dx + textRadius * math.cos(angleForCharCenter),
          center.dy + textRadius * math.sin(angleForCharCenter));
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angleForCharCenter + math.pi / 2);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
      currentAngle += charAngle;
    }
  }

  // NEW, CORRECTED METHOD (Inner Bottom, Readable and Facing Center)
  void _drawInnerCircularText(
      Canvas canvas, Size size, Offset center, double radius) {
    // Use a default style if none is provided
    final style = innerLabelStyle ??
        TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 10,
          fontWeight: FontWeight.normal,
          letterSpacing: 2, // Spacing for clarity
        );

    // Position the text inside the main ring
    final textRadius = radius - ringThickness;

    final chars = innerLabelText!.split('');
    if (chars.isEmpty) return;

    // 1. Prepare painters for each character to calculate the total arc size.
    final List<TextPainter> painters = [];
    double totalArcWidth = 0;
    for (final char in chars) {
      final painter = TextPainter(
          text: TextSpan(text: char, style: style),
          textDirection: TextDirection.ltr)
        ..layout();
      painters.add(painter);
      totalArcWidth += painter.width;
    }
    final totalAngle = totalArcWidth / textRadius;

    // 2. Center the text block at the 6 o'clock position.
    final startAngle = math.pi / 2 - totalAngle / 2;

    // 3. Iterate through the painters IN REVERSE ORDER. This is the key to readability.
    double currentAngle = startAngle;
    for (final painter in painters.reversed) {
      // Calculate the angle for the center of the current character.
      final charAngle = painter.width / textRadius;
      final angleForCharCenter = currentAngle + charAngle / 2;
      final position = Offset(
        center.dx + textRadius * math.cos(angleForCharCenter),
        center.dy + textRadius * math.sin(angleForCharCenter),
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);

      // 4. Rotate the character so its "top" points towards the circle's center.
      canvas.rotate(angleForCharCenter - math.pi / 2);

      // 5. Paint the character, offsetting to center it correctly.
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height));
      canvas.restore();

      // Move the angle cursor for the next character (which is the previous one in the string).
      currentAngle += charAngle;
    }
  }

  @override
  bool shouldRepaint(_CircularSliderPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.gradientColors != gradientColors ||
      oldDelegate.ringThickness != ringThickness ||
      oldDelegate.knobRadius != knobRadius ||
      oldDelegate.knobScale != knobScale ||
      oldDelegate.knobColor != knobColor ||
      oldDelegate.labelText != labelText ||
      // Add repaint check for inner label and editing state
      oldDelegate.innerLabelText != innerLabelText ||
      oldDelegate.innerLabelStyle != innerLabelStyle ||
      oldDelegate.isEditing != isEditing;
}
