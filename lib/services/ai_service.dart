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
    
    // Climate change and global warming
    if (lowerMessage.contains('climate change') || lowerMessage.contains('global warming')) {
      final responses = [
        'Climate change refers to long-term shifts in global or regional climate patterns. The main cause is human activities, particularly the burning of fossil fuels which releases greenhouse gases. Solutions include transitioning to renewable energy, improving energy efficiency, and adopting sustainable practices.',
        'Global warming is the long-term heating of Earth\'s climate system observed since the pre-industrial period due to human activities, primarily fossil fuel burning, which increases heat-trapping greenhouse gas levels in Earth\'s atmosphere. The average global temperature has increased by about 1.1°C since 1880.',
        'Climate change is one of the most pressing challenges of our time. It affects weather patterns, sea levels, and ecosystems worldwide. The good news is that we have solutions! Renewable energy, sustainable agriculture, and conservation efforts can help mitigate these effects.',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Solutions and solving
    if (lowerMessage.contains('solution') || lowerMessage.contains('solve') || lowerMessage.contains('help')) {
      final responses = [
        'Here are 4 key solutions for climate change:\n\n1. **Use renewable energy** - Switch to solar, wind, and hydroelectric power to reduce reliance on fossil fuels\n\n2. **Plant and protect trees** - Forests absorb carbon dioxide and help regulate the climate\n\n3. **Use public transport or bike** - Reduce emissions from personal vehicles\n\n4. **Reduce, reuse, and recycle** - Minimize waste and the energy needed to produce new materials',
        'Great question! Here are some effective solutions:\n\n• **Energy efficiency** - Upgrade to LED bulbs and energy-efficient appliances\n• **Sustainable transportation** - Walk, bike, or use public transport\n• **Plant-based diet** - Reduce meat consumption to lower emissions\n• **Support clean energy** - Choose renewable energy providers\n• **Educate others** - Share knowledge about climate solutions',
        'I\'m glad you\'re asking about solutions! Here are some actionable steps:\n\n🌱 **Individual Actions**:\n- Switch to renewable energy\n- Reduce meat consumption\n- Use public transport\n- Plant trees\n\n🏢 **Community Actions**:\n- Support local environmental initiatives\n- Advocate for clean energy policies\n- Join climate action groups',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Renewable energy
    if (lowerMessage.contains('renewable') || lowerMessage.contains('energy') || lowerMessage.contains('solar') || lowerMessage.contains('wind')) {
      final responses = [
        'Renewable energy sources like solar, wind, hydroelectric, and geothermal power are key to combating climate change. They produce little to no greenhouse gas emissions and are becoming increasingly cost-effective. Solar and wind energy are the fastest-growing renewable sources globally.',
        'Renewable energy is amazing! 🌞 Solar panels can power homes and businesses, while wind turbines generate clean electricity. These technologies are becoming cheaper and more efficient every year. Many countries are now getting most of their energy from renewables!',
        'Clean energy is the future! Here are the main types:\n\n☀️ **Solar Power** - Converts sunlight to electricity\n💨 **Wind Energy** - Uses wind turbines to generate power\n💧 **Hydropower** - Uses flowing water to create energy\n🌋 **Geothermal** - Uses Earth\'s heat\n🌱 **Biomass** - Uses organic materials',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Carbon footprint
    if (lowerMessage.contains('carbon') || lowerMessage.contains('footprint') || lowerMessage.contains('emissions')) {
      final responses = [
        'Your carbon footprint is the total greenhouse gas emissions caused by your activities. You can reduce it by:\n- Using energy-efficient appliances\n- Choosing renewable energy\n- Reducing meat consumption\n- Using public transport\n- Supporting sustainable products',
        'Carbon footprint is like your environmental impact score! 🎯 Here\'s how to lower yours:\n\n🚗 **Transport**: Walk, bike, or use public transport\n💡 **Energy**: Switch to renewable energy and LED bulbs\n🍽️ **Food**: Eat more plant-based meals\n🛍️ **Shopping**: Buy local and sustainable products\n♻️ **Waste**: Reduce, reuse, recycle',
        'Great question about carbon footprint! It\'s the amount of CO2 and other greenhouse gases your activities produce. The average person\'s footprint is about 4.8 tons per year. You can reduce yours by:\n\n• Flying less\n• Eating less meat\n• Using renewable energy\n• Driving electric vehicles\n• Supporting reforestation',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Sustainable living
    if (lowerMessage.contains('sustainable') || lowerMessage.contains('living') || lowerMessage.contains('eco-friendly')) {
      final responses = [
        'Sustainable living is about making choices that protect our planet! 🌍 Here are some easy ways to start:\n\n🏠 **At Home**:\n- Use energy-efficient appliances\n- Install solar panels\n- Compost food waste\n- Use natural cleaning products\n\n🚶 **Lifestyle**:\n- Walk or bike instead of driving\n- Buy local and seasonal food\n- Reduce single-use plastics\n- Support eco-friendly businesses',
        'Living sustainably is easier than you think! Start with these simple changes:\n\n🥤 **Reduce waste**: Use reusable water bottles and shopping bags\n🌱 **Eat green**: Choose plant-based meals more often\n💚 **Shop smart**: Buy second-hand and support sustainable brands\n🏡 **Green home**: Use LED bulbs and turn off lights when not needed',
        'Sustainable living means meeting our needs without compromising future generations! Here\'s how:\n\n♻️ **Zero Waste**: Refuse, reduce, reuse, recycle\n🌿 **Green Diet**: More plants, less meat\n🚲 **Clean Transport**: Walk, bike, or use public transit\n💡 **Smart Energy**: Use renewable energy and conserve power',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Paris Agreement
    if (lowerMessage.contains('paris') || lowerMessage.contains('agreement') || lowerMessage.contains('treaty')) {
      final responses = [
        'The Paris Agreement is a landmark international treaty adopted in 2015. It aims to limit global warming to well below 2°C, preferably 1.5°C, compared to pre-industrial levels. Countries commit to reducing emissions and adapting to climate impacts.',
        'The Paris Agreement is a global effort to fight climate change! 🌍 Signed by 196 countries, it sets targets to:\n\n📉 Reduce greenhouse gas emissions\n🌡️ Limit temperature rise to 1.5°C\n💰 Provide financial support to developing countries\n📊 Track progress with regular reports',
        'Great question! The Paris Agreement is like a global climate action plan. It brings countries together to:\n\n• Set emission reduction targets\n• Share climate solutions\n• Support vulnerable nations\n• Create a sustainable future for all',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Green technologies
    if (lowerMessage.contains('green') || lowerMessage.contains('technology') || lowerMessage.contains('innovation')) {
      final responses = [
        'Green technologies are revolutionizing how we live! 🌱 Here are some exciting innovations:\n\n🔋 **Energy Storage**: Better batteries for renewable energy\n🚗 **Electric Vehicles**: Clean transportation options\n🏠 **Smart Homes**: Energy-efficient buildings\n🌊 **Ocean Energy**: Harnessing wave and tidal power\n🌿 **Carbon Capture**: Removing CO2 from the atmosphere',
        'Green tech is amazing! Here are some cutting-edge solutions:\n\n☀️ **Solar Innovation**: More efficient panels and solar paint\n💨 **Wind Advances**: Floating wind turbines and better designs\n🌊 **Ocean Power**: Wave and tidal energy systems\n🔋 **Storage Breakthroughs**: Better batteries and hydrogen fuel\n🌱 **Carbon Tech**: Direct air capture and biochar',
        'Green technology is transforming our world! Some exciting developments include:\n\n• Advanced solar panels with higher efficiency\n• Electric vehicles with longer range\n• Smart grid systems for better energy management\n• Carbon capture and storage technologies\n• Sustainable building materials',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Greetings and general questions
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      final responses = [
        'Hello! 👋 I\'m ClimaAI, your climate and environmental science assistant. I\'m here to help you learn about climate change, sustainability, and environmental solutions. What would you like to know?',
        'Hi there! 🌍 I\'m excited to help you explore climate science and environmental topics. Whether you\'re curious about renewable energy, carbon footprints, or sustainable living, I\'m here to share knowledge and solutions!',
        'Hey! 🌱 Welcome to ClimaAI! I\'m your guide to understanding climate change and finding solutions. From renewable energy to sustainable living, I\'m here to answer your questions and inspire climate action!',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Default response
    final defaultResponses = [
      'I\'m here to help you learn about climate change and environmental solutions! 🌍 What specific aspect would you like to know more about? You can ask me about renewable energy, carbon footprints, sustainable living, or climate science.',
      'Great question! I\'m ClimaAI, your climate assistant. I can help you understand climate change, renewable energy, sustainable living, and environmental solutions. What interests you most? 🌱',
      'I\'m excited to help you explore environmental topics! 🌿 Whether you\'re curious about climate science, green technologies, or sustainable practices, I\'m here to share knowledge and inspire action. What would you like to learn about?',
      'Welcome to ClimaAI! 🌍 I\'m your climate and environmental science assistant. I can help you understand climate change, discover sustainable solutions, and learn about renewable energy. What would you like to explore today?',
    ];
    return defaultResponses[DateTime.now().millisecond % defaultResponses.length];
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