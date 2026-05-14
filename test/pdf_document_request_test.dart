import 'package:church/data/services/pdf_note_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'preserves the normalized source identity for cache-busting fragments',
    () {
      final request = PdfDocumentRequest.parse(
        r'C:\tmp\KR_0.pdf#page=1&pages=1&master=assets/data/pdf/kr/KR.pdf&v=123',
      );

      expect(request.assetPath, 'C:/tmp/KR_0.pdf');
      expect(request.startPage, 1);
      expect(request.pageCount, 1);
      expect(request.isFile, isTrue);
      expect(
        request.sourceId,
        'C:/tmp/KR_0.pdf#page=1&pages=1&master=assets/data/pdf/kr/KR.pdf&v=123',
      );
    },
  );
}
