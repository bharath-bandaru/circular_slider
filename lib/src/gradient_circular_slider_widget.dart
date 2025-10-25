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
    if (_isUpdatingTextProgrammatically || !_isEditing) return;
    final newValue = double.tryParse(_textController.text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(widget.minValue, widget.maxValue);
      final normalizedValue = _normalizeValue(clampedValue);
      _valueAnimationController.animateTo(
        normalizedValue,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      widget.onChanged?.call(clampedValue);
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
        _sizeAnimationController.forward();
        _focusNode.requestFocus();
      } else {
        _sizeAnimationController.reverse();
        _focusNode.unfocus();
        final enteredValue = double.tryParse(_textController.text) ??
            _denormalizeValue(_valueAnimationController.value);
        _animateToValue(enteredValue);
      }
    });
  }

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
                animation: Listenable.merge(
                    [_valueAnimationController, _sizeAnimationController]),
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
                          onTap: () => _toggleEditMode(),
                          onPanStart: _isEditing
                              ? null
                              : (d) {
                                  setState(() => _isDragging = true);
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
                                  widget.onChangeEnd?.call();
                                },
                          child: CustomPaint(
                            size: Size(_minDimension, _minDimension),
                            painter: _CircularSliderPainter(
                              value: _valueAnimationController.value,
                              gradientColors: widget.gradientColors,
                              ringThickness: widget.ringThickness,
                              knobRadius: widget.knobRadius,
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
    /* ... Same as before ... */
    return AnimatedOpacity(
      opacity: _isEditing ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: _buildCenterText(value),
    );
  }

// UPDATED _buildCustomInput() METHOD for Bottom Alignment

  Widget _buildCustomInput() {
    return AnimatedOpacity(
      opacity: _isEditing ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !_isEditing,
        child: Padding(
          // Add padding to the BOTTOM so it doesn't sit on the absolute edge.
          padding: EdgeInsets.only(
              bottom: _minDimension * 0.03), // 3% proportional padding
          child: SizedBox(
            width: _minDimension * 0.5, // Proportional width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.prefix,
                  style: TextStyle(
                    color: widget.textColor.withOpacity(0.7),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AutoSizeTextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 18,
                    maxLines: 1,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
        crossAxisAlignment: CrossAxisAlignment.baseline,
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

// NEW, FINAL, AND CORRECT paint() METHOD

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

    // --- Unified Gradient Definition ---
    // Define the gradient and its rotation once. This ensures visual consistency.
    final rect = Rect.fromCircle(center: center, radius: radius);
    final angleCorrection = math.atan((ringThickness / 2) / radius);
    final gradientStartRotation = -math.pi / 2 - angleCorrection;
    final gradientShader = SweepGradient(
      colors: gradientColors,
      startAngle: 0,
      endAngle: 2 * math.pi,
      transform: GradientRotation(gradientStartRotation),
      tileMode: TileMode.clamp,
    ).createShader(rect);

    // --- Conditional Painting Logic ---

    // Case 1: The slider is full (or extremely close).
    if (value >= 0.999) {
      final fullCirclePaint = Paint()
        ..shader = gradientShader // Use the unified gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..strokeCap =
            StrokeCap.butt; // Use a butt cap to prevent overlap and seam

      // Draw a full circle. It's seamless by nature.
      canvas.drawCircle(center, radius, fullCirclePaint);
    }
    // Case 2: The slider has a value but is not full.
    else if (value > 0.001) {
      final arcPaint = Paint()
        ..shader = gradientShader // Use the same unified gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..strokeCap = StrokeCap.round; // Use a round cap for the arc ends

      // Draw the arc based on the value.
      final sweepAngle = 2 * math.pi * value;
      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, arcPaint);
    }

    // --- The rest of the paint method remains the same ---

    // Calculate and draw the knob
    final angle = -math.pi / 2 + (2 * math.pi * value);
    final knobOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    (knobShadows ??
            [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 1))
            ])
        .forEach((shadow) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.solid, shadow.blurRadius);
      canvas.drawCircle(knobOffset + shadow.offset, knobRadius, shadowPaint);
    });
    final knobPaint = Paint()..color = knobColor;
    canvas.drawCircle(knobOffset, knobRadius, knobPaint);

    // Call the drawing methods for both labels
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
      oldDelegate.knobColor != knobColor ||
      oldDelegate.labelText != labelText ||
      // Add repaint check for inner label
      oldDelegate.innerLabelText != oldDelegate.innerLabelText ||
      oldDelegate.isEditing != isEditing;
}
