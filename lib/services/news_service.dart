import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/disaster_event.dart';

class NewsService {
  // API keys for real-time news
  static const String _newsApiKey = '9e2a2889e5434c26a27b8575ef476643'; // Get from https://newsapi.org/
  static const String _gNewsApiKey = '9325b82ee95c436591389f541e45d3e4'; // Get from https://gnews.io/
  
  static const String _newsApiBaseUrl = 'https://newsapi.org/v2';
  static const String _gNewsBaseUrl = 'https://gnews.io/api/v4';

  static const List<String> _climateKeywords = [
    'climate change',
    'global warming',
    'natural disaster',
    'hurricane',
    'typhoon',
    'earthquake',
    'flood',
    'wildfire',
    'drought',
    'landslide',
    'tsunami',
    'volcanic eruption',
    'extreme weather',
    'environmental disaster',
    'carbon emissions',
    'renewable energy',
    'sustainability',
  ];

  static const Map<String, String> _disasterTypeMapping = {
    'hurricane': 'HURRICANE',
    'typhoon': 'TYPHOON',
    'earthquake': 'EARTHQUAKE',
    'flood': 'FLOOD',
    'wildfire': 'WILDFIRE',
    'drought': 'DROUGHT',
    'landslide': 'LANDSLIDE',
    'tsunami': 'TSUNAMI',
    'volcanic': 'VOLCANIC ERUPTION',
    'tornado': 'TORNADO',
    'storm': 'STORM',
    'cyclone': 'CYCLONE',
  };

  static Future<List<DisasterEvent>> fetchClimateNews() async {
    try {
      print('🌍 Fetching real-time climate news from APIs...');
      final List<DisasterEvent> events = [];
      
      // Always try to fetch from real APIs since we have valid keys
      try {
        final newsApiEvents = await _fetchFromNewsAPI();
        events.addAll(newsApiEvents);
        print('✅ NewsAPI: Fetched ${newsApiEvents.length} events');
      } catch (e) {
        print('❌ NewsAPI error: $e');
      }
      
      try {
        final gNewsEvents = await _fetchFromGNews();
        events.addAll(gNewsEvents);
        print('✅ GNews: Fetched ${gNewsEvents.length} events');
      } catch (e) {
        print('❌ GNews error: $e');
      }
      
      // If we got real events, return them
      if (events.isNotEmpty) {
        events.sort((a, b) => b.date.compareTo(a.date));
        print('🎉 Successfully fetched ${events.length} real climate events');
        return events;
      }
      
      // Only use sample data if both APIs fail
      print('⚠️ Using sample data as fallback');
      return _getSampleDisasterEvents();
    } catch (e) {
      print('❌ Error fetching climate news: $e');
      return _getSampleDisasterEvents();
    }
  }

