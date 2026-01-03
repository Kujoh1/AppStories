import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/diamond_models.dart';
import '../../providers/diamond_providers.dart';
import '../pages/diamond_purchase_page.dart';

/// Dialog for unlocking an episode with diamonds
class EpisodeUnlockDialog extends ConsumerStatefulWidget {
  final String seriesId;
  final int episodeNumber;
  final String episodeTitle;
  final VoidCallback onUnlocked;

  const EpisodeUnlockDialog({
    super.key,
    required this.seriesId,
    required this.episodeNumber,
    required this.episodeTitle,
    required this.onUnlocked,
  });

  static Future<bool> show(
    BuildContext context, {
    required String seriesId,
    required int episodeNumber,
    required String episodeTitle,
    required VoidCallback onUnlocked,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => EpisodeUnlockDialog(
        seriesId: seriesId,
        episodeNumber: episodeNumber,
        episodeTitle: episodeTitle,
        onUnlocked: onUnlocked,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<EpisodeUnlockDialog> createState() => _EpisodeUnlockDialogState();
}

class _EpisodeUnlockDialogState extends ConsumerState<EpisodeUnlockDialog>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _unlockController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _unlockAnimation;
  
  bool _isUnlocking = false;
  bool _unlockSuccess = false;

  @override
  void initState() {
    super.initState();
    
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    
    _unlockAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _unlockController, curve: Curves.easeOut),
    );
    
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  Future<void> _attemptUnlock() async {
    if (_isUnlocking) return;

    setState(() => _isUnlocking = true);
    HapticFeedback.mediumImpact();

    final unlockService = ref.read(episodeUnlockServiceProvider);
    final success = await unlockService.unlockEpisode(
      widget.seriesId,
      widget.episodeNumber,
    );

    if (mounted) {
      if (success) {
        setState(() => _unlockSuccess = true);
        HapticFeedback.heavyImpact();
        await _unlockController.forward();
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onUnlocked();
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() => _isUnlocking = false);
        _showInsufficientDiamondsDialog();
      }
    }
  }

  void _showInsufficientDiamondsDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.diamond_outlined, color: Color(0xFF4ECDC4)),
            SizedBox(width: 12),
            Text(
              'Nicht genug Diamanten',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Du benötigst mehr Diamanten, um diese Episode freizuschalten.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              DiamondPurchasePage.show(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.black,
            ),
            child: const Text('Diamanten kaufen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(diamondBalanceProvider);
    final unlockCost = EpisodeUnlockStatus.standardUnlockCost;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E2E), Color(0xFF151520)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: _unlockSuccess ? _buildSuccessState() : _buildUnlockPrompt(balanceAsync, unlockCost),
        ),
      ),
    );
  }

  Widget _buildUnlockPrompt(AsyncValue<DiamondBalance> balanceAsync, int unlockCost) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon with glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4ECDC4).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 40,
              color: Color(0xFF4ECDC4),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Episode ${widget.episodeNumber}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.episodeTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Cost display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Freischalten für',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.diamond,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$unlockCost',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4ECDC4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Current balance
          balanceAsync.when(
            data: (balance) => Text(
              'Dein Guthaben: ${balance.amount} Diamanten',
              style: TextStyle(
                fontSize: 12,
                color: balance.canAfford(unlockCost)
                    ? Colors.white.withOpacity(0.5)
                    : Colors.red.withOpacity(0.8),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),

          // Buttons - Freischalten oben, Abbrechen darunter
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUnlocking ? null : _attemptUnlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUnlocking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_open, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Freischalten',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return AnimatedBuilder(
      animation: _unlockAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_unlockAnimation.value.clamp(0.0, 1.0) * 0.2),
          child: Opacity(
            opacity: _unlockAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon with particles
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4ECDC4).withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Freigeschaltet!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Episode ${widget.episodeNumber} ist jetzt verfügbar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

