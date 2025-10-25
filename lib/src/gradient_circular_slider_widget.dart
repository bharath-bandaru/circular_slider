import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';

/// A beautiful circular slider widget with gradient progress and an editable value.
class GradientCircularSlider extends StatefulWidget {
  /// Optional controller to programmatically control the slider (for example
  /// to dismiss edit mode).
  final GradientCircularSliderController? controller;

  /// Minimum value representable by the slider.
  final double minValue;

  /// Maximum value representable by the slider.
  final double maxValue;

  /// Initial numeric value displayed when the widget builds.
  final double initialValue;

  /// Colors used to paint the progress arc gradient (at least two).
  final List<Color> gradientColors;

  /// Thickness of the circular ring in logical pixels.
  final double ringThickness;

  /// Optional prefix (such as a currency symbol) rendered before the value.
  final String prefix;

  /// Scale factor applied to the prefix text relative to the main value.
  final double prefixScale;

  /// Duration of the one-time sweep animation executed after build.
  final Duration initialSweepAnimationDuration;

  /// Whether to trigger haptic feedback when the user drags the knob.
  final bool enableHaptics;

  /// Color for the main numeric text displayed in the center.
  final Color textColor;

  /// Number of decimal places rendered for the current value.
  final int decimalPrecision;

  /// Callback invoked whenever the slider's value changes due to user input.
  final ValueChanged<double>? onChanged;

  /// Callback fired when the user starts dragging the knob.
  final VoidCallback? onChangeStart;

  /// Callback fired when the user stops dragging the knob.
  final VoidCallback? onChangeEnd;

  /// Shadows drawn behind the knob for depth.
  final List<BoxShadow>? knobShadows;

  /// Radius of the knob that the user drags.
  final double knobRadius;

  /// Explicit color for the knob; falls back to gradient end color if null.
  final Color? knobColor;

  /// Color of the inactive/background ring.
  final Color? ringBackgroundColor;

  /// Duration for animating programmatic value changes.
  final Duration animationDuration;

  /// Curve used for animating programmatic value changes.
  final Curve animationCurve;

  /// Optional label text displayed outside the slider.
  final String? labelText;

  /// Text style applied to [labelText].
  final TextStyle? labelStyle;

  /// Optional text rendered inside the slider but below the main value.
  final String? innerLabelText;

  /// Text style applied to [innerLabelText].
  final TextStyle? innerLabelStyle;

  /// Creates a gradient circular slider with customizable visuals and behavior.
  GradientCircularSlider({
    super.key,
    this.controller,
    this.minValue = 0,
    this.maxValue = 100,
    required this.initialValue,
    this.initialSweepAnimationDuration = const Duration(seconds: 0),
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
    this.innerLabelText,
    this.innerLabelStyle,
  })  : assert(minValue < maxValue, 'minValue must be less than maxValue'),
        assert(initialValue >= minValue && initialValue <= maxValue,
            'initialValue must be between minValue and maxValue'),
        assert(ringThickness > 0, 'ringThickness must be positive'),
        assert(prefixScale > 0 && prefixScale <= 1,
            'prefixScale must be between 0 and 1'),
        assert(decimalPrecision >= 0, 'decimalPrecision must be non-negative'),
        assert(knobRadius > 0, 'knobRadius must be positive'),
        assert(!initialSweepAnimationDuration.isNegative,
            'initialSweepAnimationDuration must be zero or positive') {
    if (gradientColors.length < 2) {
      throw ArgumentError('gradientColors must have at least 2 colors');
    }
  }

  @override
  State<GradientCircularSlider> createState() => _GradientCircularSliderState();
}

/// Controller that can be used to programmatically control a
/// [GradientCircularSlider]. Currently provides a `dismiss()` method which
/// forces the slider out of edit mode if it is editing.
class GradientCircularSliderController {
  VoidCallback? _dismissCallback;

  /// Force the slider to exit edit mode if it is currently in edit mode.
  void dismiss() => _dismissCallback?.call();

  void _bind(VoidCallback callback) {
    _dismissCallback = callback;
  }

  void _unbind() {
    _dismissCallback = null;
  }
}

