// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;

void main() async {
  const _bucket = 'hatiku-4c1de.appspot.com';
  const _baseUrl = 'https://firebasestorage.googleapis.com/v0/b/$_bucket/o';
  final path = 'v2/alkitab';
  final encodedPrefix = Uri.encodeComponent(path.endsWith('/') ? path : '$path/');
  final url = '$_baseUrl?prefix=$encodedPrefix';
  print('URL: $url');
  
  final response = await http.get(Uri.parse(url));
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
