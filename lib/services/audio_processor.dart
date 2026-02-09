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

    // Chopping simulation
    final duration = await _getDuration(tempScrewed);
    int numChops = max(2, (duration ~/ 5));
    for (int i = 0; i < numChops; i++) {
      if (onChop != null) onChop();
      await Future.delayed(Duration(milliseconds: 300));
    }

    // Copy temp to final
    await File(tempScrewed).copy(outputPath);
    await File(tempScrewed).delete();
  }

  static Future<double> _getDuration(String filePath) async {
    double duration = 0.0;
    await _ffmpeg.getMediaInformation(filePath).then((info) {
      final d = info.getMediaProperties()?['duration'];
      if (d != null) duration = double.parse(d.toString()) / 1000.0;
    });
    return duration;
  }
}