  static Future<void> launchSourceUrl(String url) async {
    try {
      print('🔗 Attempting to launch URL: $url');
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ Successfully launched URL');
      } else {
        print('❌ Could not launch URL: $url');
        // Show user-friendly error message
        throw Exception('Unable to open link. Please check your internet connection.');
      }
    } catch (e) {
      print('❌ Error launching URL: $e');
      rethrow; // Re-throw to show error to user
    }
  }

  static Future<List<DisasterEvent>> _fetchFromNewsAPI() async {
    try {
      final List<DisasterEvent> events = [];
      
      for (String keyword in _climateKeywords) {
        final response = await http.get(
          Uri.parse('$_newsApiBaseUrl/everything?q=$keyword&sortBy=publishedAt&language=en&pageSize=5&apiKey=$_newsApiKey'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final articles = data['articles'] as List;

          for (var article in articles) {
            final event = _parseNewsAPIArticle(article);
            if (event != null) {
              events.add(event);
            }
          }
        }
      }
      
      return events;
    } catch (e) {
      print('Error fetching from NewsAPI: $e');
      return [];
    }
  }

  static Future<List<DisasterEvent>> _fetchFromGNews() async {
    try {
      final List<DisasterEvent> events = [];
      
      for (String keyword in _climateKeywords) {
        final response = await http.get(
          Uri.parse('$_gNewsBaseUrl/search?q=$keyword&lang=en&country=us&max=5&apikey=$_gNewsApiKey'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final articles = data['articles'] as List;

          for (var article in articles) {
            final event = _parseGNewsArticle(article);
            if (event != null) {
              events.add(event);
            }
          }
        }
      }
      
      return events;
    } catch (e) {
      print('Error fetching from GNews: $e');
      return [];
    }
  }

  static DisasterEvent? _parseNewsAPIArticle(Map<String, dynamic> article) {
    try {
      final title = article['title'] ?? '';
      final description = article['description'] ?? '';
      final content = article['content'] ?? '';
      final url = article['url'] ?? '';
      final imageUrl = article['urlToImage'] ?? '';
      final publishedAt = article['publishedAt'] ?? '';
      final source = article['source']?['name'] ?? '';

      final disasterType = _extractDisasterType('$title $description $content');
      final location = _extractLocation('$title $description $content');
      final casualties = _extractCasualties('$title $description $content');
      final damage = _extractDamage('$title $description $content');

      return DisasterEvent(
        id: url.hashCode.toString(),
        title: title,
        description: description.isNotEmpty ? description : content.substring(0, content.length > 200 ? 200 : content.length),
        location: location,
        type: disasterType,
        date: DateTime.parse(publishedAt),
        casualties: casualties,
        damage: damage,
        imageUrl: imageUrl,
        sourceUrl: url,
      );
    } catch (e) {
      print('Error parsing NewsAPI article: $e');
      return null;
    }
  }

  static DisasterEvent? _parseGNewsArticle(Map<String, dynamic> article) {
    try {
      final title = article['title'] ?? '';
      final description = article['description'] ?? '';
      final content = article['content'] ?? '';
      final url = article['url'] ?? '';
      final imageUrl = article['image'] ?? '';
      final publishedAt = article['publishedAt'] ?? '';
      final source = article['source']?['name'] ?? '';

      final disasterType = _extractDisasterType('$title $description $content');
      final location = _extractLocation('$title $description $content');
      final casualties = _extractCasualties('$title $description $content');
      final damage = _extractDamage('$title $description $content');

      return DisasterEvent(
        id: url.hashCode.toString(),
        title: title,
        description: description.isNotEmpty ? description : content.substring(0, content.length > 200 ? 200 : content.length),
        location: location,
        type: disasterType,
        date: DateTime.parse(publishedAt),
        casualties: casualties,
        damage: damage,
        imageUrl: imageUrl,
        sourceUrl: url,
      );
    } catch (e) {
      print('Error parsing GNews article: $e');
      return null;
    }
  }

  static String _extractDisasterType(String text) {
    final lowerText = text.toLowerCase();
    
    for (var entry in _disasterTypeMapping.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return 'CLIMATE EVENT';
  }

  static String _extractLocation(String text) {
    final locations = [
      'Seoul', 'Busan', 'Gangnam', 'Jeju-do', 'Pacific Ocean',
      'South Korea', 'Japan', 'Philippines', 'United States',
      'California', 'Florida', 'Texas', 'New York'
    ];
    
    for (String location in locations) {
      if (text.contains(location)) {
        return location;
      }
    }
    
    return 'Global';
  }

  static String _extractCasualties(String text) {
    final casualtiesPattern = RegExp(r'(\d+)\s*(?:people\s*)?(?:dead|killed|injured|missing)', caseSensitive: false);
    final match = casualtiesPattern.firstMatch(text);
    
    if (match != null) {
      return '${match.group(1)} people affected';
    }
    
    return 'Information not available';
  }

  static String _extractDamage(String text) {
    final damagePattern = RegExp(r'(\d+)\s*(?:buildings|homes|structures)\s*(?:damaged|destroyed)', caseSensitive: false);
    final match = damagePattern.firstMatch(text);
    
    if (match != null) {
      return '${match.group(1)} buildings damaged';
    }
    
    return 'Damage assessment ongoing';
  }

  static List<DisasterEvent> _getSampleDisasterEvents() {
    return [
      DisasterEvent(
        id: '1',
        title: 'Climate Change Impact: Record Heatwaves Across Asia',
        description: 'Scientists report unprecedented heatwaves affecting multiple Asian countries, with temperatures reaching record highs. The extreme weather events are linked to climate change and pose significant health risks to vulnerable populations.',
        location: 'Asia Pacific Region',
        type: 'EXTREME WEATHER',
        date: DateTime.now().subtract(Duration(hours: 2)),
        casualties: 'Thousands affected by heat stress',
        damage: 'Agricultural losses estimated at millions',
        imageUrl: 'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800',
        sourceUrl: 'https://www.reuters.com/environment/climate-change/',
      ),
      DisasterEvent(
        id: '2',
        title: 'Rising Sea Levels Threaten Coastal Communities',
        description: 'New research shows accelerated sea level rise affecting coastal communities worldwide. Small island nations and low-lying coastal areas are particularly vulnerable to this climate change impact.',
        location: 'Global Coastal Areas',
        type: 'CLIMATE EVENT',
        date: DateTime.now().subtract(Duration(hours: 4)),
        casualties: 'Millions at risk of displacement',
        damage: 'Infrastructure damage in coastal regions',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        sourceUrl: 'https://www.nationalgeographic.com/environment/',
      ),
      DisasterEvent(
        id: '3',
        title: 'Renewable Energy Adoption Accelerates Globally',
        description: 'Solar and wind energy installations reach new records as countries transition to clean energy sources. This shift is crucial for meeting climate targets and reducing greenhouse gas emissions.',
        location: 'Global',
        type: 'SUSTAINABILITY',
        date: DateTime.now().subtract(Duration(hours: 6)),
        casualties: 'Positive impact on climate goals',
        damage: 'Reduced carbon emissions',
        imageUrl: 'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=800',
        sourceUrl: 'https://www.bloomberg.com/news/articles/',
      ),
    ];
  }
} 