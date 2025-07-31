import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/image_upload_service.dart';
import 'dart:io';
import 'dart:typed_data';

class ProfilePictureUploadScreen extends StatefulWidget {
  final AppUser user;
  final bool isFromRegistration;

  const ProfilePictureUploadScreen({
    Key? key,
    required this.user,
    this.isFromRegistration = false,
  }) : super(key: key);

  @override
  State<ProfilePictureUploadScreen> createState() => _ProfilePictureUploadScreenState();
}

class _ProfilePictureUploadScreenState extends State<ProfilePictureUploadScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _previewImageUrl;
  bool _isImageValid = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final imageFile = await ImageUploadService.pickImageFromGallery();
      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
          _selectedImageBytes = null;
          _isImageValid = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final imageBytes = await ImageUploadService.takePhotoWithCamera();
      if (imageBytes != null) {
        setState(() {
          _selectedImageBytes = imageBytes;
          _selectedImageFile = null;
          _isImageValid = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _saveProfilePicture() async {
    if (!_isImageValid) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      
      if (_selectedImageFile != null) {
        imageUrl = await ImageUploadService.uploadProfilePicture(
          userId: widget.user.id,
          imageFile: _selectedImageFile,
        );
      } else if (_selectedImageBytes != null) {
        imageUrl = await ImageUploadService.uploadProfilePicture(
          userId: widget.user.id,
          imageBytes: _selectedImageBytes,
        );
      }

      if (imageUrl != null) {
        final userService = UserService();
        await userService.updateUserProfilePic(widget.user.id, imageUrl);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          if (widget.isFromRegistration) {
            // Navigate to home screen after registration
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          } else {
            // Go back to previous screen and refresh data
            Navigator.pop(context, true); // Pass true to indicate data was updated
          }
        }
      } else {
        _showErrorSnackBar('Failed to upload image');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile picture: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _skipForNow() {
    if (widget.isFromRegistration) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile Picture Preview
                        _buildProfilePreview(),
                        const SizedBox(height: 32),
                        
                        // Upload Form
                        _buildUploadForm(),
                        const SizedBox(height: 32),
                        
                        // Action Buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (!widget.isFromRegistration)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isFromRegistration 
                      ? 'Welcome to ClimaCore!'
                      : 'Update Profile Picture',
                  style: GoogleFonts.questrial(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isFromRegistration
                      ? 'Let\'s personalize your profile'
                      : 'Choose a profile picture that represents you',
                  style: GoogleFonts.questrial(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePreview() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Profile Picture
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 4),
              ),
              child: ClipOval(
                child: _previewImageUrl != null
                    ? Image.network(
                        _previewImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildDefaultAvatar();
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
            
            // Upload Icon Overlay
            if (_previewImageUrl == null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[300]!, Colors.green[600]!],
        ),
      ),
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUploadForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Profile Picture',
          style: GoogleFonts.questrial(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a photo from your gallery or take a new one',
          style: GoogleFonts.questrial(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        
        // Image Selection Status
        if (_selectedImageFile != null || _selectedImageBytes != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image Selected',
                        style: GoogleFonts.questrial(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        _selectedImageFile != null 
                            ? 'File: ${_selectedImageFile!.path.split('/').last}'
                            : 'Camera photo selected',
                        style: GoogleFonts.questrial(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedImageFile = null;
                      _selectedImageBytes = null;
                      _isImageValid = false;
                    });
                  },
                  icon: Icon(Icons.clear, color: Colors.green[600]),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Upload Options
        Row(
          children: [
            Expanded(
              child: _buildUploadOption(
                icon: Icons.photo_library,
                title: 'Gallery',
                subtitle: 'Choose from photos',
                onTap: _pickImageFromGallery,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUploadOption(
                icon: Icons.camera_alt,
                title: 'Camera',
                subtitle: 'Take a photo',
                onTap: _takePhotoWithCamera,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.questrial(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.questrial(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isImageValid && !_isLoading ? _saveProfilePicture : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.isFromRegistration ? 'Continue' : 'Save Changes',
                    style: GoogleFonts.questrial(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        
        if (widget.isFromRegistration) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : _skipForNow,
            child: Text(
              'Skip for now',
              style: GoogleFonts.questrial(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ],
    );
  }
} 