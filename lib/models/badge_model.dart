class BadgeModel {
  final String name;
  final String description;
  final String tier; // bronze, silver, gold
  final int triggerValue;
  final int bonusPoints;

  BadgeModel({
    required this.name,
    required this.description,
    required this.tier,
    required this.triggerValue,
    required this.bonusPoints,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tier: json['tier'] ?? 'bronze',
      triggerValue: json['trigger_value'] ?? 0,
      bonusPoints: json['bonus_points'] ?? 0,
    );
  }
}

class UserBadgeModel {
  final BadgeModel badge;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  UserBadgeModel({
    required this.badge,
    required this.progress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      badge: BadgeModel.fromJson(json['badge'] ?? {}),
      progress: json['progress'] ?? 0,
      isUnlocked: json['is_unlocked'] ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'])
          : null,
    );
  }
}
