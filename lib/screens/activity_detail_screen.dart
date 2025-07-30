import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/user.dart';
import '../services/activity_service.dart';
import '../services/user_service.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final AppUser currentUser;
  final String schoolId;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
    required this.currentUser,
    required this.schoolId,
  }) : super(key: key);

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final ActivityService _activityService = ActivityService();
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _checkJoinStatus();
  }

  Future<void> _checkJoinStatus() async {
    setState(() => _isLoading = true);
    try {
      final isJoined = await _activityService.isUserJoined(widget.schoolId, widget.activity.id, widget.currentUser.id);
      setState(() {
        _isJoined = isJoined;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ActivityDetail: Error checking join status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleJoin() async {
    setState(() => _isLoading = true);
    try {
      if (_isJoined) {
        await _activityService.leaveActivity(widget.schoolId, widget.activity.id, widget.currentUser.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You left the activity'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await _activityService.joinActivity(widget.schoolId, widget.activity.id, widget.currentUser.id);
        
        // Award points and update user stats
        await _userService.addUserPoints(widget.currentUser.id, widget.activity.points);
        await _userService.addUserAction(widget.currentUser.id);
        await _userService.addWeekPoints(widget.currentUser.id, widget.activity.points);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You joined the activity! +${widget.activity.points} points earned!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _isJoined = !_isJoined;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ActivityDetail: Error toggling join: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${_isJoined ? 'leave' : 'join'} activity'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Activity image
            if (widget.activity.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  widget.activity.imageUrl!,
                fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and type
                  Text(
                    widget.activity.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.activity.type,
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.activity.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Activity details
                  _buildDetailRow(Icons.calendar_today, 'Date', _formatDate(widget.activity.date)),
                  _buildDetailRow(Icons.people, 'Participants', '${widget.activity.participantCount} people'),
                  _buildDetailRow(Icons.star, 'Points', '${widget.activity.points} points'),
                  
                  SizedBox(height: 32),
                  
                  // Join/Leave button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _toggleJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isJoined ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isJoined ? 'Leave Activity' : 'Join Activity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Additional info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow('Type', widget.activity.type),
                        _buildInfoRow('Points Awarded', '${widget.activity.points}'),
                        _buildInfoRow('Current Participants', '${widget.activity.participantCount}'),
                        _buildInfoRow('Date', _formatDate(widget.activity.date)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
            children: [
          Icon(icon, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
              Expanded(
                child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 