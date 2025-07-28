import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/ai_message.dart';

class AIService {
  static const Uuid _uuid = Uuid();
  
  static const List<Map<String, String>> _freeModels = [
    {
      'name': 'Llama 2 7B',
      'url': 'https://api-inference.huggingface.co/models/meta-llama/Llama-2-7b-chat-hf',
      'description': 'Meta\'s powerful 7B parameter model'
    },
    {
      'name': 'Mistral 7B',
      'url': 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2',
      'description': 'Mistral AI\'s efficient 7B model'
    },
    {
      'name': 'Gemma 2B',
      'url': 'https://api-inference.huggingface.co/models/google/gemma-2b-it',
      'description': 'Google\'s lightweight but powerful model'
    },
    {
      'name': 'Gemma 7B',
      'url': 'https://api-inference.huggingface.co/models/google/gemma-7b-it',
      'description': 'Google\'s larger 7B parameter model'
    },
    {
      'name': 'CodeLlama 7B',
      'url': 'https://api-inference.huggingface.co/models/codellama/CodeLlama-7b-Instruct-hf',
      'description': 'Specialized for code and technical topics'
    }
  ];
  
  static const String _systemPrompt = '''
You are ClimaAI, a specialized AI assistant focused on climate change, environmental science, and sustainability. Your role is to:

1. Provide accurate, science-based information about climate change
2. Help users understand environmental issues and their solutions
3. Suggest practical actions for reducing environmental impact
4. Answer questions about renewable energy, sustainability, and green technologies
5. Explain complex climate science in simple terms
6. Provide solutions for climate-related problems

Always be informative, encouraging, and solution-oriented. When discussing climate change, focus on both the challenges and the opportunities for positive action.

Key areas of expertise:
- Climate science and global warming
- Renewable energy and clean technologies
- Sustainable living and green practices
- Environmental conservation
- Climate policy and international agreements
- Carbon footprint reduction
- Adaptation and resilience strategies

Remember to be factual, optimistic about solutions, and encourage user engagement with climate action.
''';

