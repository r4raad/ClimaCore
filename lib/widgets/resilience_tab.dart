import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/disaster_event.dart';
import '../services/news_service.dart';
import '../widgets/disaster_event_card.dart';

class ResilienceTab extends StatefulWidget {
  @override
  _ResilienceTabState createState() => _ResilienceTabState();
}

class _ResilienceTabState extends State<ResilienceTab> {
  List<DisasterEvent> _disasterEvents = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDisasterEvents();
  }

  Future<void> _loadDisasterEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('🔄 Loading real-time climate news...');
      final events = await NewsService.fetchClimateNews()
          .timeout(Duration(seconds: 10), onTimeout: () {
        print('⏰ News loading timeout, using fallback data');
        return _getFallbackDisasterEvents();
      });
      
      if (mounted) {
        setState(() {
          _disasterEvents = events;
          _isLoading = false;
        });
        print('✅ Loaded ${events.length} climate events');
      }
    } catch (e) {
      print('❌ Error loading disaster events: $e');
      if (mounted) {
        setState(() {
          _disasterEvents = _getFallbackDisasterEvents();
          _isLoading = false;
        });
      }
    }
  }

  List<DisasterEvent> _getFallbackDisasterEvents() {
    return [
      DisasterEvent(
        id: 'fallback_1',
        title: 'Global Temperature Rise Continues',
        description: 'Recent data shows continued global temperature increases, highlighting the urgency of climate action.',
        location: 'Global',
        date: DateTime.now().subtract(Duration(days: 1)),
        type: 'CLIMATE CHANGE',
        casualties: '0',
        damage: 'Environmental',
        imageUrl: 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Climate+Change',
        sourceUrl: 'https://example.com',
      ),
      DisasterEvent(
        id: 'fallback_2',
        title: 'Renewable Energy Adoption Increases',
        description: 'Countries worldwide are accelerating their transition to renewable energy sources.',
        location: 'Global',
        date: DateTime.now().subtract(Duration(days: 2)),
        type: 'POSITIVE NEWS',
        casualties: '0',
        damage: 'None',
        imageUrl: 'https://via.placeholder.com/400x200/2196F3/FFFFFF?text=Renewable+Energy',
        sourceUrl: 'https://example.com',
      ),
      DisasterEvent(
        id: 'fallback_3',
        title: 'Extreme Weather Events',
        description: 'Increased frequency of extreme weather events linked to climate change.',
        location: 'Multiple Regions',
        date: DateTime.now().subtract(Duration(days: 3)),
        type: 'EXTREME WEATHER',
        casualties: '0',
        damage: 'Infrastructure',
        imageUrl: 'https://via.placeholder.com/400x200/FF9800/FFFFFF?text=Extreme+Weather',
        sourceUrl: 'https://example.com',
      ),
    ];
  }

  List<DisasterEvent> get _filteredEvents {
    if (_searchQuery.isEmpty) {
      return _disasterEvents;
    }
    return _disasterEvents.where((event) {
      return event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             event.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             event.type.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Map<String, List<DisasterEvent>> get _groupedEvents {
    final grouped = <String, List<DisasterEvent>>{};
    
    for (final event in _filteredEvents) {
      final date = event.date;
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));
      
      String groupKey;
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        groupKey = 'Today';
      } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
        groupKey = 'Yesterday';
      } else {
        groupKey = DateFormat('EEEE, MMMM d').format(date);
      }
      
      grouped.putIfAbsent(groupKey, () => []).add(event);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSearchBar(),
          
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search disasters...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          Icon(Icons.filter_list, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 16),
          Text(
            'Fetching real-time climate news...',
            style: GoogleFonts.questrial(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: GoogleFonts.questrial(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No disaster events found' : 'No events match your search',
              style: GoogleFonts.questrial(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDisasterEvents,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 0),
        itemCount: _groupedEvents.length,
        itemBuilder: (context, index) {
          final groupKey = _groupedEvents.keys.elementAt(index);
          final events = _groupedEvents[groupKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(
                  groupKey,
                  style: GoogleFonts.questrial(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              ...events.map((event) => _buildEventCard(event)).toList(),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventCard(DisasterEvent event) {
    Color tagColor = _getEventTypeColor(event.type);
    IconData iconData = Icons.warning;
    switch (event.type.toUpperCase()) {
      case 'LANDSLIDE':
        iconData = Icons.terrain;
        break;
      case 'FLOOD':
      case 'FLOOD: HEAVY RAIN':
        iconData = Icons.water_damage;
        break;
      case 'TYPHOON':
        iconData = Icons.cyclone;
        break;
      case 'EARTHQUAKE':
        iconData = Icons.waves;
        break;
      case 'WILDFIRE':
        iconData = Icons.local_fire_department;
        break;
      default:
        iconData = Icons.warning;
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.type.toUpperCase(),
                  style: GoogleFonts.questrial(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Spacer(),
              Text(
                'Updated: ${DateFormat('h:mm a').format(event.date)}',
                style: GoogleFonts.questrial(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: tagColor.withOpacity(0.1),
                child: Icon(iconData, color: tagColor),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.questrial(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[900],
                      ),
                    ),
                    if (event.casualties.isNotEmpty || event.damage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          [
                            if (event.casualties.isNotEmpty) event.casualties,
                            if (event.damage.isNotEmpty) event.damage,
                          ].join(', '),
                          style: GoogleFonts.questrial(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new, color: Colors.green, size: 20),
                onPressed: () => NewsService.launchSourceUrl(event.sourceUrl),
                tooltip: 'Read More',
              ),
            ],
          ),
          if (event.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                event.description,
                style: GoogleFonts.questrial(
                  fontSize: 13,
                  color: Colors.grey[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEventDetails(DisasterEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getEventTypeColor(event.type),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.type,
                        style: GoogleFonts.questrial(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    Text(
                      event.title,
                      style: GoogleFonts.questrial(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                        SizedBox(width: 4),
                        Text(
                          event.location,
                          style: GoogleFonts.questrial(
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        Text(
                          DateFormat('MMM d, y').format(event.date),
                          style: GoogleFonts.questrial(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    if (event.casualties.isNotEmpty) ...[
                      _buildInfoRow('Casualties', event.casualties),
                      SizedBox(height: 8),
                    ],
                    if (event.damage.isNotEmpty) ...[
                      _buildInfoRow('Damage', event.damage),
                      SizedBox(height: 16),
                    ],
                    
                    Text(
                      'Description',
                      style: GoogleFonts.questrial(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      event.description,
                      style: GoogleFonts.questrial(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                            },
                            icon: Icon(Icons.share),
                            label: Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                await NewsService.launchSourceUrl(event.sourceUrl);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Unable to open link: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.open_in_new),
                            label: Text('Read More'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.questrial(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.questrial(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'LANDSLIDE':
        return Colors.red;
      case 'FLOOD':
      case 'FLOOD: HEAVY RAIN':
        return Colors.blue;
      case 'TYPHOON':
        return Colors.purple;
      case 'EARTHQUAKE':
        return Colors.orange;
      case 'WILDFIRE':
        return Colors.deepOrange;
      default:
        return Color(0xFF4CAF50);
    }
  }
} 