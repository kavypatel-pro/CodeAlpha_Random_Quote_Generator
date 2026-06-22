import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class AnthropicService {
  static const String _endpoint = 'https://api.anthropic.com/v1/messages';

  bool _isGeminiKey(String key) {
    return key.startsWith('AQ.') || key.startsWith('AIza');
  }

  Future<http.Response> _makePostRequest(String apiKey, String model, String prompt) async {
    return await http.post(
      Uri.parse(_endpoint),
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: json.encode({
        'model': model,
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    ).timeout(const Duration(seconds: 15));
  }

  Future<Quote> generatePersonalizedQuote(List<String> interests) async {
    final apiKey = dotenv.env['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'mock_anthropic_api_key_for_testing') {
      throw const AnthropicException('Invalid API Key: Please configure ANTHROPIC_API_KEY in your .env file.');
    }

    if (interests.isEmpty) {
      interests = ['Motivation', 'Success', 'Life'];
    }

    final interestsStr = interests.join(', ');

    if (_isGeminiKey(apiKey)) {
      return await _generateGeminiQuote(apiKey, interestsStr);
    } else {
      return await _generateAnthropicQuote(apiKey, interestsStr);
    }
  }

  Future<Quote> _generateGeminiQuote(String apiKey, String interestsStr) async {
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
    final prompt = 'Generate one unique inspirational quote based on these interests: '
        '$interestsStr. Return ONLY valid JSON in this format: '
        '{ "text": "Quote text here", "author": "AI-curated" }';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'content-type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json'
          }
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final candidates = responseData['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw const AnthropicException('Received empty candidates array from Gemini API.');
        }

        final content = candidates[0]['content'];
        if (content == null) {
          throw const AnthropicException('Received empty content in Gemini candidate.');
        }

        final parts = content['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw const AnthropicException('Received empty parts from Gemini API.');
        }

        final String textResponse = parts[0]['text'] as String? ?? '';
        if (textResponse.trim().isEmpty) {
          throw const AnthropicException('Received empty text response from Gemini API.');
        }

        return _parseQuoteJson(textResponse);
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        throw AnthropicException('Authentication or API error: Gemini API returned status code ${response.statusCode}. Details: ${response.body}');
      } else {
        throw AnthropicException('Gemini API Request failed with status code ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw AnthropicException('Network Connection Error: $e');
    } catch (e) {
      if (e is AnthropicException) rethrow;
      throw AnthropicException('An unexpected error occurred during Gemini AI curation: $e');
    }
  }

  Future<Quote> _generateAnthropicQuote(String apiKey, String interestsStr) async {
    final prompt = 'Generate one unique inspirational quote based on these interests: '
        '$interestsStr. Return ONLY valid JSON in this format: '
        '{ "text": "Quote text here", "author": "AI-curated" }';

    try {
      var response = await _makePostRequest(apiKey, 'claude-sonnet-4-6', prompt);

      // Model name fallback logic (if claude-sonnet-4-6 is invalid/unsupported by Anthropic)
      if (response.statusCode == 400) {
        try {
          final Map<String, dynamic> errData = json.decode(response.body);
          final errMsg = errData['error']?['message']?.toString() ?? '';
          if (errMsg.contains('model') || response.body.contains('not_found_error')) {
            response = await _makePostRequest(apiKey, 'claude-3-5-sonnet-20241022', prompt);
          }
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final contentList = responseData['content'] as List?;
        if (contentList == null || contentList.isEmpty) {
          throw const AnthropicException('Received empty content array from Anthropic API.');
        }

        final String textResponse = contentList[0]['text'] as String? ?? '';
        if (textResponse.trim().isEmpty) {
          throw const AnthropicException('Received empty text body from Anthropic API.');
        }

        return _parseQuoteJson(textResponse);
      } else if (response.statusCode == 401) {
        throw const AnthropicException('Unauthorized: The Anthropic API key is invalid.');
      } else if (response.statusCode == 429) {
        throw const AnthropicException('Rate Limit Reached: Too many requests to the Anthropic API. Please try again later.');
      } else {
        throw AnthropicException('Anthropic API Request failed with status code ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw AnthropicException('Network Connection Error: $e');
    } catch (e) {
      if (e is AnthropicException) rethrow;
      throw AnthropicException('An unexpected error occurred during Anthropic AI curation: $e');
    }
  }

  Quote _parseQuoteJson(String textResponse) {
    try {
      String cleanedText = textResponse.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      final Map<String, dynamic> parsedJson = json.decode(cleanedText);
      final quoteText = parsedJson['text'] as String? ?? '';
      final quoteAuthor = parsedJson['author'] as String? ?? 'AI-curated';

      if (quoteText.isEmpty) {
        throw const AnthropicException('Parsed JSON is missing the quote "text" field.');
      }

      return Quote(
        text: quoteText,
        author: quoteAuthor,
        category: 'AI Personalization',
      );
    } catch (e) {
      throw AnthropicException('JSON parsing error on AI response: $e\nResponse text: $textResponse');
    }
  }
}

class AnthropicException implements Exception {
  final String message;
  const AnthropicException(this.message);

  @override
  String toString() => message;
}

