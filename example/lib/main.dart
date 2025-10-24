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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  double _currentValue1 = 24343.43;
  double _currentValue2 = 50;
  double _currentValue3 = 75.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Gradient Circular Slider Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Example 1: Basic slider with dollar prefix
            Card(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Basic Slider with Dollar Prefix',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: GradientCircularSlider(
                        minValue: 0,
                        maxValue: 100000,
                        initialValue: _currentValue1,
                        gradientColors: const [
                          Color(0xFF00A8E8),
                          Color(0xFF00FF7F),
                        ],
                        labelText: "SLIDE ME",
                        prefix: r"$",
                        prefixScale: 0.6,
                        enableHaptics: true,
                        onChanged: (val) {
                          setState(() {
                            _currentValue1 = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Value: \$${_currentValue1.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Example 2: Percentage slider
            Card(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Percentage Slider',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: GradientCircularSlider(
                        minValue: 0,
                        maxValue: 100,
                        initialValue: _currentValue2,
                        gradientColors: const [
                          Colors.purple,
                          Colors.pink,
                          Colors.orange,
                        ],
                        labelText: "PERCENTAGE",
                        prefix: "%",
                        prefixScale: 0.5,
                        decimalPrecision: 0,
                        ringThickness: 25,
                        knobRadius: 18,
                        enableHaptics: true,
                        knobShadows: const [
                          BoxShadow(
                            color: Colors.purple,
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _currentValue2 = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Value: ${_currentValue2.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Example 3: Custom styled slider with Indian Rupee
            Card(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Custom Styled with Indian Rupee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: GradientCircularSlider(
                        minValue: 0,
                        maxValue: 1000000,
                        initialValue: _currentValue3 * 1000,
                        gradientColors: const [
                          Color(0xFFFFD700),
                          Color(0xFFFF6B6B),
                          Color(0xFF4ECDC4),
                        ],
                        labelText: "ADJUST AMOUNT",
                        prefix: "₹",
                        prefixScale: 0.7,
                        decimalPrecision: 0,
                        ringThickness: 30,
                        knobRadius: 20,
                        textColor: Colors.amber,
                        ringBackgroundColor: Colors.grey.shade800,
                        labelStyle: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                        knobColor: Colors.amber,
                        knobShadows: const [
                          BoxShadow(
                            color: Colors.amber,
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                        animationDuration: const Duration(milliseconds: 500),
                        animationCurve: Curves.easeOutCubic,
                        enableHaptics: true,
                        onChanged: (val) {
                          setState(() {
                            _currentValue3 = val / 1000;
                          });
                        },
                        onChangeStart: () {
                          debugPrint('Drag started');
                        },
                        onChangeEnd: () {
                          debugPrint('Drag ended');
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Value: ₹${(_currentValue3 * 1000).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Example 4: Minimal slider without label
            Card(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Minimal Slider (No Label)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: GradientCircularSlider(
                        minValue: 0,
                        maxValue: 10,
                        initialValue: 5.5,
                        gradientColors: const [
                          Colors.cyan,
                          Colors.blue,
                        ],
                        prefix: "",
                        decimalPrecision: 1,
                        ringThickness: 15,
                        knobRadius: 12,
                        textColor: Colors.cyan,
                        enableHaptics: false,
                        onChanged: (val) {
                          debugPrint('Minimal slider value: $val');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}