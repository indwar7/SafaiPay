import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
// ignore: unused_import
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import '../../services/location_service.dart';
import '../../services/storage_service.dart';
import '../../core/theme/app_colors.dart';
// ignore: unused_import
import '../../core/widgets/primary_button.dart';
// ignore: unused_import
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

  static const _issueCategories = [
    'Overflowing Bin',
    'Open Garbage',
    'Sewage',
    'Road Waste',
    'Littering',
    'Illegal Dumping',
  ];

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
            backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
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
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Image Source',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.neonLime,
                ),
              ),
              title: Text('Take Photo',
                  style: GoogleFonts.dmSans(color: AppColors.textWhite)),
              subtitle: Text('Capture using camera',
                  style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.neonLime,
                ),
              ),
              title: Text('Choose from Gallery',
                  style: GoogleFonts.dmSans(color: AppColors.textWhite)),
              subtitle: Text('Select existing photo',
                  style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
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
          backgroundColor: AppColors.error,
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
                    color: AppColors.textOnLime,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Report submitted successfully! +5 points',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.neonLime,
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
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Custom back header
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface3,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.textWhite, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Report Issue',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 32,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // CAMERA ZONE
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.neonLime.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
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
                                    top: 12,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: _showImageSourceDialog,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.neonLime,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Change Photo',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textOnLime,
                                          ),
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
                                    scale: Tween<double>(
                                            begin: 0.95, end: 1.05)
                                        .animate(CurvedAnimation(
                                      parent: _pulseController,
                                      curve: Curves.easeInOut,
                                    )),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 32,
                                      color: AppColors.neonLime,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap to capture',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // LOCATION CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.neonLime, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _isFetchingLocation
                                ? _buildShimmerText()
                                : Text(
                                    _address,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                          ),
                          if (!_isFetchingLocation)
                            GestureDetector(
                              onTap: _autoFetchLocation,
                              child: const Icon(Icons.refresh,
                                  size: 20, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ISSUE CATEGORIES
                    Text(
                      "What's the issue?",
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _issueCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final type = _issueCategories[index];
                          final isSelected = _selectedIssueType == type;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedIssueType = type),
                            child: AnimatedScale(
                              scale: isSelected ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.neonLime
                                      : AppColors.surface3,
                                  borderRadius: BorderRadius.circular(22),
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: AppColors.borderActive),
                                ),
                                child: Text(
                                  type,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.textOnLime
                                        : AppColors.textWhite,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // DESCRIPTION
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            minLines: 3,
                            maxLength: 300,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.textWhite,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Describe the issue in detail...',
                              hintStyle: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppColors.textTertiary,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.all(16),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppColors.neonLime,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 14,
                            child: Text(
                              '${_descriptionController.text.length}/300',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // POINTS BANNER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.limePointsBanner,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.neonLime.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.neonLime, size: 28),
                          const SizedBox(width: 12),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "You'll earn  ",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                TextSpan(
                                  text: '+5 POINTS',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 28,
                                    color: AppColors.neonLime,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonLime,
                          disabledBackgroundColor:
                              AppColors.neonLime.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.textOnLime,
                                ),
                              )
                            : Text(
                                'SUBMIT REPORT',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 20,
                                  color: AppColors.textOnLime,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerText() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.3, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      onEnd: () {
        if (_isFetchingLocation) {
          setState(() {});
        }
      },
      child: Container(
        height: 14,
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.borderDefault,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
