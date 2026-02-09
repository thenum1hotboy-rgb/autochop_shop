import 'dart:io';
import 'dart:math';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

typedef ChopCallback = void Function();

class AudioProcessor {
  static final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  static Future<void> processWav(String inputPath,
      {ChopCallback? onChop, String preset = 'Houston Screw'}) async {
    final outputDir = inputPath
        .replaceAll('/AutoChopShopInput/', '/AutoChopShopOutput/');
    final fileName = inputPath.split('/').last.split('.').first;
    final outputPath = '$outputDir/${fileName} - $preset.wav';

    await Directory(outputDir).create(recursive: true);

    double atempo = 0.75;
    double pitch = 0.85;
    int repeatMin = 2, repeatMax = 4;

    switch (preset) {
      case 'Houston Screw':
        atempo = 0.75; pitch = 0.85; repeatMin = 2; repeatMax = 4; break;
      case 'Deep Screw':
        atempo = 0.65; pitch = 0.80; repeatMin = 3; repeatMax = 5; break;
      case 'Chop Heavy':
        atempo = 0.85; pitch = 0.90; repeatMin = 4; repeatMax = 6; break;
      case 'Light Chop':
        atempo = 0.90; pitch = 0.95; repeatMin = 2; repeatMax = 3; break;
      case 'Club Screw':
        atempo = 0.80; pitch = 0.88; repeatMin = 2; repeatMax = 4; break;
    }

    String tempScrewed = '$outputDir/temp_screwed.wav';
    String screwingCmd =
        '-i "$inputPath" -filter:a "atempo=$atempo,asetrate=44100*$pitch,aresample=44100" "$tempScrewed"';
    await _ffmpeg.execute(screwingCmd);

    final duration = await _getDuration(tempScrewed);

    int numChops = max(2, (duration ~/ 5));
    List<double> chopPositions = [];
    for (int i = 0; i < numChops; i++) {
      chopPositions.add(duration * (0.08 + 0.08 * i));
    }

    // Use a seeded Random so the UI simulation and FFmpeg filter use
    // identical chop parameters.
    final seed = DateTime.now().millisecondsSinceEpoch;
    final rng = Random(seed);

    // Pre-compute chop parameters once so both the UI callback loop and
    // the FFmpeg filter construction use the same values.
    List<int> repeatCounts = [];
    List<double> segmentDurations = [];
    for (int i = 0; i < chopPositions.length; i++) {
      repeatCounts.add(repeatMin + rng.nextInt(repeatMax - repeatMin + 1));
      segmentDurations.add(0.25 + rng.nextDouble() * 0.25);
    }

    // UI chop simulation
    for (int i = 0; i < chopPositions.length; i++) {
      for (int r = 0; r < repeatCounts[i]; r++) {
        if (onChop != null) onChop();
        await Future.delayed(
            Duration(milliseconds: (segmentDurations[i] * 1000).toInt()));
      }
    }

    // Build FFmpeg filter using the same pre-computed parameters
    String filter = '';
    for (int i = 0; i < chopPositions.length; i++) {
      double pos = chopPositions[i];
      filter +=
          "[0:a]atrim=start=${pos.toStringAsFixed(2)}:end=${(pos + segmentDurations[i]).toStringAsFixed(2)},aloop=loop=${repeatCounts[i] - 1}:size=2e+09[a$i];";
    }

    String inputs =
        List.generate(chopPositions.length, (i) => "[a$i]").join();
    String finalCmd =
        '-i "$tempScrewed" -filter_complex "$filter $inputs concat=n=${chopPositions.length}:v=0:a=1[out]" -map "[out]" "$outputPath"';
    await _ffmpeg.execute(finalCmd);
    await File(tempScrewed).delete();
  }

  static Future<double> _getDuration(String filePath) async {
    double duration = 0.0;
    await _ffmpeg.getMediaInformation(filePath).then((info) {
      final d = info.getMediaProperties()?['duration'];
      // flutter_ffmpeg returns duration in seconds, not milliseconds
      if (d != null) duration = double.parse(d.toString());
    });
    return duration;
  }
}
