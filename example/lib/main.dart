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
  double _currentValue = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Custom Styled Slider',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 350,
              child: GradientCircularSlider(
                minValue: 0,
                maxValue: 70,
                initialValue: _currentValue,
                gradientColors: const [
                  Color(0xFFFFD700),
                  Color(0xFFFF6B6B),
                  Color(0xFF4ECDC4),
                ],
                // Outer label (at the top)
                labelText: "TAP TO ENTER AMOUNT VALUE",
                labelStyle: TextStyle(
                  color: Colors.amber.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                // NEW: Inner label (at the bottom)
                innerLabelText: "DRAG OR TAP TO EDIT",
                innerLabelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 2.5,
                ),
                prefix: "₹",
                prefixScale: 0.7,
                decimalPrecision: 0,
                ringThickness: 32,
                knobRadius: 24,
                textColor: Colors.amber,
                ringBackgroundColor: Colors.grey.shade800,
                knobColor: Colors.amber,
                knobShadows: const [
                  BoxShadow(
                    color: Color.fromARGB(113, 255, 255, 255),
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
              'Value: ₹${_currentValue.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
