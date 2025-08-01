import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/ecore.dart';
import '../models/user.dart';
import '../services/climagame_service.dart';
import '../services/image_upload_service.dart';
import 'dart:typed_data';

class MissionProofScreen extends StatefulWidget {
  final Ecore ecore;
  final EcoreMission mission;
  final AppUser user;

  const MissionProofScreen({
    Key? key,
    required this.ecore,
    required this.mission,
    required this.user,
  }) : super(key: key);

  @override
  State<MissionProofScreen> createState() => _MissionProofScreenState();
}

class _MissionProofScreenState extends State<MissionProofScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mission Proof',
          style: GoogleFonts.questrial(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mission Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.eco,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mission.title,
                          style: GoogleFonts.questrial(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.mission.points} points',
                          style: GoogleFonts.questrial(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Text(
              'Take a photo to prove you completed this mission',
              style: GoogleFonts.questrial(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your photo will be reviewed to verify mission completion. Make sure your photo clearly shows the activity you completed.',
              style: GoogleFonts.questrial(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Photo Preview
            if (_selectedImage != null || _selectedImageBytes != null) ...[
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Camera Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Submit Button
            if (_selectedImage != null || _selectedImageBytes != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Submitting...',
                              style: GoogleFonts.questrial(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Submit Mission',
                          style: GoogleFonts.questrial(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final imageBytes = await ImageUploadService.takePhotoWithCamera();
      if (imageBytes != null) {
        setState(() {
          _selectedImageBytes = imageBytes;
          _selectedImage = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final imageFile = await ImageUploadService.pickImageFromGallery();
      if (imageFile != null) {
        setState(() {
          _selectedImage = imageFile;
          _selectedImageBytes = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _submitMission() async {
    if (_selectedImage == null && _selectedImageBytes == null) {
      _showErrorSnackBar('Please take a photo first');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? proofImageUrl;
      
      // Upload image to Supabase
      if (_selectedImage != null) {
        proofImageUrl = await ImageUploadService.uploadMissionProofImage(
          missionId: widget.mission.id,
          userId: widget.user.id,
          imageFile: _selectedImage,
        );
      } else if (_selectedImageBytes != null) {
        proofImageUrl = await ImageUploadService.uploadMissionProofImage(
          missionId: widget.mission.id,
          userId: widget.user.id,
          imageBytes: _selectedImageBytes,
        );
      }
      
      if (proofImageUrl != null) {
        final success = await ClimaGameService.completeMission(
          ecoreId: widget.ecore.id,
          missionId: widget.mission.id,
          userId: widget.user.id,
          userName: widget.user.displayName,
          proofImageUrl: proofImageUrl,
        );

        if (success) {
          _showSuccessSnackBar('Mission completed successfully!');
          Navigator.pop(context); // Go back to mission detail
          Navigator.pop(context); // Go back to map
        } else {
          _showErrorSnackBar('Failed to complete mission. Please try again.');
        }
      } else {
        _showErrorSnackBar('Failed to upload proof image. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 