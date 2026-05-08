import 'dart:typed_data';

class MidiTempoDetector {
  const MidiTempoDetector._();

  static double detectBpm(Uint8List bytes, {double fallbackBpm = 76}) {
    if (bytes.length < 14 || !_hasFourCc(bytes, 0, 'MThd')) {
      return fallbackBpm;
    }

    final headerLength = _readUint32(bytes, 4);
    final trackCount = _readUint16(bytes, 10);
    var offset = 8 + headerLength;

    for (
      var track = 0;
      track < trackCount && offset + 8 <= bytes.length;
      track++
    ) {
      if (!_hasFourCc(bytes, offset, 'MTrk')) return fallbackBpm;
      final trackLength = _readUint32(bytes, offset + 4);
      offset += 8;
      final end = (offset + trackLength).clamp(0, bytes.length).toInt();
      final bpm = _scanTrackForTempo(bytes, offset, end);
      if (bpm != null) return bpm;
      offset = end;
    }

    return fallbackBpm;
  }

  static double? _scanTrackForTempo(Uint8List bytes, int offset, int end) {
    var pos = offset;
    var runningStatus = 0;

    while (pos < end) {
      final delta = _readVariableLength(bytes, pos, end);
      pos = delta.nextOffset;
      if (pos >= end) break;

      var status = bytes[pos++];
      if (status < 0x80) {
        if (runningStatus == 0) return null;
        pos--;
        status = runningStatus;
      } else if (status < 0xF0) {
        runningStatus = status;
      }

      if (status == 0xFF) {
        if (pos >= end) break;
        final metaType = bytes[pos++];
        final length = _readVariableLength(bytes, pos, end);
        pos = length.nextOffset;
        if (metaType == 0x51 && length.value == 3 && pos + 3 <= end) {
          final microsecondsPerQuarter =
              (bytes[pos] << 16) | (bytes[pos + 1] << 8) | bytes[pos + 2];
          if (microsecondsPerQuarter > 0) {
            return 60000000 / microsecondsPerQuarter;
          }
        }
        pos += length.value;
        continue;
      }

      if (status == 0xF0 || status == 0xF7) {
        final length = _readVariableLength(bytes, pos, end);
        pos = length.nextOffset + length.value;
        continue;
      }

      final command = status & 0xF0;
      pos += (command == 0xC0 || command == 0xD0) ? 1 : 2;
    }

    return null;
  }

  static bool _hasFourCc(Uint8List bytes, int offset, String value) {
    if (offset + 4 > bytes.length) return false;
    final codeUnits = value.codeUnits;
    return bytes[offset] == codeUnits[0] &&
        bytes[offset + 1] == codeUnits[1] &&
        bytes[offset + 2] == codeUnits[2] &&
        bytes[offset + 3] == codeUnits[3];
  }

  static int _readUint16(Uint8List bytes, int offset) {
    if (offset + 2 > bytes.length) return 0;
    return (bytes[offset] << 8) | bytes[offset + 1];
  }

  static int _readUint32(Uint8List bytes, int offset) {
    if (offset + 4 > bytes.length) return 0;
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  static _VariableLength _readVariableLength(
    Uint8List bytes,
    int offset,
    int end,
  ) {
    var value = 0;
    var pos = offset;
    for (var i = 0; i < 4 && pos < end; i++) {
      final byte = bytes[pos++];
      value = (value << 7) | (byte & 0x7F);
      if ((byte & 0x80) == 0) break;
    }
    return _VariableLength(value, pos);
  }
}

class _VariableLength {
  final int value;
  final int nextOffset;

  const _VariableLength(this.value, this.nextOffset);
}
