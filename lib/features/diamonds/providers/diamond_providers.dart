import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/diamond_repository.dart';
import '../../../domain/models/diamond_models.dart';

/// Provider for the DiamondRepository singleton
final diamondRepositoryProvider = Provider<DiamondRepository>((ref) {
  return DiamondRepository();
});

/// Provider for current diamond balance
/// Watches for changes and updates automatically
final diamondBalanceProvider = StateNotifierProvider<DiamondBalanceNotifier, AsyncValue<DiamondBalance>>((ref) {
  final repository = ref.watch(diamondRepositoryProvider);
  return DiamondBalanceNotifier(repository);
});

/// Notifier for diamond balance state
class DiamondBalanceNotifier extends StateNotifier<AsyncValue<DiamondBalance>> {
  final DiamondRepository _repository;

  DiamondBalanceNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final balance = await _repository.getBalance();
      state = AsyncValue.data(balance);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Spend diamonds
  Future<bool> spend(int amount, {String? description, String? itemId}) async {
    try {
      final newBalance = await _repository.spendDiamonds(
        amount,
        description: description,
        itemId: itemId,
      );
      state = AsyncValue.data(newBalance);
      return true;
    } on InsufficientDiamondsException {
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Add diamonds (for testing or mock purchases)
  Future<void> add(int amount, {DiamondTransactionType type = DiamondTransactionType.purchase}) async {
    try {
      final newBalance = await _repository.addDiamonds(amount, type: type);
      state = AsyncValue.data(newBalance);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh balance from storage
  Future<void> refresh() async {
    await _loadBalance();
  }
}

/// Provider for episode unlock status
final episodeUnlockStatusProvider = FutureProvider.family<EpisodeUnlockStatus, ({String seriesId, int episodeNumber})>((ref, params) async {
  final repository = ref.watch(diamondRepositoryProvider);
  return repository.getEpisodeUnlockStatus(params.seriesId, params.episodeNumber);
});

/// Provider for all unlocked episodes in a series
final unlockedEpisodesProvider = FutureProvider.family<Set<int>, String>((ref, seriesId) async {
  final repository = ref.watch(diamondRepositoryProvider);
  return repository.getUnlockedEpisodes(seriesId);
});

/// Service for handling episode unlocks with diamond payment
class EpisodeUnlockService {
  final DiamondRepository _repository;
  final DiamondBalanceNotifier _balanceNotifier;

  EpisodeUnlockService(this._repository, this._balanceNotifier);

  /// Check if episode can be accessed (free or unlocked)
  Future<bool> canAccessEpisode(String seriesId, int episodeNumber) async {
    return _repository.isEpisodeUnlocked(seriesId, episodeNumber);
  }

  /// Attempt to unlock an episode
  /// Returns true if successful, false if insufficient diamonds
  Future<bool> unlockEpisode(String seriesId, int episodeNumber) async {
    final status = await _repository.getEpisodeUnlockStatus(seriesId, episodeNumber);
    
    // Already unlocked or free
    if (status.isUnlocked) return true;
    
    // Try to spend diamonds
    final success = await _balanceNotifier.spend(
      status.unlockCost,
      description: 'Episode $episodeNumber freigeschaltet',
      itemId: '${seriesId}_$episodeNumber',
    );
    
    if (success) {
      await _repository.unlockEpisode(seriesId, episodeNumber);
      return true;
    }
    
    return false;
  }

  /// Get unlock cost for an episode
  Future<int> getUnlockCost(String seriesId, int episodeNumber) async {
    final status = await _repository.getEpisodeUnlockStatus(seriesId, episodeNumber);
    return status.unlockCost;
  }
}

/// Provider for episode unlock service
final episodeUnlockServiceProvider = Provider<EpisodeUnlockService>((ref) {
  final repository = ref.watch(diamondRepositoryProvider);
  final balanceNotifier = ref.watch(diamondBalanceProvider.notifier);
  return EpisodeUnlockService(repository, balanceNotifier);
});

/// Mock purchase service for testing
/// Will be replaced with Apple IAP in production
class MockPurchaseService {
  final DiamondBalanceNotifier _balanceNotifier;

  MockPurchaseService(this._balanceNotifier);

  /// Simulate purchasing a diamond package
  Future<bool> purchasePackage(DiamondPackage package) async {
    // In production, this would call Apple IAP
    // For now, just add the diamonds
    await _balanceNotifier.add(
      package.diamonds,
      type: DiamondTransactionType.purchase,
    );
    return true;
  }

  /// Get available packages
  List<DiamondPackage> getAvailablePackages() {
    return DiamondPackage.packages;
  }
}

/// Provider for mock purchase service
final purchaseServiceProvider = Provider<MockPurchaseService>((ref) {
  final balanceNotifier = ref.watch(diamondBalanceProvider.notifier);
  return MockPurchaseService(balanceNotifier);
});

