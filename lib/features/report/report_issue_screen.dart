import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import '../../providers/user_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import '../../services/location_service.dart';
import '../../services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  
  File? _selectedImage;
  String? _selectedIssueType;
  String _address = 'Fetching location...';
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  bool _isFetchingLocation = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _autoFetchLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _autoFetchLocation() async {
    setState(() => _isFetchingLocation = true);
    
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      setState(() {
        _address = address;
        _isFetchingLocation = false;
      });
    } else {
      setState(() {
        _address = 'Location permission denied. Please enable location.';
        _isFetchingLocation = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enable location services'),
            backgroundColor: AppColors.orange,
            action: SnackBarAction(
              label: 'Enable',
              textColor: Colors.white,
              onPressed: () async {
                await _locationService.checkAndRequestPermission();
                _autoFetchLocation();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryGreen,
                ),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture using camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.blue,
                ),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select existing photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedIssueType == null ||
        _descriptionController.text.isEmpty ||
        _latitude == null ||
        _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.currentUser;

      if (user == null) return;

      // Upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadImage(_selectedImage!, 'reports');
      }

      // Create report
      final report = ReportModel(
        id: const Uuid().v4(),
        userId: user.uid,
        userName: user.name ?? 'User',
        issueType: _selectedIssueType!,
        description: _descriptionController.text,
        latitude: _latitude!,
        longitude: _longitude!,
        address: _address,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await context.read<ReportProvider>().createReport(report);

      // Award points
      await userProvider.addPoints(5, 'Reported issue: $_selectedIssueType');

      // Update user's total reports
      final updatedUser = user.copyWith(
        totalReports: user.totalReports + 1,
      );
      await userProvider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Report submitted successfully! +5 points',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Report Issue',
          style: TextStyle(color: AppColors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.black),
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Report a cleanliness issue',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '+5 Points',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Camera section with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _selectedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                                CurvedAnimation(
                                  parent: _pulseController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Tap to add photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Camera or Gallery',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location chip with pulse animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isFetchingLocation
                    ? AppColors.orange.withOpacity(0.1)
                    : AppColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isFetchingLocation
                      ? AppColors.orange.withOpacity(0.3)
                      : AppColors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  _isFetchingLocation
                      ? SpinKitPulse(
                          color: AppColors.orange,
                          size: 24,
                        )
                      : const Icon(Icons.location_on, color: AppColors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  if (!_isFetchingLocation)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _autoFetchLocation,
                      color: AppColors.blue,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Issue Type
            const Text(
              'Issue Type *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.issueTypes.map((type) {
                final isSelected = _selectedIssueType == type;
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.95, end: isSelected ? 1.0 : 0.95),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIssueType = type;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.greyLight,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.white,
                            ),
                          if (isSelected) const SizedBox(width: 4),
                          Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Description *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.greyLight,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Submit Report (+5 points)',
              onPressed: _submitReport,
              isLoading: _isLoading,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }
}
