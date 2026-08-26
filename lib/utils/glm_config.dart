import '../utils/env_config.dart';

class GLMConfig {

  static Map<String, Map<String, dynamic>> get endpoints {
    return {

      'gemini': {
        'url': 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
        'model': 'gemini-pro',
        'headers': {
          'Content-Type': 'application/json',
        },
        'parameters': {
          'temperature': 0.7,
          'maxOutputTokens': 500,
        },
      },

      'palm': {
        'url': 'https://generativelanguage.googleapis.com/v1beta/models/chat-bison-001:generateMessage',
        'model': 'chat-bison-001',
        'headers': {
          'Content-Type': 'application/json',
        },
        'parameters': {
          'temperature': 0.7,
          'maxOutputTokens': 500,
        },
      },

      'local': {
        'url': 'local',
        'model': 'local-fallback',
        'headers': {},
        'parameters': {},
      },
    };
  }

  static const String systemPrompt = '''
You are ClimaAI, a specialized AI assistant focused on climate change and environmental science.

Your role is to:
- Provide accurate, up-to-date information about climate change, environmental science, and sustainability
- Help users understand complex environmental concepts in simple terms
- Suggest practical solutions for reducing environmental impact
- Share insights about renewable energy, carbon footprints, and sustainable practices
- Be encouraging and positive about climate action while being realistic about challenges
- Generate unique, contextual responses based on the user's specific questions
- Avoid generic or repetitive answers
- Use examples and data when relevant
- Be conversational and engaging

Guidelines:
- Always provide specific, actionable information
- Use current data and examples when possible
- Explain complex concepts in simple terms
- Be encouraging about climate solutions
- Avoid generic responses - make each answer unique to the question
- Keep responses concise but informative (200-400 words)
- Use a friendly, educational tone

Please provide helpful, accurate, and unique responses about climate change, environmental science, or sustainability. Be specific and avoid generic answers. Focus on providing valuable information that helps users understand climate issues and solutions.
''';

