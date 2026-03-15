import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../providers/booking_provider.dart';
import '../../core/theme/app_colors.dart';
// ignore: unused_import
import '../../core/widgets/primary_button.dart';
import '../../core/constants/app_constants.dart';

class BookPickupScreen extends StatefulWidget {
  const BookPickupScreen({super.key});

  @override
  State<BookPickupScreen> createState() => _BookPickupScreenState();
}

class _BookPickupScreenState extends State<BookPickupScreen> {
  final TextEditingController _addressController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String? _selectedWasteType;
  double _weightKg = 5.0;
  bool _isLoading = false;

  static const _wasteTypes = [
    {'name': 'Dry Waste', 'emoji': '\u{1F4E6}', 'rate': '+10/kg'},
    {'name': 'Wet Waste', 'emoji': '\u{1F34C}', 'rate': '+10/kg'},
    {'name': 'E-Waste', 'emoji': '\u{1F50B}', 'rate': '+10/kg'},
    {'name': 'Hazardous', 'emoji': '\u{2622}\u{FE0F}', 'rate': '+10/kg'},
    {'name': 'Mixed', 'emoji': '\u{267B}\u{FE0F}', 'rate': '+10/kg'},
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonLime,
              onPrimary: AppColors.textOnLime,
              surface: AppColors.cardBg,
              onSurface: AppColors.textWhite,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.primaryBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _bookPickup() async {
    if (_selectedDate == null ||
        _selectedTimeSlot == null ||
        _selectedWasteType == null ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final bookingProvider = context.read<BookingProvider>();
    final userProvider = context.read<UserProvider>();

    try {
      await bookingProvider.createBooking(
        wasteType: _selectedWasteType!,
        bookingDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        address: _addressController.text,
      );

      // Reload user profile to reflect updated booking count
      await userProvider.loadUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup booked successfully!'),
            backgroundColor: AppColors.neonLime,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book pickup: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
            // Header
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Pickup',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 36,
                          color: AppColors.textWhite,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Schedule a garbage pickup',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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

                    // ADDRESS
                    Text(
                      'Pickup Address',
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _addressController,
                        maxLines: 3,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textWhite,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your complete address',
                          hintStyle: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.all(16),
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
                    ),
                    const SizedBox(height: 28),

                    // WASTE TYPE SELECTOR
                    Text(
                      'Waste Type',
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _wasteTypes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final wt = _wasteTypes[index];
                          final isSelected =
                              _selectedWasteType == wt['name'];
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedWasteType = wt['name'] as String),
                            child: AnimatedScale(
                              scale: isSelected ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 100,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.neonLime
                                      : AppColors.cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected
                                      ? null
                                      : Border.all(color: AppColors.borderDefault),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      wt['emoji'] as String,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      wt['name'] as String,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.textOnLime
                                            : AppColors.textWhite,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      wt['rate'] as String,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: isSelected
                                            ? AppColors.textOnLime
                                                .withValues(alpha: 0.7)
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // DATE PICKER
                    Text(
                      'Pickup Date',
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: AppColors.neonLime, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(_selectedDate!)
                                  : 'Select date',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                color: _selectedDate != null
                                    ? AppColors.textWhite
                                    : AppColors.textTertiary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary, size: 22),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // TIME SLOTS GRID
                    Text(
                      'Time Slot',
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: AppConstants.timeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = AppConstants.timeSlots[index];
                        final isSelected = _selectedTimeSlot == slot;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedTimeSlot = slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.surface2
                                  : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.neonLime
                                    : AppColors.borderDefault,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: GoogleFonts.barlow(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.neonLime
                                    : AppColors.textWhite,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // WEIGHT ESTIMATE
                    Text(
                      'Estimated Weight',
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        '${_weightKg.toStringAsFixed(1)} kg',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 32,
                          color: AppColors.neonLime,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.neonLime,
                        inactiveTrackColor: AppColors.surface3,
                        thumbColor: AppColors.neonLime,
                        overlayColor: AppColors.neonLime.withValues(alpha: 0.15),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _weightKg,
                        min: 1,
                        max: 50,
                        divisions: 98,
                        onChanged: (v) => setState(() => _weightKg = v),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 kg',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          '50 kg',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Estimated points preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.limePointsBanner,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neonLime.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.neonLime, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Estimated points: ',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '+${(_weightKg * 10).toInt()}',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 22,
                              color: AppColors.neonLime,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CONFIRM BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _bookPickup,
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
                                'CONFIRM BOOKING',
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

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
