import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/disaster_event.dart';

class DisasterEventCard extends StatelessWidget {
  final DisasterEvent event;
  final VoidCallback? onTap;

  const DisasterEventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Spacer(),
                    Text(
                      'Updated: ${DateFormat('h:mm a').format(event.date)}',
                      style: GoogleFonts.questrial(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getEventTypeColor(event.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getEventIcon(event.type),
                        color: _getEventTypeColor(event.type),
                        size: 20,
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${event.location} (${event.casualties})',
                            style: GoogleFonts.questrial(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          
                          SizedBox(height: 4),
                          
                          Text(
                            event.description,
                            style: GoogleFonts.questrial(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.open_in_new,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
      case 'DROUGHT':
        return Colors.brown;
      case 'TSUNAMI':
        return Colors.indigo;
      case 'VOLCANIC ERUPTION':
        return Colors.deepPurple;
      default:
        return Color(0xFF4CAF50);
    }
  }

  IconData _getEventIcon(String type) {
    switch (type.toUpperCase()) {
      case 'LANDSLIDE':
        return Icons.terrain;
      case 'FLOOD':
      case 'FLOOD: HEAVY RAIN':
        return Icons.water;
      case 'TYPHOON':
        return Icons.air;
      case 'EARTHQUAKE':
        return Icons.vibration;
      case 'WILDFIRE':
        return Icons.local_fire_department;
      case 'DROUGHT':
        return Icons.wb_sunny;
      case 'TSUNAMI':
        return Icons.waves;
      case 'VOLCANIC ERUPTION':
        return Icons.volcano;
      default:
        return Icons.warning;
    }
  }
} 