const List<BoxShadow> _defaultKnobShadows = [
  BoxShadow(
    color: Color(0x19000000),
    blurRadius: 20,
    offset: Offset(0, 1),
  )
];

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
    widget.controller?._bind(() {
      if (mounted) _toggleEditMode(forceState: false);
    });
    _valueAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _normalizeValue(widget.minValue),
    );
    _sizeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _sizeAnimationController,
        curve: Curves.easeOut,
      ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleInitialSweep();
    });
  }

  @override
  void didUpdateWidget(GradientCircularSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind();
      widget.controller?._bind(() {
        if (mounted) _toggleEditMode(forceState: false);
      });
    }
    if (oldWidget.initialValue != widget.initialValue &&
        !_isDragging &&
        !_isEditing) {
      _animateToValue(widget.initialValue);
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind();
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
    if (_isUpdatingTextProgrammatically || !_isEditing) return;

    if (widget.decimalPrecision > 0) {
      final text = _textController.text;
      final decimalIndex = text.indexOf('.');
      if (decimalIndex != -1) {
        final decimals = text.length - decimalIndex - 1;
        if (decimals > widget.decimalPrecision) {
          final trimmedText =
              text.substring(0, decimalIndex + 1 + widget.decimalPrecision);
          final selectionBase = _textController.selection.baseOffset;
          final selectionOffset = selectionBase < 0
              ? trimmedText.length
              : math.min(trimmedText.length, selectionBase);
          _isUpdatingTextProgrammatically = true;
          _textController.value = TextEditingValue(
            text: trimmedText,
            selection: TextSelection.collapsed(offset: selectionOffset),
          );
          _isUpdatingTextProgrammatically = false;
        }
      }
    }

    final newValue = double.tryParse(_textController.text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(widget.minValue, widget.maxValue);
      final normalizedValue = _normalizeValue(clampedValue);
      _valueAnimationController.value = normalizedValue;
      widget.onChanged?.call(clampedValue);
    }
  }

  void _scheduleInitialSweep() {
    Future<void>.delayed(widget.initialSweepAnimationDuration, () {
      if (!mounted || _isDragging || _isEditing) return;
      _animateToValue(
        widget.initialValue,
        curveOverride: Curves.easeInOutCubic,
      );
    });
  }

  void _animateToValue(double denormalizedValue,
      {Curve? curveOverride, Duration? durationOverride}) {
    final clampedValue =
        denormalizedValue.clamp(widget.minValue, widget.maxValue);
    final normalizedValue = _normalizeValue(clampedValue);
    _valueAnimationController.animateTo(
      normalizedValue,
      duration: durationOverride ?? widget.animationDuration,
      curve: curveOverride ?? widget.animationCurve,
    );
    _setText(clampedValue.toStringAsFixed(widget.decimalPrecision));
  }

  void _toggleEditMode({bool? forceState}) {
    setState(() {
      _isEditing = forceState ?? !_isEditing;
      if (_isEditing) {
        _sizeAnimationController.forward();

        final currentValue = _denormalizeValue(_valueAnimationController.value);
        final valueForEditing =
            currentValue.toStringAsFixed(widget.decimalPrecision);
        _setText(valueForEditing);
        _focusNode.requestFocus();
      } else {
        _sizeAnimationController.reverse();
        _focusNode.unfocus();

        final enteredValue = double.tryParse(_textController.text) ??
            _denormalizeValue(_valueAnimationController.value);
        final double clampedValue =
            (enteredValue).clamp(widget.minValue, widget.maxValue);
        _animateToValue(clampedValue);
        widget.onChanged?.call(clampedValue);
      }
    });
  }

  bool _hasFiredMaxValueHaptic = false;

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
      if (!_hasFiredMaxValueHaptic) {
        HapticFeedback.mediumImpact();
      }
      _hasFiredMaxValueHaptic = true;
    }
    if (newNormalizedValue < 1.0) {
      _hasFiredMaxValueHaptic = false;
    }

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _minDimension = math.min(constraints.maxWidth, constraints.maxHeight);

        return SizedBox(
          width: _minDimension,
          height: _minDimension,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  _valueAnimationController,
                  _sizeAnimationController,
                  _knobScaleAnimationController
                ]),
                builder: (context, child) {
                  final denormalizedValue =
                      _denormalizeValue(_valueAnimationController.value);

                  final alignment = Alignment.lerp(
                    Alignment.center,
                    Alignment.topCenter,
                    _sizeAnimationController.value,
                  )!;

                  return Align(
                    alignment: alignment,
                    child: Transform.scale(
                      scale: _sizeAnimation.value,
                      alignment: Alignment.center,
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
                                  Colors.grey.withAlpha(51),
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
    if (!_isEditing && !_focusNode.hasFocus) {
      final formattedValue = value.toStringAsFixed(widget.decimalPrecision);
      if (_textController.text != formattedValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final int digitCount = text.replaceAll('.', '').replaceAll('-', '').length;

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
    final allowNegativeValues = widget.minValue < 0;
    final textInputType = TextInputType.numberWithOptions(
      decimal: widget.decimalPrecision > 0,
      signed: allowNegativeValues,
    );
    final signPattern = allowNegativeValues ? '-?' : '';
    final RegExp inputFormatterPattern = widget.decimalPrecision == 0
        ? RegExp('^$signPattern\\d*\$')
        : RegExp('^$signPattern\\d*(\\.\\d*)?\$');

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 0),
      opacity: _isEditing ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 0),
        curve: Curves.easeInOut,
        offset: _isEditing ? Offset.zero : const Offset(0, 1),
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
                    keyboardType: textInputType,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(inputFormatterPattern),
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
      ),
    );
  }

  Widget _buildCenterText(double value) {
    final displayValue = value.toStringAsFixed(widget.decimalPrecision);
    const double fontSize = 48.0;
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
  final String? innerLabelText;
  final TextStyle? innerLabelStyle;
  final bool isEditing;

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
    required this.isEditing,
    this.labelStyle,
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

    final backgroundPaint = Paint()
      ..color = ringBackgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringThickness
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);

    if (value > 0.001) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..strokeCap = StrokeCap.butt;

      final fullSweep = 2 * math.pi * value;
      final gapAngle = math.min(0.12, (ringThickness / (radius + 1)) * 1.2);
      final sweepAngle =
          (value >= 0.999) ? math.max(0.0, fullSweep - gapAngle) : fullSweep;

      final shader = SweepGradient(
        colors: gradientColors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
      arcPaint.shader = shader;

      const startAngle = -math.pi / 2;
      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

      final endAngle = startAngle + sweepAngle;
      final startPoint = Offset(
        center.dx + radius * math.cos(startAngle),
        center.dy + radius * math.sin(startAngle),
      );
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final startCirclePaint = Paint()..color = gradientColors.first;

      final endCirclePaint = Paint()
        ..color = _getColorAtValue(value, gradientColors);

      canvas.drawCircle(startPoint, ringThickness / 2, startCirclePaint);
      canvas.drawCircle(endPoint, ringThickness / 2, endCirclePaint);
    }

    final angle = -math.pi / 2 + (2 * math.pi * value);
    final knobOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    if (!isEditing) {
      final scaledKnobRadius = knobRadius * knobScale;
      final shadows = knobShadows ?? _defaultKnobShadows;
      for (final shadow in shadows) {
        final shadowPaint = Paint()
          ..color = shadow.color
          ..maskFilter = MaskFilter.blur(BlurStyle.solid, shadow.blurRadius);
        canvas.drawCircle(
            knobOffset + shadow.offset, scaledKnobRadius, shadowPaint);
      }
      final knobPaint = Paint()..color = knobColor;
      canvas.drawCircle(knobOffset, scaledKnobRadius, knobPaint);
    }

    if (labelText != null && labelText!.isNotEmpty && !isEditing) {
      _drawCircularText(canvas, size, center, radius);
    }
    if (innerLabelText != null && innerLabelText!.isNotEmpty && !isEditing) {
      _drawInnerCircularText(canvas, size, center, radius);
    }
  }

  void _drawCircularText(
      Canvas canvas, Size size, Offset center, double radius) {
    final style = labelStyle ??
        TextStyle(
            color: Colors.grey.withAlpha(230),
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

  void _drawInnerCircularText(
      Canvas canvas, Size size, Offset center, double radius) {
    final style = innerLabelStyle ??
        TextStyle(
          color: Colors.white.withAlpha(128),
          fontSize: 10,
          fontWeight: FontWeight.normal,
          letterSpacing: 2,
        );

    final textRadius = radius - ringThickness;

    final chars = innerLabelText!.split('');
    if (chars.isEmpty) return;

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

    final startAngle = math.pi / 2 - totalAngle / 2;

    double currentAngle = startAngle;
    for (final painter in painters.reversed) {
      final charAngle = painter.width / textRadius;
      final angleForCharCenter = currentAngle + charAngle / 2;
      final position = Offset(
        center.dx + textRadius * math.cos(angleForCharCenter),
        center.dy + textRadius * math.sin(angleForCharCenter),
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);

      canvas.rotate(angleForCharCenter - math.pi / 2);

      painter.paint(canvas, Offset(-painter.width / 2, -painter.height));
      canvas.restore();

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
      oldDelegate.innerLabelText != innerLabelText ||
      oldDelegate.innerLabelStyle != innerLabelStyle ||
      oldDelegate.isEditing != isEditing;
}
