import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:church/domain/entity/pastel_preset/pastel_preset.dart';

void main() {
  group('PastelPreset', () {
    test('skyBlue preset has correct values', () {
      final preset = pastelPresets.firstWhere((p) => p.key == 'skyBlue');
      expect(preset.key, 'skyBlue');
      expect(preset.label, 'Sky Blue');
      expect(preset.primary, const Color(0xFF93C5FD));
      expect(preset.container, const Color(0xFFDBEAFE));
      expect(preset.surface, const Color(0xFFF8FAFC));
    });

    test('mintGreen preset has correct values', () {
      final preset = pastelPresets.firstWhere((p) => p.key == 'mintGreen');
      expect(preset.key, 'mintGreen');
      expect(preset.label, 'Mint Green');
      expect(preset.primary, const Color(0xFF6EE7B7));
    });

    test('all presets have valid colors', () {
      for (final preset in pastelPresets) {
        expect((preset.primary.a * 255.0).round().clamp(0, 255), greaterThan(0));
        expect((preset.container.a * 255.0).round().clamp(0, 255), greaterThan(0));
        expect((preset.surface.a * 255.0).round().clamp(0, 255), greaterThan(0));
      }
    });

    test('all presets have unique keys', () {
      final keys = pastelPresets.map((p) => p.key).toList();
      expect(keys.toSet().length, keys.length);
    });
  });
}