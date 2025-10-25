import 'package:flutter/material.dart';
import 'lib/gradient_circular_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradient Circular Slider Test',
      theme: ThemeData.dark(),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  double _value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Gradient Circular Slider Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: GradientCircularSlider(
                minValue: 0,
                maxValue: 100,
                initialValue: _value,
                gradientColors: const [
                  Color(0xFF00A8E8),
                  Color(0xFF00FF7F),
                ],
                labelText: "DRAG HANDLE",
                prefix: "%",
                prefixScale: 0.6,
                decimalPrecision: 1,
                enableHaptics: true,
                onChanged: (val) {
                  setState(() {
                    _value = val;
                  });
                  debugPrint('Value: ${val.toStringAsFixed(1)}%');
                },
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Current Value: ${_value.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _value == 0
                  ? 'Knob at START (top center)'
                  : _value >= 99.9
                      ? 'Knob at END (top center)'
                      : 'Knob at ${(_value * 3.6).toStringAsFixed(0)}°',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _value = 0;
                });
              },
              child: const Text('Reset to 0%'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _value = 50;
                });
              },
              child: const Text('Set to 50%'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _value = 100;
                });
              },
              child: const Text('Set to 100%'),
            ),
          ],
        ),
      ),
    );
  }
}
