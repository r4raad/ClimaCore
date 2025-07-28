import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/disaster_event.dart';

class NewsService {
  static const String _newsApiKey = 'YOUR_NEWS_API_KEY';
  static const String _gNewsApiKey = 'YOUR_GNEWS_API_KEY';
  
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
      final List<DisasterEvent> events = [];
      
      final newsApiEvents = await _fetchFromNewsAPI();
      final gNewsEvents = await _fetchFromGNews();
      
      events.addAll(newsApiEvents);
      events.addAll(gNewsEvents);
      
      events.sort((a, b) => b.date.compareTo(a.date));
      
      return events;
    } catch (e) {
      print('Error fetching climate news: $e');
      return _getSampleDisasterEvents();
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
        title: 'Landslide Event',
        description: 'Landslide with injury. Landslide intersects the Sinsa Park near its midpoint at Mile 45.4 and displaces 100 yards (90 m) of the full width of the road.',
        location: 'Sinsa Neighbourhood Park',
        type: 'LANDSLIDE',
        date: DateTime.now().subtract(Duration(hours: 3)),
        casualties: 'Injured: 12',
        damage: 'Road displacement: 100 yards',
        imageUrl: 'https://example.com/landslide.jpg',
        sourceUrl: 'https://example.com/news/landslide',
      ),
      DisasterEvent(
        id: '2',
        title: 'FLOOD: Heavy Rain Event',
        description: 'Flood with injury. INC 0087. Highest rainfall in 80 years. 2,800 buildings were damaged, Killed: 9 and 163 people homeless.',
        location: 'Gangnam, Seoul',
        type: 'FLOOD: Heavy Rain',
        date: DateTime.now().subtract(Duration(hours: 6)),
        casualties: 'Death: 9, Damage: 2800 Buildings',
        damage: '2,800 buildings damaged',
        imageUrl: 'https://example.com/flood.jpg',
        sourceUrl: 'https://example.com/news/flood',
      ),
      DisasterEvent(
        id: '3',
        title: 'TYPHOON: Beblinca',
        description: 'The typhoon did not make direct landfall in South Korea. On September 15th, 2024 at 6:00 pm it had the shortest distance at about 167 km south of Seogwipo in Jeju-do.',
        location: 'Pacific Ocean',
        type: 'TYPHOON: Beblinca',
        date: DateTime.now().subtract(Duration(days: 1)),
        casualties: '6 people dead, 11 injured, and 26 missing',
        damage: 'Significant coastal damage',
        imageUrl: 'https://example.com/typhoon.jpg',
        sourceUrl: 'https://example.com/news/typhoon',
      ),
    ];
  }
} 