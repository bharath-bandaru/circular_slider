# Gradient Circular Slider

[![pub package](https://img.shields.io/pub/v/gradient_circular_slider.svg)](https://pub.dev/packages/gradient_circular_slider)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A beautiful and customizable circular slider widget with gradient progress for Flutter applications. Perfect for creating intuitive and visually appealing value selectors with smooth animations and haptic feedback.

## Features

✨ **Beautiful Gradient Progress** - Smooth color transitions with customizable gradient colors
🎯 **Draggable Knob** - Interactive knob with shadow/glow effects that follows the circular path
📝 **Auto-Sizing Text** - Smart text sizing that fits perfectly within the circle
🎨 **Customizable Prefix** - Add currency symbols, percentages, or any prefix with scaling
🔤 **Circular Arc Labels** - Optional curved text labels following the circle's arc
📳 **Haptic Feedback** - Tactile feedback during interaction (configurable)
🎭 **Smooth Animations** - Animated transitions for programmatic value changes
🎨 **Fully Customizable** - Colors, sizes, styles, and behaviors are all configurable

## Installation

Add `gradient_circular_slider` to your `pubspec.yaml`:

```yaml
dependencies:
  gradient_circular_slider: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:gradient_circular_slider/gradient_circular_slider.dart';

GradientCircularSlider(
  minValue: 0,
  maxValue: 100,
  initialValue: 50,
  gradientColors: [Colors.blue, Colors.green],
  onChanged: (value) {
    print('Value: $value');
  },
)
```

### Advanced Example with Custom Styling

```dart
GradientCircularSlider(
  minValue: 0,
  maxValue: 100000,
  initialValue: 24343.43,
  gradientColors: [Color(0xFF00A8E8), Color(0xFF00FF7F)],
  labelText: "ADJUST AMOUNT",
  prefix: "\$",
  prefixScale: 0.6,
  ringThickness: 25,
  knobRadius: 18,
  textColor: Colors.white,
  ringBackgroundColor: Colors.grey.shade800,
  knobShadows: [
    BoxShadow(
      color: Colors.blue,
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ],
  labelStyle: TextStyle(
    color: Colors.grey,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
  ),
  enableHaptics: true,
  onChanged: (val) => print("Value: $val"),
  onChangeStart: () => print("Started dragging"),
  onChangeEnd: () => print("Stopped dragging"),
)
```

## Customization Options

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `minValue` | `double` | Minimum slider value | 0 |
| `maxValue` | `double` | Maximum slider value | 100 |
| `initialValue` | `double` | Starting value (required) | - |
| `gradientColors` | `List<Color>` | Colors for the circular gradient (min 2) | `[Colors.blue, Colors.green]` |
| `ringThickness` | `double` | Width of the circular ring | 20.0 |
| `prefix` | `String` | Symbol before the value (e.g., '$', '₹', '%') | '$' |
| `prefixScale` | `double` | Ratio of prefix font size to main font (0-1) | 0.6 |
| `labelText` | `String?` | Text shown on the top arc | null |
| `enableHaptics` | `bool` | Enable tactile feedback | true |
| `textColor` | `Color` | Color for central text | Colors.white |
| `labelStyle` | `TextStyle?` | Custom style for arc label | null |
| `decimalPrecision` | `int` | Number of decimal places | 2 |
| `knobRadius` | `double` | Size of the draggable knob | 15 |
| `knobColor` | `Color?` | Color of the knob | Colors.white |
| `knobShadows` | `List<BoxShadow>?` | Shadow effects for the knob | Default shadow |
| `ringBackgroundColor` | `Color?` | Background color of the ring | Colors.grey.shade300 |
| `animationDuration` | `Duration` | Duration for value animations | 300ms |
| `animationCurve` | `Curve` | Animation curve for transitions | Curves.easeInOut |

## Callbacks

| Callback | Type | Description |
|----------|------|-------------|
| `onChanged` | `ValueChanged<double>?` | Called when the value changes |
| `onChangeStart` | `VoidCallback?` | Called when dragging starts |
| `onChangeEnd` | `VoidCallback?` | Called when dragging ends |

## Examples

### Currency Selector
```dart
GradientCircularSlider(
  minValue: 0,
  maxValue: 10000,
  initialValue: 5000,
  gradientColors: [Colors.green, Colors.blue],
  prefix: "\$",
  labelText: "SELECT AMOUNT",
)
```

### Percentage Slider
```dart
GradientCircularSlider(
  minValue: 0,
  maxValue: 100,
  initialValue: 75,
  gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  prefix: "%",
  decimalPrecision: 0,
  labelText: "COMPLETION",
)
```

### Temperature Control
```dart
GradientCircularSlider(
  minValue: 16,
  maxValue: 30,
  initialValue: 22,
  gradientColors: [Colors.blue, Colors.red],
  prefix: "°",
  decimalPrecision: 1,
  labelText: "TEMPERATURE",
)
```

## Performance

The widget is optimized for smooth 60fps performance on all modern devices:
- Efficient rebuilds with only necessary repaints
- Hardware-accelerated rendering
- Optimized gesture detection
- Smooth animations with customizable curves

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created with ❤️ by Your Name

## Support

If you find this package helpful, please consider giving it a ⭐ on [GitHub](https://github.com/yourusername/gradient_circular_slider)!