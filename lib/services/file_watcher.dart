import 'dart:io';

class FileWatcher {
  static Future<void> ensureFoldersExist() async {
    final input = Directory('/storage/emulated/0/Download/AutoChopShopInput/');
    final output = Directory('/storage/emulated/0/Music/AutoChopShopOutput/');

    if (!await input.exists()) await input.create(recursive: true);
    if (!await output.exists()) await output.create(recursive: true);
  }

  static void watchInputFolder(Function(List<String>) callback) async {
    await ensureFoldersExist();

    final folder = Directory('/storage/emulated/0/Download/AutoChopShopInput/');

    folder.watch().listen((event) {
      final files = folder
          .listSync()
          .whereType<File>()
          .map((f) => f.path)
          .toList();
      callback(files);
    });

    final files = folder.listSync().whereType<File>().map((f) => f.path).toList();
    callback(files);
  }
}