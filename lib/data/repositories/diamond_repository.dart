import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/diamond_models.dart';

/// Repository for managing diamond balance and episode unlocks
/// Uses SharedPreferences for persistence
/// Designed to be easily replaceable with server-based storage
class DiamondRepository {
  static const String _balanceKey = 'diamond_balance';
  static const String _unlockedEpisodesKey = 'unlocked_episodes';
  static const String _transactionsKey = 'diamond_transactions';
  static const String _isInitializedKey = 'diamonds_initialized';

  SharedPreferences? _prefs;

  /// Initialize repository
  Future<void> init() async {
    print('DEBUG DiamondRepository.init: START');
    if (_prefs != null) {
      print('DEBUG DiamondRepository.init: Already initialized');
      return;
    }
    
    print('DEBUG DiamondRepository.init: Getting SharedPreferences...');
    _prefs = await SharedPreferences.getInstance();
    print('DEBUG DiamondRepository.init: SharedPreferences obtained');
    
    // Grant test diamonds on first launch
    final isInitialized = _prefs!.getBool(_isInitializedKey) ?? false;
    print('DEBUG DiamondRepository.init: isInitialized=$isInitialized');
    if (!isInitialized) {
      print('DEBUG DiamondRepository.init: Granting test diamonds...');
      await _grantTestDiamonds();
      await _prefs!.setBool(_isInitializedKey, true);
      print('DEBUG DiamondRepository.init: Test diamonds granted');
    }
    print('DEBUG DiamondRepository.init: DONE');
  }

  /// Grant test diamonds for development
  Future<void> _grantTestDiamonds() async {
    final balance = DiamondBalance.testBalance;
    await _saveBalance(balance);
    
    await _recordTransaction(DiamondTransaction(
      id: 'test_grant_${DateTime.now().millisecondsSinceEpoch}',
      type: DiamondTransactionType.testGrant,
      amount: balance.amount,
      timestamp: DateTime.now(),
      description: 'Test-Diamanten für Entwicklung',
    ));
  }

  /// Get current diamond balance
  Future<DiamondBalance> getBalance() async {
    await init();
    
    final balanceJson = _prefs!.getString(_balanceKey);
    if (balanceJson == null) {
      return DiamondBalance.zero;
    }
    
    final data = jsonDecode(balanceJson) as Map<String, dynamic>;
    return DiamondBalance(
      amount: data['amount'] as int,
      lastUpdated: DateTime.parse(data['lastUpdated'] as String),
    );
  }

  /// Save diamond balance
  Future<void> _saveBalance(DiamondBalance balance) async {
    await init();
    
    final data = {
      'amount': balance.amount,
      'lastUpdated': balance.lastUpdated.toIso8601String(),
    };
    await _prefs!.setString(_balanceKey, jsonEncode(data));
  }

  /// Spend diamonds to unlock content
  Future<DiamondBalance> spendDiamonds(int amount, {String? description, String? itemId}) async {
    final currentBalance = await getBalance();
    
    if (!currentBalance.canAfford(amount)) {
      throw InsufficientDiamondsException(
        required: amount,
        available: currentBalance.amount,
      );
    }
    
    final newBalance = currentBalance.spend(amount);
    await _saveBalance(newBalance);
    
    await _recordTransaction(DiamondTransaction(
      id: 'spend_${DateTime.now().millisecondsSinceEpoch}',
      type: DiamondTransactionType.unlock,
      amount: -amount,
      timestamp: DateTime.now(),
      description: description,
      relatedItemId: itemId,
    ));
    
    return newBalance;
  }

  /// Add diamonds (from purchase or bonus)
  Future<DiamondBalance> addDiamonds(
    int amount, {
    DiamondTransactionType type = DiamondTransactionType.purchase,
    String? description,
  }) async {
    final currentBalance = await getBalance();
    final newBalance = currentBalance.add(amount);
    await _saveBalance(newBalance);
    
    await _recordTransaction(DiamondTransaction(
      id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      amount: amount,
      timestamp: DateTime.now(),
      description: description,
    ));
    
    return newBalance;
  }

  /// Check if an episode is unlocked
  Future<bool> isEpisodeUnlocked(String seriesId, int episodeNumber) async {
    // First 3 episodes are always free
    if (episodeNumber <= EpisodeUnlockStatus.freeEpisodeCount) {
      return true;
    }
    
    await init();
    final unlockedJson = _prefs!.getString(_unlockedEpisodesKey);
    if (unlockedJson == null) return false;
    
    final unlocked = (jsonDecode(unlockedJson) as List<dynamic>)
        .cast<String>()
        .toSet();
    
    return unlocked.contains('${seriesId}_$episodeNumber');
  }

