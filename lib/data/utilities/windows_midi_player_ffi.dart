import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

typedef _MciSendStringNative = Int32 Function(
  Pointer<Utf16> command,
  Pointer<Utf16> returnString,
  Uint32 returnLength,
  IntPtr callback,
);

typedef _MciSendStringDart = int Function(
  Pointer<Utf16> command,
  Pointer<Utf16> returnString,
  int returnLength,
  int callback,
);

class WindowsMidiPlayer {
  DynamicLibrary? _winmm;
  _MciSendStringDart? _mciSendString;
  String? _alias;

  bool get hasSource => _alias != null;

  Future<void> setAsset(String assetPath) async {
    if (!Platform.isWindows) return;
    await stop();
    final file = await _copyAssetToFile(assetPath);
    _alias = 'gys_midi_${DateTime.now().microsecondsSinceEpoch}';
    _send('open "${file.path}" type sequencer alias $_alias');
  }

  Future<void> play() async {
    final alias = _alias;
    if (!Platform.isWindows || alias == null) return;
    _send('play $alias');
  }

  Future<void> pause() async {
    final alias = _alias;
    if (!Platform.isWindows || alias == null) return;
    _send('pause $alias');
  }

  Future<void> stop() async {
    final alias = _alias;
    if (!Platform.isWindows || alias == null) return;
    _send('stop $alias');
    _send('close $alias');
    _alias = null;
  }

  Future<File> _copyAssetToFile(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final dir = await getTemporaryDirectory();
    final file =
        File(path.join(dir.path, 'gys_midi', path.basename(assetPath)));
    await file.parent.create(recursive: true);
    final existing = await file.exists() ? await file.readAsBytes() : null;
    if (existing == null || !_sameBytes(existing, bytes)) {
      await file.writeAsBytes(bytes, flush: true);
    }
    return file;
  }

  bool _sameBytes(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _send(String command) {
    final function = _mciSendString ??= (_winmm ??= DynamicLibrary.open(
      'winmm.dll',
    ))
        .lookupFunction<_MciSendStringNative, _MciSendStringDart>(
      'mciSendStringW',
    );
    final commandPointer = command.toNativeUtf16();
    final returnPointer = calloc<Uint16>(256);
    try {
      final result =
          function(commandPointer, returnPointer.cast<Utf16>(), 256, 0);
      final message = returnPointer.cast<Utf16>().toDartString();
      if (result != 0) {
        throw StateError('MCI command failed ($result): $command $message');
      }
      return message;
    } finally {
      calloc.free(commandPointer);
      calloc.free(returnPointer);
    }
  }
}
