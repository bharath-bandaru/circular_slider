import 'package:flutter/material.dart';
import 'package:gradient_circular_slider/gradient_circular_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradient Circular Slider Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  double _currentValue = 6.34;
  final GradientCircularSliderController _controller =
      GradientCircularSliderController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    setState(() {
      _isEditing = _controller.isEditing;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    super.dispose();
  }
  // (global key removed — no longer needed with GestureDetector/unfocus approach)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // A simple, reliable approach: unfocus the current focus node which
          // causes the slider to exit edit mode (the widget listens to focus
          // loss). This avoids low-level pointer math and should be sufficient
          // for most apps. If you prefer a modal barrier approach, we can
          // implement that instead.
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              SizedBox(
                height: 250,
                child: GradientCircularSlider(
                  controller: _controller,
                  minValue: 0,
                  editModeInputSpacing: 20,
                  enableHaptics: false,
                  initialSweepAnimationDuration:
                      const Duration(milliseconds: 500),
                  maxValue: 101.99,
                  initialValue: _currentValue,
                  gradientColors: const [
                    Color(0xFFFFD700),
                    Color(0xFFFF6B6B),
                    Color(0xFF4ECDC4),
                  ],
                  // Outer label (at the top)
                  labelText: "TAP TO ENTER AMOUNT VALUE",
                  labelStyle: TextStyle(
                    color: Colors.amber.withAlpha(153),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                  // NEW: Inner label (at the bottom)
                  innerLabelText: "DRAG OR TAP TO EDIT",
                  innerLabelStyle: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 2.5,
                  ),
                  prefix: "₹",
                  prefixScale: 0.5,
                  decimalPrecision: 2,
                  ringThickness: 27,
                  knobRadius: 16,
                  textColor: Colors.amber,
                  ringBackgroundColor: Colors.grey.shade800,
                  knobColor: Colors.amber,
                  knobShadows: const [
                    BoxShadow(
                      color: Color.fromARGB(112, 0, 0, 0),
                      blurRadius: 5,
                      spreadRadius: 3,
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _currentValue = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isEditing ? 'Editing amount…' : 'Viewing amount',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Text(
                'Value: ₹${_currentValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