  static const Map<String, List<String>> fallbackResponses = {
    'climate_change': [
      'Climate change is one of the most pressing challenges of our time. The Earth\'s average temperature has increased by about 1.1°C since pre-industrial times, primarily due to human activities releasing greenhouse gases. This warming is causing more frequent and intense weather events, rising sea levels, and ecosystem disruptions. The good news is that we have solutions available - from renewable energy to sustainable agriculture practices.',
      'The science is clear: human activities are the dominant cause of observed warming since the mid-20th century. The Intergovernmental Panel on Climate Change (IPCC) has found that it\'s extremely likely that more than half of the observed increase in global average surface temperature from 1951 to 2010 was caused by human influence. However, this also means that human actions can help solve the problem.',
      'Climate change impacts are already visible worldwide. We\'re seeing more intense heatwaves, heavier rainfall events, and rising sea levels. These changes affect agriculture, water resources, human health, and biodiversity. The transition to a sustainable future requires changes in how we produce and consume energy, food, and other resources.',
    ],
    'renewable_energy': [
      'Renewable energy sources like solar, wind, and hydropower are crucial for reducing greenhouse gas emissions. Solar energy alone could meet the world\'s electricity needs many times over. The cost of solar panels has dropped by 90% since 2010, making it increasingly competitive with fossil fuels. Many countries are now building solar farms that can compete directly with coal and natural gas plants on cost.',
      'Wind energy is one of the fastest-growing renewable energy sources globally. Modern wind turbines can generate electricity for up to 90% of the time, and offshore wind farms can produce even more consistent power. The technology continues to improve, with larger, more efficient turbines being developed.',
      'The renewable energy transition is accelerating worldwide. In 2020, renewable energy sources accounted for 29% of global electricity generation, up from 20% in 2010. This growth is expected to continue as costs decline and policies support clean energy deployment.',
    ],
    'carbon_footprint': [
      'A carbon footprint measures the total greenhouse gas emissions caused directly and indirectly by an individual, organization, event, or product. The average American has a carbon footprint of about 16 tons per year, while the global average is closer to 4 tons. Transportation typically accounts for the largest portion, followed by housing and food choices.',
      'Food choices also significantly impact your carbon footprint. Plant-based diets generally have a much lower carbon footprint than meat-heavy diets. Local and seasonal foods also tend to have lower emissions due to reduced transportation and storage requirements.',
      'Energy use in homes and buildings contributes significantly to carbon emissions. Improving insulation, using energy-efficient appliances, and switching to renewable energy sources can dramatically reduce your carbon footprint. Simple actions like using public transport, driving less, and choosing energy-efficient appliances can significantly reduce your impact.',
    ],
    'recycling': [
      '✅ Why Recycling Is Effective:\n    •    Saves Energy: Recycling uses less energy than producing new materials (e.g. recycled aluminum saves ~95% energy).\n    •    Reduces Landfill Waste: Diverts waste from landfills and lowers methane emissions.\n    •    Conserves Resources: Preserves raw materials like trees, water, and minerals.\n    •    Lowers Emissions: Produces fewer greenhouse gases than manufacturing from scratch.\n\n⚠️ Limitations of Recycling:\n    •    Not All Items Are Recyclable: Contaminated or mixed-material items often end up in landfills.\n    •    Downcycling: Some materials lose quality after each cycle (e.g. plastic).\n    •    System Inefficiencies: Poor infrastructure and low participation reduce impact.\n    •    Transport Emissions: Recycling logistics can still contribute to emissions.\n\n🔁 Better Together:\n    •    Reduce ➤ Reuse ➤ Recycle: Recycling is good—but reducing and reusing are better for the environment.',
    ],
    'sustainability': [
      'Sustainability means meeting our current needs without compromising the ability of future generations to meet theirs. This involves balancing environmental, social, and economic considerations. Sustainable practices can be applied to energy, transportation, agriculture, and many other sectors.',
      'Environmental protection and economic development can go hand in hand. Green technologies and sustainable practices often create jobs and reduce costs over time. Many businesses are finding that sustainability initiatives improve their bottom line while benefiting the planet.',
      'Individual actions matter in creating a more sustainable world. From reducing waste and energy consumption to supporting sustainable businesses and policies, everyone can contribute to positive environmental change. Sustainable agriculture practices like crop rotation, organic farming, and reduced tillage can improve soil health while reducing environmental impacts.',
    ],
    'general': [
      'Climate change is a complex issue that affects all aspects of our lives. The good news is that we have many solutions available, from renewable energy to sustainable agriculture. Every action counts in building a more sustainable future.',
      'Environmental science shows us that human activities are the primary driver of current climate change. However, this also means that human actions can help solve the problem. We have the technology and knowledge needed to transition to a cleaner, more sustainable world.',
      'Education and awareness are crucial for addressing climate change. Understanding the science and impacts helps people make informed decisions about their own actions and support for policies and technologies that can make a difference.',
    ],
  };

  static Map<String, dynamic>? getEndpoint(String name) {
    return endpoints[name];
  }

  static List<String> getEndpointNames() {
    return ['glm-4.5', 'llama', 'glm-4-9b'];
  }

  static String getContextualFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('climate change') || lowerMessage.contains('global warming')) {
      return _getRandomResponse('climate_change');
    } else if (lowerMessage.contains('renewable') || lowerMessage.contains('solar') || lowerMessage.contains('wind')) {
      return _getRandomResponse('renewable_energy');
    } else if (lowerMessage.contains('carbon') || lowerMessage.contains('footprint') || lowerMessage.contains('emissions')) {
      return _getRandomResponse('carbon_footprint');
    } else if (lowerMessage.contains('recycling') || lowerMessage.contains('recycle') || lowerMessage.contains('effective')) {
      return _getRandomResponse('recycling');
    } else if (lowerMessage.contains('sustainable') || lowerMessage.contains('environment') || lowerMessage.contains('green')) {
      return _getRandomResponse('sustainability');
    } else {
      return _getRandomResponse('general');
    }
  }

  static String _getRandomResponse(String category) {
    final responses = fallbackResponses[category] ?? fallbackResponses['general']!;
    final random = DateTime.now().millisecondsSinceEpoch % responses.length;
    return responses[random];
  }
}