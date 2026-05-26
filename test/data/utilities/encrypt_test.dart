import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:church/data/utilities/encrypt.dart';
import 'package:church/di/injection.dart';

void main() {
  late Directory tempDir;
  late AppDirectory appDirectory;
  late EncryptData encryptData;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('encrypt_test');

    final document = '${tempDir.path}/document';
    final cache = '${tempDir.path}/cache';
    final support = '${tempDir.path}/support';

    appDirectory = AppDirectory(document, cache, support);
    encryptData = EncryptData(appDirectory);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('encrypt and decrypt file successfully', () async {
    // Arrange
    final originalText = 'Hello, this is a secret message!';
    final sourceFile = File('${tempDir.path}/source.txt');
    await sourceFile.writeAsString(originalText);

    // Act
    final encryptedFile = await encryptData.encryptFile(sourceFile);

    // Validate that it's encrypted and saved as base64
    final encryptedText = await encryptedFile.readAsString();
    expect(encryptedText, isNot(contains(originalText)));
    expect(() => base64.decode(encryptedText), returnsNormally);

    // Act
    final decryptedFile = await encryptData.decryptFile(encryptedFile);
    final decryptedText = await decryptedFile.readAsString();

    // Assert
    expect(encryptedFile.existsSync(), isTrue);
    expect(decryptedFile.existsSync(), isTrue);
    expect(decryptedText, equals(originalText));
  });

  test('encrypt and decrypt image file (binary data)', () async {
    // Arrange
    final sourceFile = File('${tempDir.path}/image.png');
    // Create some dummy binary data
    final originalBytes = List.generate(256, (i) => i);
    await sourceFile.writeAsBytes(originalBytes);

    // Act
    final encryptedFile = await encryptData.encryptFile(sourceFile);

    // Check that it's base64 encoded string
    final encryptedText = await encryptedFile.readAsString();
    expect(() => base64.decode(encryptedText), returnsNormally);

    // Act
    final decryptedFile = await encryptData.decryptFile(encryptedFile);
    final decryptedBytes = await decryptedFile.readAsBytes();

    // Assert
    expect(encryptedFile.existsSync(), isTrue);
    expect(decryptedFile.existsSync(), isTrue);
    expect(decryptedBytes, equals(originalBytes));
  });

  test('encrypting large file works correctly', () async {
    // Arrange
    final sourceFile = File('${tempDir.path}/large.txt');
    // Create a larger file
    final largeText = 'A' * 1024 * 1024; // 1 MB of text
    await sourceFile.writeAsString(largeText);

    // Act
    final encryptedFile = await encryptData.encryptFile(sourceFile);
    final decryptedFile = await encryptData.decryptFile(encryptedFile);
    final decryptedText = await decryptedFile.readAsString();

    // Assert
    expect(decryptedText, equals(largeText));
  });
}
