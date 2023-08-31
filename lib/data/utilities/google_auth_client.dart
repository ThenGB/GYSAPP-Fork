import 'package:http/http.dart';

class GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;
  final _client = Client();

  GoogleAuthClient(this._headers);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
