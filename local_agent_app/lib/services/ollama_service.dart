import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434';
  final http.Client _client;

  OllamaService({http.Client? client}) : _client = client ?? http.Client();

  /// Streams the AI response chunk by chunk so the user doesn't have to wait.
  Stream<String> sendMessageStream({
    required String model,
    required List<Map<String, String>> messages,
  }) async* {
    final url = Uri.parse('$_baseUrl/api/chat');
    
    final request = http.Request('POST', url);
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'model': model,
      'messages': messages,
      'stream': true, // Tell Ollama to stream the response
    });

    try {
      final response = await _client.send(request);
      
      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw OllamaException('API returned status ${response.statusCode}: $body');
      }

      // Read the response stream line by line
      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());
      
      await for (final line in stream) {
        if (line.trim().isEmpty) continue;
        try {
          final data = jsonDecode(line) as Map<String, dynamic>;
          final message = data['message'] as Map<String, dynamic>?;
          if (message != null && message.containsKey('content')) {
            // Yield each chunk of text as it arrives
            yield message['content'] as String;
          }
        } catch (_) {
          // Ignore parse errors on partial lines
        }
      }
    } on http.ClientException catch (e) {
      throw OllamaException(
        'Could not connect to Ollama. Is it running on $_baseUrl?\n'
        'Error: ${e.message}',
      );
    } catch (e) {
      if (e is OllamaException) rethrow;
      throw OllamaException('Unexpected error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class OllamaException implements Exception {
  final String message;
  OllamaException(this.message);
  @override
  String toString() => message;
}
