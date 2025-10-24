import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradient_circular_slider/gradient_circular_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() {
  group('GradientCircularSlider', () {
    testWidgets('creates widget with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('displays initial value correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 42.5,
              decimalPrecision: 1,
            ),
          ),
        ),
      );

      expect(find.text('42.5'), findsOneWidget);
      expect(find.text(r'$'), findsOneWidget);
    });

    testWidgets('displays custom prefix correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 75,
              prefix: '%',
              decimalPrecision: 0,
            ),
          ),
        ),
      );

      expect(find.text('75'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('displays label text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              labelText: 'TEST LABEL',
            ),
          ),
        ),
      );

      // The label is drawn character by character in a circular arc
      // So we check if the CustomPaint widget is present
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('respects min and max values', (WidgetTester tester) async {
      const minValue = 10.0;
      const maxValue = 90.0;
      const initialValue = 50.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              minValue: minValue,
              maxValue: maxValue,
              initialValue: initialValue,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);
    });

    testWidgets('calls onChanged callback when dragged', (WidgetTester tester) async {
      double? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: GradientCircularSlider(
                  initialValue: 50,
                  onChanged: (value) {
                    changedValue = value;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Find the widget and simulate a drag
      final gesture = await tester.startGesture(const Offset(150, 50));
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();

      expect(changedValue, isNotNull);
    });

    testWidgets('calls onChangeStart and onChangeEnd callbacks', (WidgetTester tester) async {
      bool startCalled = false;
      bool endCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: GradientCircularSlider(
                  initialValue: 50,
                  onChangeStart: () {
                    startCalled = true;
                  },
                  onChangeEnd: () {
                    endCalled = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Start and end a drag gesture
      final gesture = await tester.startGesture(const Offset(150, 50));
      await tester.pump();
      expect(startCalled, isTrue);

      await gesture.up();
      await tester.pump();
      expect(endCalled, isTrue);
    });

    testWidgets('respects decimal precision setting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GradientCircularSlider(
                  initialValue: 42.123456,
                  decimalPrecision: 0,
                ),
                GradientCircularSlider(
                  initialValue: 42.123456,
                  decimalPrecision: 3,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.text('42.123'), findsOneWidget);
    });

    testWidgets('applies custom text color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              textColor: customColor,
            ),
          ),
        ),
      );

      final richText = tester.widget<AutoSizeText>(find.byType(AutoSizeText));
      expect(richText, isNotNull);
    });

    testWidgets('accepts multiple gradient colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              gradientColors: [Colors.red, Colors.blue, Colors.green],
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('handles empty label text gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              labelText: null,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('applies custom ring thickness', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              ringThickness: 30,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('applies custom knob radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              knobRadius: 20,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('handles Indian Rupee symbol correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 5000,
              prefix: '₹',
            ),
          ),
        ),
      );

      expect(find.text('₹'), findsOneWidget);
      expect(find.text('5000.00'), findsOneWidget);
    });

    testWidgets('animates value changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 0,
              animationDuration: Duration(milliseconds: 300),
            ),
          ),
        ),
      );

      expect(find.text('0.00'), findsOneWidget);

      // Update with new value
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 100,
              animationDuration: Duration(milliseconds: 300),
            ),
          ),
        ),
      );

      // Pump for animation
      await tester.pump(const Duration(milliseconds: 150));
      // The value should be animating, not instantly at 100

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('100.00'), findsOneWidget);
    });

    testWidgets('widget adapts to available size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: GradientCircularSlider(
                    initialValue: 50,
                  ),
                ),
                SizedBox(
                  width: 400,
                  height: 400,
                  child: GradientCircularSlider(
                    initialValue: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsNWidgets(2));
    });

    testWidgets('prefix scale affects prefix size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              prefix: '%',
              prefixScale: 0.5,
            ),
          ),
        ),
      );

      expect(find.text('%'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);
    });
  });

  group('GradientCircularSlider assertions', () {
    test('throws when minValue >= maxValue', () {
      expect(
        () => GradientCircularSlider(
          minValue: 100,
          maxValue: 50,
          initialValue: 75,
        ),
        throwsAssertionError,
      );
    });

    test('throws when initialValue is out of range', () {
      expect(
        () => GradientCircularSlider(
          minValue: 0,
          maxValue: 100,
          initialValue: 150,
        ),
        throwsAssertionError,
      );

      expect(
        () => GradientCircularSlider(
          minValue: 0,
          maxValue: 100,
          initialValue: -10,
        ),
        throwsAssertionError,
      );
    });

    test('throws when gradientColors has less than 2 colors', () {
      expect(
        () => GradientCircularSlider(
          initialValue: 50,
          gradientColors: const [Colors.blue],
        ),
        throwsArgumentError,
      );
    });

    test('throws when ringThickness is not positive', () {
      expect(
        () => GradientCircularSlider(
          initialValue: 50,
          ringThickness: 0,
        ),
        throwsAssertionError,
      );

      expect(
        () => GradientCircularSlider(
          initialValue: 50,
          ringThickness: -10,
        ),
        throwsAssertionError,
      );
    });

    test('throws when prefixScale is out of range', () {
      expect(
        () => GradientCircularSlider(
          initialValue: 50,
          prefixScale: 0,
        ),
        throwsAssertionError,
      );

      expect(
        () => GradientCircularSlider(
          initialValue: 50,
          prefixScale: 1.5,
        ),
        throwsAssertionError,
      );
    });

    test('throws when decimalPrecision is negative', () {
      expect(
        () => GradientCircularSlider(
          initialValue: 50,
          decimalPrecision: -1,
        ),
        throwsAssertionError,
      );
    });

    test('throws when knobRadius is not positive', () {
      expect(
        () => GradientCircularSlider(
          initialValue: 50,
          knobRadius: 0,
        ),
        throwsAssertionError,
      );

      expect(
        () => GradientCircularSlider(
          initialValue: 50,
          knobRadius: -5,
        ),
        throwsAssertionError,
      );
    });
  });
}