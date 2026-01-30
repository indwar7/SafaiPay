import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

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
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
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
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;

    if (user == null) return;

    final booking = BookingModel(
      id: const Uuid().v4(),
      userId: user.uid,
      userName: user.name ?? 'User',
      phoneNumber: user.phoneNumber,
      address: _addressController.text,
      wasteType: _selectedWasteType!,
      bookingDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      createdAt: DateTime.now(),
    );

    try {
      await context.read<BookingProvider>().createBooking(booking);
      
      // Update user's total bookings
      final updatedUser = user.copyWith(
        totalBookings: user.totalBookings + 1,
      );
      await userProvider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup booked successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book pickup: $e'),
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
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Pickup',
          style: TextStyle(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule a pickup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Book a waste collection from your doorstep',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 32),

            // Address
            const Text(
              'Pickup Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your complete address',
              ),
            ),
            const SizedBox(height: 24),

            // Waste Type
            const Text(
              'Waste Type',
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
              children: AppConstants.wasteTypes.map((type) {
                final isSelected = _selectedWasteType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWasteType = type;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.greyLight,
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Date
            const Text(
              'Pickup Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                          : 'Select date',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null
                            ? AppColors.black
                            : AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time Slot
            const Text(
              'Time Slot',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: AppConstants.timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlot = slot;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.greyLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.greyText,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          slot,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Confirm Booking',
              onPressed: _bookPickup,
              isLoading: _isLoading,
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
