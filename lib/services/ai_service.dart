import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_message.dart';
import '../utils/glm_config.dart';
import '../utils/env_config.dart';

class AIService {
  static final Map<String, List<Map<String, dynamic>>> _conversationContexts = {};
  static final Map<String, int> _responsePatterns = {};

  static Future<AIResponse> sendMessage(String message, {String? conversationId}) async {
    try {

      if (conversationId != null) {
        if (!_conversationContexts.containsKey(conversationId)) {
          _conversationContexts[conversationId] = [];
        }
        _conversationContexts[conversationId]!.add({
          'role': 'user',
          'content': message,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      final prompt = _buildIntelligentPrompt(message, conversationId);

      try {
        final response = await _sendToAI(prompt);
        if (response != null) {

          if (conversationId != null) {
            _conversationContexts[conversationId]!.add({
              'role': 'assistant',
              'content': response.content,
              'timestamp': DateTime.now().toIso8601String(),
            });
          }
          return response;
        }
      } catch (e) {
        print('❌ AI API failed: $e');
      }

      final fallbackResponse = _getContextualFallbackResponse(message, conversationId);

      if (conversationId != null) {
        _conversationContexts[conversationId]!.add({
          'role': 'assistant',
          'content': fallbackResponse.content,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      return fallbackResponse;
    } catch (e) {
      print('❌ Error in AI service: $e');
      return AIResponse(
        content: 'I apologize, but I\'m having trouble processing your request right now. Please try again in a moment.',
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<AIResponse?> _sendToAI(String prompt) async {

    final priorityEndpoints = ['gemini', 'palm', 'local'];

    for (final endpointName in priorityEndpoints) {
      try {
        print('🔄 Trying $endpointName...');
        final response = await _tryEndpoint(endpointName, prompt);
        if (response != null) {
          print('✅ Success with $endpointName');
          return response;
        }
      } catch (e) {
        print('❌ $endpointName API failed: $e');
        continue;
      }
    }

    print('⚠️ All AI endpoints failed, using fallback responses');
    return null;
  }

  static Future<AIResponse?> _tryEndpoint(String endpointName, String prompt) async {
    final config = GLMConfig.getEndpoint(endpointName);
    if (config == null) return null;

    try {

      final headers = Map<String, String>.from(config['headers']);
      if (endpointName == 'gemini') {
        final apiKey = EnvConfig.geminiApiKey;
        final url = '${config['url']}?key=$apiKey';
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(_buildRequestBody(endpointName, prompt, config)),
        );
        return _handleResponse(response, endpointName, config);
      } else {
        final response = await http.post(
          Uri.parse(config['url']),
          headers: headers,
          body: jsonEncode(_buildRequestBody(endpointName, prompt, config)),
        );
        return _handleResponse(response, endpointName, config);
      }
    } catch (e) {
      print('❌ $endpointName API error: $e');
      return null;
    }
  }

  static Future<AIResponse?> _handleResponse(http.Response response, String endpointName, Map<String, dynamic> config) async {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = _extractContent(data, endpointName);

        if (content.isNotEmpty) {
          return AIResponse(
            content: _cleanAIResponse(content),
            metadata: {
              'model': config['model'],
              'source': '$endpointName-api',
            },
          );
        }
      } else {
        print('❌ $endpointName API error: ${response.statusCode} - ${response.body}');
      }

      return null;
    } catch (e) {
      print('❌ $endpointName API error: $e');
      return null;
    }
  }

  static Map<String, dynamic> _buildRequestBody(String endpointName, String prompt, Map<String, dynamic> config) {
    switch (endpointName) {
      case 'glm-4.5':
        return {
          'model': config['model'],
          'messages': [
            {
              'role': 'system',
              'content': GLMConfig.systemPrompt,
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          ...config['parameters'],
        };

      case 'llama':
      case 'glm-4-9b':
        return {
          'inputs': prompt,
          'parameters': config['parameters'],
        };

      case 'gemini':
        return {
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are ClimaAI, a helpful climate and environmental science assistant. Provide accurate, helpful information about climate change, sustainability, and environmental topics.\n\nUser: $prompt'
                }
              ]
            }
          ],
          'generationConfig': config['parameters'],
        };

      default:
        return {
          'inputs': prompt,
          'parameters': config['parameters'],
        };
    }
  }

  static String _extractContent(dynamic data, String endpointName) {
    switch (endpointName) {
      case 'glm-4.5':
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'] ?? '';
        }
        break;

      case 'llama':
      case 'glm-4-9b':
        if (data is List && data.isNotEmpty) {
          return data.first['generated_text'] ?? '';
        } else if (data is Map) {
          return data['generated_text'] ?? '';
        }
        break;

      case 'microsoft-dialoGPT':
        if (data is List && data.isNotEmpty) {
          String fullText = data.first['generated_text'] ?? '';

          List<String> parts = fullText.split('<|endoftext|>');
          if (parts.length > 1) {
            return parts.last.trim();
          }
          return fullText.trim();
        }
        break;

      case 'gemini':
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate['content'] != null && candidate['content']['parts'] != null) {
            final parts = candidate['content']['parts'] as List;
            if (parts.isNotEmpty && parts[0]['text'] != null) {
              return parts[0]['text'];
            }
          }
        }
        break;
    }
    return '';
  }

  static String _buildIntelligentPrompt(String message, String? conversationId) {
    final context = conversationId != null ? _conversationContexts[conversationId] : null;
    final recentMessages = context?.take(3).map((m) => m['content']).join('\n') ?? '';

    return '''
Previous conversation context:
$recentMessages

User's current question: $message

Please provide a helpful, accurate, and unique response about climate change, environmental science, or sustainability. Be specific and avoid generic answers. Focus on providing valuable information that helps users understand climate issues and solutions.
''';
  }

  static String _cleanAIResponse(String response) {

    response = response.replaceAll(RegExp(r'^.*?:'), '').trim();
    response = response.replaceAll(RegExp(r'<\|.*?\|>'), '').trim();

    if (response.length > 500) {
      response = response.substring(0, 500) + '...';
    }

    return response;
  }

  static AIResponse _getContextualFallbackResponse(String message, String? conversationId) {

    final contextualResponse = GLMConfig.getContextualFallbackResponse(message);

    return AIResponse(
      content: contextualResponse,
      metadata: {
        'source': 'contextual-fallback',
        'note': 'Using contextual fallback response - consider adding API keys for better AI responses',
      },
    );
  }

  static Future<AIConversation> getConversation(String conversationId) async {
    final messages = _conversationContexts[conversationId] ?? [];
    return AIConversation(
      id: conversationId,
      userId: 'current_user',
      title: 'Climate Chat',
      createdAt: DateTime.now(),
      messages: messages.map((msg) => AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: msg['content'],
        type: msg['role'] == 'user' ? MessageType.user : MessageType.ai,
        timestamp: DateTime.parse(msg['timestamp']),
        status: MessageStatus.sent,
        conversationId: conversationId,
      )).toList(),
    );
  }

  static void clearConversation(String conversationId) {
    _conversationContexts.remove(conversationId);
    _responsePatterns.remove(conversationId);
  }
}