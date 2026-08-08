/// Range conversion helpers shared by font/chord/lyrics sliders.
///
/// Both the bottom-sheet font picker and the dedicated font-settings page used
/// to define their own copies of these two functions; keeping a single source
/// here avoids drift between the two UIs.
library;

/// Maps [value] (in [minValue]..[maxValue]) to a 0..1 slider fraction.
double convertToPercentage(double value, double minValue, double maxValue) =>
    ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);

/// Maps a 0..1 slider fraction back to the [minValue]..[maxValue] range.
double convertToValue(double percentage, double minValue, double maxValue) =>
    (percentage * (maxValue - minValue)) + minValue;
