import 'dart:developer';
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
  bool _openFailed = false;

  bool get hasSource => _alias != null;
  bool get isReady => hasSource && !_openFailed;

  Future<bool> setAsset(String assetPath) async {
    if (!Platform.isWindows) return false;
    await stop();
    _openFailed = false;
    try {
      final file = await _copyAssetToFile(assetPath);
      _alias = 'gys_midi_${DateTime.now().microsecondsSinceEpoch}';
      _send('open "${file.path}" type sequencer alias $_alias');
      return true;
    } catch (e) {
      _openFailed = true;
      _alias = null;
      log('Windows MIDI setAsset failed: $e', name: 'WindowsMidiPlayer');
      return false;
    }
  }

  Future<bool> play() async {
    final alias = _alias;
    if (!Platform.isWindows || alias == null || _openFailed) return false;
    try {
      _send('play $alias');
      return true;
    } catch (e) {
      log('Windows MIDI play failed: $e', name: 'WindowsMidiPlayer');
      return false;
    }
  }

  Future<void> pause() async {
    final alias = _alias;
    if (!Platform.isWindows || alias == null || _openFailed) return;
    try {
      _send('pause $alias');
    } catch (e) {
      log('Windows MIDI pause failed: $e', name: 'WindowsMidiPlayer');
    }
  }

  Future<void> stop() async {
    final alias = _alias;
    if (!Platform.isWindows || alias == null) return;
    try {
      _send('stop $alias');
      _send('close $alias');
    } catch (e) {
      log('Windows MIDI stop failed: $e', name: 'WindowsMidiPlayer');
    } finally {
      _alias = null;
      _openFailed = false;
    }
  }

  String? getMode() {
    final alias = _alias;
    if (!Platform.isWindows || alias == null || _openFailed) return null;
    try {
      return _send('status $alias mode').trim().toLowerCase();
    } catch (e) {
      return null;
    }
  }

  int? getPositionMs() {
    final alias = _alias;
    if (!Platform.isWindows || alias == null || _openFailed) return null;
    try {
      return int.tryParse(_send('status $alias position').trim());
    } catch (e) {
      return null;
    }
  }

  int? getLengthMs() {
    final alias = _alias;
    if (!Platform.isWindows || alias == null || _openFailed) return null;
    try {
      return int.tryParse(_send('status $alias length').trim());
    } catch (e) {
      return null;
    }
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

  _MciSendStringDart? get _mciFunction {
    if (_mciSendString != null) return _mciSendString;
    try {
      _winmm = DynamicLibrary.open('winmm.dll');
      _mciSendString = _winmm!
          .lookupFunction<_MciSendStringNative, _MciSendStringDart>(
              'mciSendStringW');
      return _mciSendString;
    } catch (e) {
      log('Failed to load winmm.dll: $e', name: 'WindowsMidiPlayer');
      return null;
    }
  }

  String _send(String command) {
    final function = _mciFunction;
    if (function == null) {
      throw StateError('winmm.dll not available');
    }
    final commandPointer = command.toNativeUtf16();
    final returnPointer = calloc<Uint16>(256);
    try {
      final result =
          function(commandPointer, returnPointer.cast<Utf16>(), 256, 0);
      final message = returnPointer.cast<Utf16>().toDartString();
      if (result != 0) {
        throw StateError(
            'MCI command failed ($result): $command — $message');
      }
      return message;
    } finally {
      calloc.free(commandPointer);
      calloc.free(returnPointer);
    }
  }
}
