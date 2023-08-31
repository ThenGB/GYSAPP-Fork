import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart';

import '../../di/injection.dart';

class EncryptData {
  final AppDirectory appDirectory;
  final key = Key.fromBase64('yrvxIa8zgtn6cxTLH/+BsLjx5SrgGRQN7IVhK0ufB1Y=');
  late final encrypter = Encrypter(AES(key));
  final iv = IV.fromLength(16);

  EncryptData(this.appDirectory);

  Future<File> encryptFile(File file) async {
    var bytes = await file.readAsBytes();
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    final cachedFile =
        File('${appDirectory.encryptFolder}/${basename(file.path)}');
    cachedFile.createSync(recursive: true);
    await cachedFile.writeAsString(encrypted.base64);
    return cachedFile;
  }

  Future<File> decryptFile(File encoded) async {
    var bytes = await encoded.readAsString();
    var decrypted = encrypter.decryptBytes(Encrypted.fromBase64(bytes), iv: iv);
    final cachedFile =
        File('${appDirectory.decryptFolder}/${basename(encoded.path)}');
    cachedFile.createSync(recursive: true);
    await cachedFile.writeAsBytes(decrypted);
    return cachedFile;
  }
}