  /// Unlock an episode
  Future<void> unlockEpisode(String seriesId, int episodeNumber) async {
    await init();
    
    final unlockedJson = _prefs!.getString(_unlockedEpisodesKey);
    final unlocked = unlockedJson != null
        ? (jsonDecode(unlockedJson) as List<dynamic>).cast<String>().toSet()
        : <String>{};
    
    unlocked.add('${seriesId}_$episodeNumber');
    await _prefs!.setString(_unlockedEpisodesKey, jsonEncode(unlocked.toList()));
  }

  /// Get unlock status for an episode
  Future<EpisodeUnlockStatus> getEpisodeUnlockStatus(
    String seriesId,
    int episodeNumber,
  ) async {
    final isUnlocked = await isEpisodeUnlocked(seriesId, episodeNumber);
    return EpisodeUnlockStatus.forEpisode(
      seriesId: seriesId,
      episodeNumber: episodeNumber,
      isUnlocked: isUnlocked,
    );
  }

  /// Get all unlocked episodes for a series
  Future<Set<int>> getUnlockedEpisodes(String seriesId) async {
    await init();
    
    final unlockedJson = _prefs!.getString(_unlockedEpisodesKey);
    if (unlockedJson == null) {
      // Return first 3 as free
      return {1, 2, 3};
    }
    
    final unlocked = (jsonDecode(unlockedJson) as List<dynamic>)
        .cast<String>()
        .where((key) => key.startsWith('${seriesId}_'))
        .map((key) => int.parse(key.split('_').last))
        .toSet();
    
    // Always include first 3 free episodes
    return {...unlocked, 1, 2, 3};
  }

  /// Record a transaction
  Future<void> _recordTransaction(DiamondTransaction transaction) async {
    await init();
    
    final transactionsJson = _prefs!.getString(_transactionsKey);
    final transactions = transactionsJson != null
        ? (jsonDecode(transactionsJson) as List<dynamic>)
        : <dynamic>[];
    
    transactions.add({
      'id': transaction.id,
      'type': transaction.type.name,
      'amount': transaction.amount,
      'timestamp': transaction.timestamp.toIso8601String(),
      'description': transaction.description,
      'relatedItemId': transaction.relatedItemId,
    });
    
    // Keep only last 100 transactions
    if (transactions.length > 100) {
      transactions.removeRange(0, transactions.length - 100);
    }
    
    await _prefs!.setString(_transactionsKey, jsonEncode(transactions));
  }

  /// Get transaction history
  Future<List<DiamondTransaction>> getTransactionHistory() async {
    await init();
    
    final transactionsJson = _prefs!.getString(_transactionsKey);
    if (transactionsJson == null) return [];
    
    final transactions = (jsonDecode(transactionsJson) as List<dynamic>)
        .map((data) => DiamondTransaction(
              id: data['id'] as String,
              type: DiamondTransactionType.values.firstWhere(
                (t) => t.name == data['type'],
                orElse: () => DiamondTransactionType.purchase,
              ),
              amount: data['amount'] as int,
              timestamp: DateTime.parse(data['timestamp'] as String),
              description: data['description'] as String?,
              relatedItemId: data['relatedItemId'] as String?,
            ))
        .toList();
    
    return transactions.reversed.toList(); // Most recent first
  }

  /// Reset all diamond data (for testing)
  Future<void> resetAll() async {
    await init();
    await _prefs!.remove(_balanceKey);
    await _prefs!.remove(_unlockedEpisodesKey);
    await _prefs!.remove(_transactionsKey);
    await _prefs!.remove(_isInitializedKey);
  }

  /// ADMIN: Set diamond balance to exact amount
  Future<DiamondBalance> setDiamondBalance(int amount) async {
    final newBalance = DiamondBalance(
      amount: amount,
      lastUpdated: DateTime.now(),
    );
    await _saveBalance(newBalance);
    
    await _recordTransaction(DiamondTransaction(
      id: 'admin_set_${DateTime.now().millisecondsSinceEpoch}',
      type: DiamondTransactionType.testGrant,
      amount: amount,
      timestamp: DateTime.now(),
      description: 'Admin: Diamanten auf $amount gesetzt',
    ));
    
    return newBalance;
  }

  /// ADMIN: Reset all episode unlocks (keeps diamonds)
  Future<void> resetAllUnlocks() async {
    await init();
    await _prefs!.remove(_unlockedEpisodesKey);
    
    await _recordTransaction(DiamondTransaction(
      id: 'admin_reset_${DateTime.now().millisecondsSinceEpoch}',
      type: DiamondTransactionType.testGrant,
      amount: 0,
      timestamp: DateTime.now(),
      description: 'Admin: Alle Käufe zurückgesetzt',
    ));
  }
}


