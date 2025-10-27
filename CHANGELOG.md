# Changelog

## 1.0.6 - Sweep Duration Renames & Integer Snapping

- Renamed `animationDuration` to `sweepAnimationDuration` to better describe its role in value interpolation.
- Renamed `initialSweepAnimationDuration` to `initialSweepDelayDuration` to clarify it now governs the delay before the first sweep.
- Added the `isClampToInteger` flag to make drag gestures snap to whole-number values when desired.
- Updated the README to reflect the new API.

## 1.0.5 - Added editModeScaleFactor

- Add `editModeScaleFactor` to control how large the circle remains while editing.

## 1.0.4 - Added editModeInputSpacing and isEditing Listener

- Expose the slider's edit state through `GradientCircularSliderController.isEditing` and `Listenable` notifications.
- Update the example app and README to demonstrate reacting to edit mode changes.
- Document the `editModeInputSpacing` parameter in the README.


## 1.0.3 - Improve Documentation Coverage

- Updated License

## 1.0.2 - Improve Documentation Coverage

- Added detailed dartdoc comments for all primary public parameters and callbacks.
- Updated README installation instructions to reference the latest published version.

## 1.0.1 - Polish and Metadata Updates

- Tweaked package metadata and README details based on initial feedback.

## 1.0.0 - Initial Release

### Features
- ✨ Beautiful circular slider with gradient progress
- 🎯 Draggable knob with smooth interactions
- 📝 Auto-sizing center text display with customizable prefix
- 🎨 Fully customizable gradient colors
- 🔤 Optional circular arc label text
- 📳 Haptic feedback support
- 🎭 Smooth animations for programmatic value changes
- 💫 Shadow/glow effects for the knob
- 🎨 Customizable ring thickness, colors, and styles
- 📊 Support for various number formats and decimal precision
- 🌍 Support for currency symbols (USD, INR, EUR, etc.)
- ⚡ Optimized for 60fps performance

### Supported Parameters
- Min/max value configuration
- Custom gradient colors (2+ colors)
- Ring thickness customization
- Prefix text with scaling
- Circular arc labels
- Text color customization
- Decimal precision control
- Knob size and appearance
- Background ring color
- Animation duration and curves
- Callbacks for value changes

### Examples Included
- Basic usage
- Currency selector
- Percentage slider
- Temperature control
- Custom styling examples
