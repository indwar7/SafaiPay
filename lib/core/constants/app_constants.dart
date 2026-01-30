class AppConstants {
  // App Info
  static const String appName = 'SafaiPay';
  static const String appTagline = 'Clean Actions. Real Rewards.';
  
  // Waste Types
  static const List<String> wasteTypes = [
    'Dry Waste',
    'Wet Waste',
    'E-Waste',
    'Hazardous Waste',
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
  ];
  
  // Issue Types (for reporting)
  static const List<String> issueTypes = [
    'Overflowing Bin',
    'Illegal Dumping',
    'Littering',
    'Broken Bin',
    'Uncollected Waste',
    'Other',
  ];
  
  // Points
  static const int pointsPerKg = 10;
  static const int reportIssuePoints = 5;
  static const int dailyCheckInPoints = 2;
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String bookingsCollection = 'bookings';
  static const String reportsCollection = 'reports';
  static const String transactionsCollection = 'transactions';
  static const String collectorsCollection = 'collectors';
  
  // Time Slots
  static const List<String> timeSlots = [
    '6:00 AM - 8:00 AM',
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 2:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
  ];
}
