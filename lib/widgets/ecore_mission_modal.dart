import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/ecore.dart';
import '../models/user.dart';
import '../services/climagame_service.dart';
import '../screens/mission_detail_screen.dart';
import '../utils/transitions.dart';

class EcoreMissionModal extends StatefulWidget {
  final Ecore ecore;
  final AppUser user;
  final VoidCallback onMissionCompleted;

  const EcoreMissionModal({
    Key? key,
    required this.ecore,
    required this.user,
    required this.onMissionCompleted,
  }) : super(key: key);

  @override
  State<EcoreMissionModal> createState() => _EcoreMissionModalState();
}

class _EcoreMissionModalState extends State<EcoreMissionModal> {
  bool _isLoading = false;
  bool _canDoMission = true;
  int _userDailyMissionCount = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _checkUserMissionLimit();
    _startCooldownTimer();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkUserMissionLimit() async {
    try {
      final canDo = await ClimaGameService.canUserDoMission(widget.user.id);
      final dailyCount = await ClimaGameService.getUserDailyMissionCount(widget.user.id);

      if (mounted) {
        setState(() {
          _canDoMission = canDo;
          _userDailyMissionCount = dailyCount;
        });
      }
    } catch (e) {
      print('❌ Error checking user mission limit: $e');
    }
  }

  void _startCooldownTimer() {
    if (widget.ecore.isInCoolingTime) {
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {

          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedMissions = widget.ecore.missions.where((m) => m.isCompleted).length;
    final totalMissions = widget.ecore.missions.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [

          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.ecore.isConquered ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ecore.name,
                        style: GoogleFonts.questrial(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.ecore.isConquered
                            ? 'Conquered by ${widget.ecore.conqueredBySchoolName}'
                            : '$completedMissions/$totalMissions missions completed',
                        style: GoogleFonts.questrial(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.ecore.isInCoolingTime)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cooling',
                      style: GoogleFonts.questrial(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (!_canDoMission)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Daily mission limit reached (3/3)',
                      style: GoogleFonts.questrial(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: widget.ecore.isInCoolingTime
                ? _buildCooldownContent()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: widget.ecore.missions.length,
                    itemBuilder: (context, index) {
                      final mission = widget.ecore.missions[index];
                      return _buildMissionCard(mission);
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.questrial(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(EcoreMission mission) {
    final canStartMission = !mission.isCompleted &&
                           widget.ecore.canBeConquered &&
                           _canDoMission;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mission.isCompleted ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mission.isCompleted ? Colors.green : Colors.grey[300]!,
          width: mission.isCompleted ? 2 : 1,
        ),
        boxShadow: mission.isCompleted ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: mission.isCompleted ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ] : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: mission.imageUrl.isNotEmpty
                  ? _buildMissionImage(mission)
                  : Container(
                      color: mission.isCompleted ? Colors.green : Colors.grey[300],
                      child: Icon(
                        mission.isCompleted ? Icons.check_circle : Icons.eco,
                        color: Colors.white,
                        size: mission.isCompleted ? 24 : 20,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: GoogleFonts.questrial(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SvgPicture.asset(
                      'icons/green_points.svg',
                      width: 16,
                      height: 16,
                      placeholderBuilder: (context) => Icon(Icons.eco, color: Colors.green, size: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${mission.points} points',
                      style: GoogleFonts.questrial(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (mission.isCompleted) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'COMPLETED',
                          style: GoogleFonts.questrial(
                            fontSize: 10,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${mission.completedByUserName ?? 'Unknown User'}',
                    style: GoogleFonts.questrial(
                      fontSize: 10,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!mission.isCompleted && widget.ecore.canBeConquered)
            TextButton(
              onPressed: canStartMission ? () => _openMissionDetail(mission) : null,
              style: TextButton.styleFrom(
                foregroundColor: canStartMission ? Colors.green : Colors.grey[400],
              ),
              child: Text(
                canStartMission ? 'Start' : 'Limit Reached',
                style: GoogleFonts.questrial(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: canStartMission ? Colors.green : Colors.grey[400],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openMissionDetail(EcoreMission mission) {
    Navigator.push(
      context,
      AppTransitions.cardTransition(MissionDetailScreen(
        mission: mission,
        ecore: widget.ecore,
        user: widget.user,
      )),
    ).then((_) {

      _checkUserMissionLimit();
      widget.onMissionCompleted();
    });
  }

  Widget _buildMissionImage(EcoreMission mission) {

    if (mission.imageUrl.startsWith('assets/images/')) {
      return Image.asset(
        mission.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: mission.isCompleted ? Colors.green : Colors.grey[300],
            child: Icon(
              mission.isCompleted ? Icons.check_circle : Icons.eco,
              color: Colors.white,
              size: mission.isCompleted ? 24 : 20,
            ),
          );
        },
      );
    }

    if (mission.imageUrl.startsWith('http://') || mission.imageUrl.startsWith('https://')) {
      return Image.network(
        mission.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: mission.isCompleted ? Colors.green : Colors.grey[300],
            child: Icon(
              mission.isCompleted ? Icons.check_circle : Icons.eco,
              color: Colors.white,
              size: mission.isCompleted ? 24 : 20,
            ),
          );
        },
      );
    }

    return Container(
      color: mission.isCompleted ? Colors.green : Colors.grey[300],
      child: Icon(
        mission.isCompleted ? Icons.check_circle : Icons.eco,
        color: Colors.white,
        size: mission.isCompleted ? 24 : 20,
      ),
    );
  }

  Widget _buildCooldownContent() {
    final remaining = widget.ecore.coolingTimeEnd?.difference(DateTime.now()) ?? Duration.zero;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Icon(
              Icons.timer,
              color: Colors.orange,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Cooling Time',
            style: GoogleFonts.questrial(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'This ecore is currently in cooldown period.\nPlease wait before attempting missions again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.questrial(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              children: [
                Text(
                  'Time Remaining',
                  style: GoogleFonts.questrial(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: GoogleFonts.questrial(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (widget.ecore.isConquered)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Conquered by ${widget.ecore.conqueredBySchoolName ?? 'Unknown School'}',
                    style: GoogleFonts.questrial(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}