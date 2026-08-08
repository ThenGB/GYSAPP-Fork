import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart';

class EncryptedAssetPackageService {
  static const _headerMagic = 'GYSPKG1';
  // NOTE: this key is obfuscation-only (static, shipped in the client) and
  // MUST NOT be relied on for confidentiality — the real tamper protection
  // is the mandatory SHA-256 checksum verified before install plus HTTPS.
  static final Key _key = Key.fromBase64(
    'yrvxIa8zgtn6cxTLH/+BsLjx5SrgGRQN7IVhK0ufB1Y=',
  );

  Future<void> installPackage({
    required File packageFile,
    required File destinationFile,
  }) async {
    final bytes = await packageFile.readAsBytes();
    final payload = await decodePackageOrCopy(bytes);
    await destinationFile.parent.create(recursive: true);
    await destinationFile.writeAsBytes(payload, flush: true);
  }

  /// Decodes a downloaded package (raw bytes) into installable asset bytes.
  ///
  /// Handles both the encrypted GYSPKG1 format and plain payloads. This is
  /// the web-compatible entry point — it never touches the file system.
  Future<Uint8List> installPackageBytes(Uint8List bytes) async {
    return decodePackageOrCopy(bytes);
  }

  Future<Uint8List> decodePackageOrCopy(Uint8List bytes) async {
    Uint8List payload;
    if (bytes.length >= _headerMagic.length &&
        String.fromCharCodes(
              bytes.sublist(0, _headerMagic.length),
            ) ==
            _headerMagic) {
      // Encrypted + GZip-compressed package (GYSPKG1 format).
      payload = await decodePackage(bytes);
    } else {
      // Unencrypted package (e.g. a raw SoundFont file downloaded
      // directly from a GitHub release).  Just copy the bytes.
      payload = bytes;
    }
    return payload;
  }

  Uint8List buildPackageBytesForTesting(Uint8List payload) {
    return buildPackageBytes(payload);
  }

  Uint8List buildPackageBytes(Uint8List payload) {
    final compressed = Uint8List.fromList(GZipEncoder().encode(payload));
    final ivBytes = Uint8List.fromList(
      List<int>.generate(16, (_) => Random.secure().nextInt(256)),
    );
    final iv = IV(ivBytes);
    final encrypted = Encrypter(AES(_key)).encryptBytes(compressed, iv: iv).bytes;
    final builder = BytesBuilder(copy: false);
    builder.add(_headerMagic.codeUnits);
    builder.add(ivBytes);
    builder.add(encrypted);
    return builder.toBytes();
  }

  Future<Uint8List> decodePackage(Uint8List bytes) async {
    final headerBytes = bytes.sublist(0, _headerMagic.length);
    final header = String.fromCharCodes(headerBytes);
    if (header != _headerMagic) {
      throw const FormatException('Invalid asset package header.');
    }

    final ivOffset = _headerMagic.length;
    final iv = IV(bytes.sublist(ivOffset, ivOffset + 16));
    final encryptedBytes = bytes.sublist(ivOffset + 16);
    final decrypted = Encrypter(AES(_key)).decryptBytes(
      Encrypted(encryptedBytes),
      iv: iv,
    );
    final output = GZipDecoder().decodeBytes(decrypted);
    return Uint8List.fromList(output);
  }
}