  static Future<AIResponse> sendMessage(String message, {String? conversationId}) async {
    try {
      for (final model in _freeModels) {
        final cloudResponse = await _sendToFreeCloudAI(message, conversationId, model);
        if (cloudResponse != null) {
          return cloudResponse;
        }
      }

      return await _getSampleResponse(message);
    } catch (e) {
      print('Error in AI service: $e');
      return AIResponse(
        content: 'I apologize, but I\'m having trouble processing your request right now. Please try again later.',
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<AIResponse?> _sendToFreeCloudAI(String message, String? conversationId, Map<String, String> model) async {
    try {
      final response = await http.post(
        Uri.parse(model['url']!),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': _buildPromptForModel(message, model['name']!),
          'parameters': {
            'max_new_tokens': 300,
            'temperature': 0.7,
            'do_sample': true,
            'top_p': 0.9,
            'repetition_penalty': 1.1,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String content = '';
        
        if (data is List && data.isNotEmpty) {
          content = data[0]['generated_text'] ?? '';
        } else if (data is Map) {
          content = data['generated_text'] ?? '';
        }
        
        content = _cleanAIResponse(content, message, model['name']!);
        
        return AIResponse(
          content: content.trim(),
          metadata: {
            'model': model['name']!,
            'conversationId': conversationId,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
      
      return null;
    } catch (e) {
      print('Free cloud AI (${model['name']}) failed: $e');
      return null;
    }
  }

  static String _buildPromptForModel(String message, String modelName) {
    if (modelName.contains('Llama')) {
      return '''<s>[INST] $_systemPrompt

User: $message [/INST]''';
    } else if (modelName.contains('Mistral')) {
      return '''<s>[INST] $_systemPrompt

User: $message [/INST]''';
    } else if (modelName.contains('Gemma')) {
      return '''<start_of_turn>user
$_systemPrompt

User: $message<end_of_turn>
<start_of_turn>model''';
    } else if (modelName.contains('CodeLlama')) {
      return '''[INST] $_systemPrompt

User: $message [/INST]''';
    } else {
      return '''$_systemPrompt

User: $message

ClimaAI:''';
    }
  }

  static String _cleanAIResponse(String response, String originalMessage, String modelName) {
    String cleaned = response;
    
    if (modelName.contains('Llama') || modelName.contains('Mistral') || modelName.contains('CodeLlama')) {
      if (cleaned.contains('[/INST]')) {
        cleaned = cleaned.split('[/INST]').last;
      }
    } else if (modelName.contains('Gemma')) {
      if (cleaned.contains('<start_of_turn>model')) {
        cleaned = cleaned.split('<start_of_turn>model').last;
      }
      if (cleaned.contains('<end_of_turn>')) {
        cleaned = cleaned.split('<end_of_turn>').first;
      }
    } else {
      if (cleaned.contains('ClimaAI:')) {
        cleaned = cleaned.split('ClimaAI:').last;
      }
    }
    
    if (cleaned.contains('User: $originalMessage')) {
      cleaned = cleaned.replaceAll('User: $originalMessage', '');
    }
    
    cleaned = cleaned.trim();
    
    if (cleaned.length < 10) {
      return _getSampleResponseContent(originalMessage);
    }
    
    return cleaned;
  }

  static Future<AIResponse> _getSampleResponse(String message) async {
    final content = _getSampleResponseContent(message);
    
    return AIResponse(
      content: content,
      metadata: {
        'model': 'sample-responses',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static String _getSampleResponseContent(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('climate change') || lowerMessage.contains('global warming')) {
      return 'Climate change refers to long-term shifts in global or regional climate patterns. The main cause is human activities, particularly the burning of fossil fuels which releases greenhouse gases. Solutions include transitioning to renewable energy, improving energy efficiency, and adopting sustainable practices.';
    }
    
    if (lowerMessage.contains('solution') || lowerMessage.contains('solve')) {
      return 'Here are 4 key solutions for climate change:\n\n1. **Use renewable energy** - Switch to solar, wind, and hydroelectric power to reduce reliance on fossil fuels\n\n2. **Plant and protect trees** - Forests absorb carbon dioxide and help regulate the climate\n\n3. **Use public transport or bike** - Reduce emissions from personal vehicles\n\n4. **Reduce, reuse, and recycle** - Minimize waste and the energy needed to produce new materials';
    }
    
    if (lowerMessage.contains('renewable') || lowerMessage.contains('energy')) {
      return 'Renewable energy sources like solar, wind, hydroelectric, and geothermal power are key to combating climate change. They produce little to no greenhouse gas emissions and are becoming increasingly cost-effective. Solar and wind energy are the fastest-growing renewable sources globally.';
    }
    
    if (lowerMessage.contains('carbon') || lowerMessage.contains('footprint')) {
      return 'Your carbon footprint is the total greenhouse gas emissions caused by your activities. You can reduce it by:\n- Using energy-efficient appliances\n- Choosing renewable energy\n- Reducing meat consumption\n- Using public transport\n- Supporting sustainable products';
    }
    
    return 'I\'m here to help you learn about climate change and environmental solutions. What specific aspect would you like to know more about?';
  }

  static List<Map<String, String>> getAvailableFreeModels() {
    return _freeModels;
  }

  static String generateConversationTitle(String firstMessage) {
    final lowerMessage = firstMessage.toLowerCase();
    
    if (lowerMessage.contains('climate change')) return 'Climate Change Discussion';
    if (lowerMessage.contains('renewable')) return 'Renewable Energy Chat';
    if (lowerMessage.contains('carbon')) return 'Carbon Footprint Talk';
    if (lowerMessage.contains('solution')) return 'Climate Solutions';
    if (lowerMessage.contains('sustainable')) return 'Sustainability Discussion';
    
    return 'Climate & Environment Chat';
  }

  static Future<void> saveConversation(AIConversation conversation) async {
  }

  static Future<List<AIConversation>> getConversationHistory(String userId) async {
    return [];
  }

  static Future<void> optimizeModelForClimate() async {
  }

  static List<String> getClimateSuggestions() {
    return [
      'What is climate change?',
      'How can I reduce my carbon footprint?',
      'What are renewable energy sources?',
      'Tell me about sustainable living',
      'What are the effects of global warming?',
      'How can we combat climate change?',
      'What is the Paris Agreement?',
      'Tell me about green technologies',
    ];
  }
} 