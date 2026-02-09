import 'package:flutter/material.dart';
import '../services/file_watcher.dart';
import '../services/audio_processor.dart';
import 'settings_screen.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> files = [];
  double pulse = 0.0;
  double waveformAmp = 0.0;
  String selectedPreset = 'Houston Screw';
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _waveformTimer;
  StreamSubscription? _playerCompleteSubscription;

  bool batchPreviewMode = false;
  int batchIndex = 0;

  @override
  void initState() {
    super.initState();
    FileWatcher.watchInputFolder((newFiles) {
      setState(() => files = newFiles);
    });
  }

  void _triggerPulse() {
    setState(() => pulse = 1.0);
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) setState(() => pulse = 0.0);
    });
  }

  void _startProcessing() async {
    for (var file in files) {
      await AudioProcessor.processWav(file,
          preset: selectedPreset, onChop: _triggerPulse);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Processing Complete!")),
    );
  }

  void _playPreview(String filePath) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(filePath));

    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      if (mounted) {
        setState(() {
          waveformAmp = 0.2 + Random().nextDouble() * 0.8;
        });
      }
    });

    // Cancel any previous completion listener to prevent listener leak
    _playerCompleteSubscription?.cancel();
    if (batchPreviewMode) {
      _playerCompleteSubscription =
          _audioPlayer.onPlayerComplete.listen((event) {
        batchIndex++;
        if (batchIndex < files.length) {
          _playPreview(files[batchIndex]);
        } else {
          _stopBatchPreview();
        }
      });
    }
  }

  void _startBatchPreview() {
    if (files.isEmpty) return;
    batchPreviewMode = true;
    batchIndex = 0;
    _playPreview(files[batchIndex]);
  }

  void _stopBatchPreview() {
    batchPreviewMode = false;
    _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = null;
    _audioPlayer.stop();
    _waveformTimer?.cancel();
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    _waveformTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(
                  painter: StarfieldPainter(pulse, waveformAmp))),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text("AutoChop Shop"),
                  backgroundColor: Colors.deepPurple[900]?.withOpacity(0.8),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SettingsScreen()));
                        })
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (_, i) => ListTile(
                      title: Text(files[i].split('/').last,
                          style: TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: Icon(Icons.play_arrow, color: Colors.cyanAccent),
                        onPressed: () => _playPreview(files[i]),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        value: selectedPreset,
                        items: [
                          'Houston Screw',
                          'Deep Screw',
                          'Chop Heavy',
                          'Light Chop',
                          'Club Screw'
                        ]
                            .map((p) => DropdownMenuItem(
                                value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedPreset = val!),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _startProcessing,
                        child: Text("Start AutoChop"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _startBatchPreview,
                        child: Text("Batch Preview (DJ Mode)"),
                      ),
                      ElevatedButton(
                        onPressed: _stopBatchPreview,
                        child: Text("Stop Preview"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final double pulse;
  final double waveformAmp;
  final Random _rand = Random();
  StarfieldPainter(this.pulse, this.waveformAmp);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 200; i++) {
      double radius =
          _rand.nextDouble() * 2 + 1 + pulse * 2 + waveformAmp * 3;
      double opacity =
          (0.3 + pulse * 0.5 + waveformAmp * 0.5).clamp(0.0, 1.0);
      paint.color = Colors.blueAccent.withOpacity(opacity);
      canvas.drawCircle(
        Offset(_rand.nextDouble() * size.width,
            _rand.nextDouble() * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) => true;
}
