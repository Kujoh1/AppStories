/// Diamond currency and purchase system models

/// Represents the user's diamond balance
class DiamondBalance {
  final int amount;
  final DateTime lastUpdated;

  const DiamondBalance({
    required this.amount,
    required this.lastUpdated,
  });

  DiamondBalance copyWith({int? amount, DateTime? lastUpdated}) {
    return DiamondBalance(
      amount: amount ?? this.amount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if user can afford a purchase
  bool canAfford(int cost) => amount >= cost;

  /// Create a new balance after spending diamonds
  DiamondBalance spend(int cost) {
    if (!canAfford(cost)) {
      throw InsufficientDiamondsException(required: cost, available: amount);
    }
    return DiamondBalance(
      amount: amount - cost,
      lastUpdated: DateTime.now(),
    );
  }

  /// Create a new balance after adding diamonds
  DiamondBalance add(int diamonds) {
    return DiamondBalance(
      amount: amount + diamonds,
      lastUpdated: DateTime.now(),
    );
  }

  /// Default starting balance for testing
  static DiamondBalance get testBalance => DiamondBalance(
    amount: 100000,
    lastUpdated: DateTime.now(),
  );

  /// Empty balance
  static DiamondBalance get zero => DiamondBalance(
    amount: 0,
    lastUpdated: DateTime.now(),
  );
}

/// Exception thrown when user doesn't have enough diamonds
class InsufficientDiamondsException implements Exception {
  final int required;
  final int available;

  const InsufficientDiamondsException({
    required this.required,
    required this.available,
  });

  @override
  String toString() => 'Insufficient diamonds: need $required, have $available';
}

/// Represents a diamond package available for purchase
class DiamondPackage {
  final String id;
  final String name;
  final int diamonds;
  final double priceEur;
  final String? appleProductId; // For future IAP integration
  final bool isBestValue;
  final int? bonusPercent;

  const DiamondPackage({
    required this.id,
    required this.name,
    required this.diamonds,
    required this.priceEur,
    this.appleProductId,
    this.isBestValue = false,
    this.bonusPercent,
  });

  /// Predefined diamond packages
  static const List<DiamondPackage> packages = [
    DiamondPackage(
      id: 'diamonds_small',
      name: 'Kleines Paket',
      diamonds: 50,
      priceEur: 0.99,
      appleProductId: 'com.appstories.diamonds.50',
    ),
    DiamondPackage(
      id: 'diamonds_medium',
      name: 'Mittleres Paket',
      diamonds: 150,
      priceEur: 2.49,
      appleProductId: 'com.appstories.diamonds.150',
      bonusPercent: 10,
    ),
    DiamondPackage(
      id: 'diamonds_large',
      name: 'Großes Paket',
      diamonds: 400,
      priceEur: 4.99,
      appleProductId: 'com.appstories.diamonds.400',
      bonusPercent: 25,
      isBestValue: true,
    ),
    DiamondPackage(
      id: 'diamonds_mega',
      name: 'Mega Paket',
      diamonds: 1000,
      priceEur: 9.99,
      appleProductId: 'com.appstories.diamonds.1000',
      bonusPercent: 40,
    ),
  ];
}

/// Represents the unlock status of an episode
class EpisodeUnlockStatus {
  final String seriesId;
  final int episodeNumber;
  final bool isUnlocked;
  final bool isFree; // First 3 episodes are free
  final int unlockCost;
  final DateTime? unlockedAt;

  const EpisodeUnlockStatus({
    required this.seriesId,
    required this.episodeNumber,
    required this.isUnlocked,
    required this.isFree,
    required this.unlockCost,
    this.unlockedAt,
  });

  /// Cost to unlock an episode (first 3 are free)
  static const int standardUnlockCost = 5;

  /// Number of free episodes per series
  static const int freeEpisodeCount = 3;

  /// Check if this episode requires payment
  bool get requiresPayment => !isFree && !isUnlocked;

  /// Create status for an episode
  static EpisodeUnlockStatus forEpisode({
    required String seriesId,
    required int episodeNumber,
    required bool isUnlocked,
  }) {
    final isFree = episodeNumber <= freeEpisodeCount;
    return EpisodeUnlockStatus(
      seriesId: seriesId,
      episodeNumber: episodeNumber,
      isUnlocked: isUnlocked || isFree,
      isFree: isFree,
      unlockCost: isFree ? 0 : standardUnlockCost,
    );
  }
}

/// Record of a diamond transaction
class DiamondTransaction {
  final String id;
  final DiamondTransactionType type;
  final int amount;
  final DateTime timestamp;
  final String? description;
  final String? relatedItemId; // e.g., episode ID for unlock

  const DiamondTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.description,
    this.relatedItemId,
  });
}

/// Type of diamond transaction
enum DiamondTransactionType {
  purchase,    // Bought diamonds with real money
  unlock,      // Spent diamonds to unlock content
  bonus,       // Received bonus diamonds
  refund,      // Refunded diamonds
  testGrant,   // Test diamonds granted
}

