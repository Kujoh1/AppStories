import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/diamond_providers.dart';

/// Stylish diamond balance display widget
/// Shows current diamond count with animated updates
class DiamondBalanceWidget extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  final bool compact;

  const DiamondBalanceWidget({
    super.key,
    this.onTap,
    this.compact = false,
  });

  @override
  ConsumerState<DiamondBalanceWidget> createState() => _DiamondBalanceWidgetState();
}

class _DiamondBalanceWidgetState extends ConsumerState<DiamondBalanceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int? _previousBalance;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerPulse() {
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(diamondBalanceProvider);

    return balanceAsync.when(
      data: (balance) {
        // Trigger pulse animation on balance change
        if (_previousBalance != null && _previousBalance != balance.amount) {
          _triggerPulse();
        }
        _previousBalance = balance.amount;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              );
            },
            child: _buildBalanceDisplay(balance.amount),
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
    );
  }

  Widget _buildBalanceDisplay(int amount) {
    if (widget.compact) {
      return _buildCompactDisplay(amount);
    }
    return _buildFullDisplay(amount);
  }

  Widget _buildCompactDisplay(int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E2E),
            const Color(0xFF2D2D44),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDiamondIcon(size: 18),
          const SizedBox(width: 6),
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          if (widget.onTap != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.add_circle_outline,
              size: 14,
              color: const Color(0xFF4ECDC4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullDisplay(int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDiamondIcon(size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Diamanten',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatAmount(amount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (widget.onTap != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 16,
                color: Color(0xFF4ECDC4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiamondIcon({required double size}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: size * 1.5,
          height: size * 1.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF4ECDC4).withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Diamond icon
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF4ECDC4),
              Color(0xFF44A08D),
              Color(0xFF4ECDC4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(
            Icons.diamond_outlined,
            size: size,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF4ECDC4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.error_outline,
        size: 18,
        color: Colors.red,
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}

