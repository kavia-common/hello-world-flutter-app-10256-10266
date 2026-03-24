import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:react_agent/features/react_agent/domain/chat_message.dart';
import 'package:react_agent/features/react_agent/services/openai_chat_service.dart';

class _FakeClient extends http.BaseClient {
  _FakeClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _handler(request);
}

void main() {
  test('OpenAIChatService surfaces HTTP status + parsed OpenAI error body', () async {
    final client = _FakeClient((request) async {
      final body = '''
      {
        "error": {
          "message": "Incorrect API key provided: sk-... You can find your API key at https://platform.openai.com/account/api-keys.",
          "type": "invalid_request_error",
          "code": "invalid_api_key"
        }
      }
      '''
          .trim();

      final stream = Stream<List<int>>.fromIterable(<List<int>>[body.codeUnits]);
      return http.StreamedResponse(
        stream,
        401,
        reasonPhrase: 'Unauthorized',
        headers: const {'content-type': 'application/json'},
      );
    });

    final svc = OpenAIChatService(apiKey: 'sk-invalid', httpClient: client);

    try {
      await svc.sendMessage(
        messages: const [ChatMessage(role: 'user', content: 'Hello')],
      );
      fail('Expected ChatGPTException to be thrown');
    } catch (e) {
      expect(e, isA<ChatGPTException>());
      final msg = (e as ChatGPTException).toString();

      // Must include HTTP status code and the OpenAI-provided message.
      expect(msg, contains('HTTP 401'));
      expect(msg, contains('Incorrect API key provided'));
      expect(msg, contains('code=invalid_api_key'));
    }
  });
}
