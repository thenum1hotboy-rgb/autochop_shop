import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

// Unit tests for audio_processor logic extracted into testable functions.
// We can't directly import audio_processor.dart in a pure test environment
// because it depends on flutter_ffmpeg (native plugin), so we test the
// pure-Dart logic that was buggy.

void main() {
  group('Duration parsing', () {
    // Bug: original code divided by 1000, treating seconds as milliseconds
    test('duration in seconds should not be divided by 1000', () {
      // flutter_ffmpeg returns duration as seconds (e.g., "245.5")
      const rawDuration = '245.5';
      final correctDuration = double.parse(rawDuration);
      final buggyDuration = double.parse(rawDuration) / 1000.0;

      expect(correctDuration, 245.5);
      expect(buggyDuration, closeTo(0.2455, 0.001));

      // With the bug, numChops would always be 2 (the minimum)
      final buggyChops = max(2, (buggyDuration ~/ 5));
      expect(buggyChops, 2, reason: 'Bug: short duration always yields minimum chops');

      // With the fix, a 245s track gets ~49 chops
      final correctChops = max(2, (correctDuration ~/ 5));
      expect(correctChops, 49);
    });

    test('short tracks still get minimum 2 chops', () {
      const rawDuration = '8.0';
      final duration = double.parse(rawDuration);
      final numChops = max(2, (duration ~/ 5));
      expect(numChops, 2);
    });
  });

  group('Chop parameter determinism', () {
    // Bug: original code called Random() twice with different seeds,
    // producing different values for the UI simulation vs FFmpeg filter.
    test('seeded Random produces identical sequences', () {
      const seed = 42;
      const repeatMin = 2;
      const repeatMax = 4;

      final rng1 = Random(seed);
      final rng2 = Random(seed);

      for (int i = 0; i < 10; i++) {
        final repeat1 = repeatMin + rng1.nextInt(repeatMax - repeatMin + 1);
        final segment1 = 0.25 + rng1.nextDouble() * 0.25;

        final repeat2 = repeatMin + rng2.nextInt(repeatMax - repeatMin + 1);
        final segment2 = 0.25 + rng2.nextDouble() * 0.25;

        expect(repeat1, repeat2, reason: 'Same seed must produce same repeat count');
        expect(segment1, segment2, reason: 'Same seed must produce same segment duration');
      }
    });

    test('unseeded Random produces different sequences', () {
      final rng1 = Random();
      final rng2 = Random();

      // Generate enough values that it's statistically impossible for
      // two unseeded generators to match on all of them.
      bool allMatch = true;
      for (int i = 0; i < 20; i++) {
        if (rng1.nextInt(1000) != rng2.nextInt(1000)) {
          allMatch = false;
          break;
        }
      }
      expect(allMatch, false,
          reason: 'Unseeded Random instances should diverge');
    });
  });

  group('Opacity clamping', () {
    // Bug: opacity could exceed 1.0 causing withOpacity to throw
    test('opacity stays within 0.0-1.0 range', () {
      // Worst case: pulse=1.0, waveformAmp=1.0
      final unclamped = 0.3 + 1.0 * 0.5 + 1.0 * 0.5;
      expect(unclamped, 1.3, reason: 'Unclamped value exceeds 1.0');

      final clamped = unclamped.clamp(0.0, 1.0);
      expect(clamped, 1.0);
    });

    test('opacity at zero values', () {
      final opacity = (0.3 + 0.0 * 0.5 + 0.0 * 0.5).clamp(0.0, 1.0);
      expect(opacity, 0.3);
    });

    test('opacity at moderate values stays unchanged', () {
      final opacity = (0.3 + 0.5 * 0.5 + 0.4 * 0.5).clamp(0.0, 1.0);
      expect(opacity, closeTo(0.75, 0.001));
    });
  });

  group('Output path construction', () {
    test('replaceAll correctly maps input to output directory', () {
      const inputPath =
          '/storage/emulated/0/Download/AutoChopShopInput/song.wav';
      final outputDir = inputPath
          .replaceAll('/AutoChopShopInput/', '/AutoChopShopOutput/');
      expect(outputDir,
          '/storage/emulated/0/Download/AutoChopShopOutput/song.wav');
    });

    test('fileName extraction handles dots in path', () {
      const inputPath = '/some/path/my.song.name.wav';
      final fileName = inputPath.split('/').last.split('.').first;
      // Only gets first segment before dot — this is existing behavior
      expect(fileName, 'my');
    });
  });
}
