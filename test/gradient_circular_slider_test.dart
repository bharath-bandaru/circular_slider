import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradient_circular_slider/gradient_circular_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';

extension _WidgetTesterX on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(widget);
    await pump();
    await pump(const Duration(milliseconds: 1));
  }
}

void main() {
  group('GradientCircularSlider', () {
    testWidgets('creates widget with required parameters',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('displays initial value correctly',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 42.5,
              decimalPrecision: 1,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('42.5'), findsWidgets);
      expect(find.text(r'$'), findsWidgets);
    });

    testWidgets('displays custom prefix correctly',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 75,
              prefix: '%',
              decimalPrecision: 0,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('75'), findsWidgets);
      expect(find.text('%'), findsWidgets);
    });

    testWidgets('displays label text when provided',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              labelText: 'TEST LABEL',
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
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

      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              minValue: minValue,
              maxValue: maxValue,
              initialValue: initialValue,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
      expect(find.text('50.00'), findsWidgets);
    });

    testWidgets('calls onChanged callback when dragged',
        (WidgetTester tester) async {
      double? changedValue;

      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: GradientCircularSlider(
                  initialValue: 50,
                  animationDuration: Duration.zero,
                  initialSweepAnimationDuration: Duration.zero,
                  onChanged: (value) {
                    changedValue = value;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final sliderFinder = find.byType(GradientCircularSlider);
      await tester.drag(sliderFinder, const Offset(0, -40));
      await tester.pump();

      expect(changedValue, isNotNull);
    });

    testWidgets('calls onChangeStart and onChangeEnd callbacks',
        (WidgetTester tester) async {
      bool startCalled = false;
      bool endCalled = false;

      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: GradientCircularSlider(
                  initialValue: 50,
                  animationDuration: Duration.zero,
                  initialSweepAnimationDuration: Duration.zero,
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

      final sliderFinder = find.byType(GradientCircularSlider);
      await tester.drag(sliderFinder, const Offset(0, -40));
      await tester.pump();
      expect(startCalled, isTrue);
      expect(endCalled, isTrue);
    });

    testWidgets('respects decimal precision setting',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: GradientCircularSlider(
                    initialValue: 42.123456,
                    decimalPrecision: 0,
                    animationDuration: Duration.zero,
                    initialSweepAnimationDuration: Duration.zero,
                  ),
                ),
                SizedBox(
                  width: 250,
                  height: 250,
                  child: GradientCircularSlider(
                    initialValue: 42.123456,
                    decimalPrecision: 3,
                    animationDuration: Duration.zero,
                    initialSweepAnimationDuration: Duration.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('42'), findsWidgets);
      expect(find.text('42.123'), findsWidgets);
    });

    testWidgets('applies custom text color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              textColor: customColor,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      final richText = tester.widget<AutoSizeText>(find.byType(AutoSizeText));
      expect(richText, isNotNull);
    });

    testWidgets('accepts multiple gradient colors',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              gradientColors: const [Colors.red, Colors.blue, Colors.green],
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('handles empty label text gracefully',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              labelText: null,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('applies custom ring thickness', (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              ringThickness: 30,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('applies custom knob radius', (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              knobRadius: 20,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsOneWidget);
    });

    testWidgets('handles Indian Rupee symbol correctly',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 5000,
              maxValue: 10000,
              prefix: '₹',
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('₹'), findsWidgets);
      expect(find.text('5000.00'), findsWidgets);
    });

    testWidgets('animates value changes', (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 0,
              animationDuration: const Duration(milliseconds: 300),
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('0.00'), findsWidgets);

      // Update with new value
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 100,
              animationDuration: const Duration(milliseconds: 300),
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      // Pump for animation
      await tester.pump(const Duration(milliseconds: 150));
      // The value should be animating, not instantly at 100

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('100.00'), findsWidgets);
    });

    testWidgets('widget adapts to available size', (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: GradientCircularSlider(
                    initialValue: 50,
                    animationDuration: Duration.zero,
                    initialSweepAnimationDuration: Duration.zero,
                  ),
                ),
                SizedBox(
                  width: 400,
                  height: 400,
                  child: GradientCircularSlider(
                    initialValue: 50,
                    animationDuration: Duration.zero,
                    initialSweepAnimationDuration: Duration.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GradientCircularSlider), findsNWidgets(2));
    });

    testWidgets('prefix scale affects prefix size',
        (WidgetTester tester) async {
      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: GradientCircularSlider(
              initialValue: 50,
              prefix: '%',
              prefixScale: 0.5,
              animationDuration: Duration.zero,
              initialSweepAnimationDuration: Duration.zero,
            ),
          ),
        ),
      );

      final centerRowFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Row &&
            widget.mainAxisAlignment == MainAxisAlignment.center &&
            widget.children.length == 2,
      );
      final centerPrefixFinder =
          find.descendant(of: centerRowFinder, matching: find.text('%'));
      final Text centerPrefix = tester.widget<Text>(centerPrefixFinder);
      expect(centerPrefix.style?.fontSize, closeTo(48 * 0.5, 0.01));

      expect(find.text('50.00'), findsWidgets);
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
