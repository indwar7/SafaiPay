class AppConstants {
  // App Info
  static const String appName = 'SafaiPay';
  static const String appTagline = 'Clean Actions. Real Rewards.';

  // Backend API
  static const String apiBaseUrl = 'https://safaipay-backend-production.up.railway.app/api/v1';

  // Waste Types
  static const List<String> wasteTypes = [
    'Dry Waste',
    'Wet Waste',
    'E-Waste',
    'Hazardous Waste',
    'Mixed Waste',
  ];

  // Issue Types (for reporting — must match backend exactly)
  static const List<String> issueTypes = [
    'Overflowing Bin',
    'Dirty Street',
    'Illegal Dumping',
    'Broken Drain',
    'Dead Animal',
    'Construction Waste',
    'Other',
  ];

  // Points
  static const int pointsPerKg = 10;
  static const int reportIssuePoints = 5;
  static const int dailyCheckInPoints = 2;

  // Time Slots
  static const List<String> timeSlots = [
    '6:00 AM - 8:00 AM',
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
  ];
}
