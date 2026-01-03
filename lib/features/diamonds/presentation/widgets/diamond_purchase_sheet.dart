import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/diamond_models.dart';
import '../../providers/diamond_providers.dart';
import 'diamond_balance_widget.dart';

/// Bottom sheet for purchasing diamond packages
class DiamondPurchaseSheet extends ConsumerStatefulWidget {
  const DiamondPurchaseSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const DiamondPurchaseSheet(),
    );
  }

  @override
  ConsumerState<DiamondPurchaseSheet> createState() => _DiamondPurchaseSheetState();
}

class _DiamondPurchaseSheetState extends ConsumerState<DiamondPurchaseSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPurchasing = false;
  int? _purchasingIndex;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _purchasePackage(DiamondPackage package, int index) async {
    if (_isPurchasing) return;

    setState(() {
      _isPurchasing = true;
      _purchasingIndex = index;
    });

    HapticFeedback.mediumImpact();

    // Simulate purchase delay
    await Future.delayed(const Duration(milliseconds: 800));

    final purchaseService = ref.read(purchaseServiceProvider);
    final success = await purchaseService.purchasePackage(package);

    if (mounted) {
      setState(() {
        _isPurchasing = false;
        _purchasingIndex = null;
      });

      if (success) {
        HapticFeedback.heavyImpact();
        _showSuccessAnimation(package);
      }
    }
  }

  void _showSuccessAnimation(DiamondPackage package) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.diamond, color: Color(0xFF4ECDC4)),
            const SizedBox(width: 12),
            Text(
              '+${package.diamonds} Diamanten erhalten!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packages = DiamondPackage.packages;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Diamanten kaufen',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Schalte neue Episoden frei',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const DiamondBalanceWidget(compact: true),
                      ],
                    ),
                  ],
                ),
              ),

              // Package list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(packages.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPackageCard(packages[index], index),
                    );
                  }),
                ),
              ),

              // Footer info
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Testmodus: Käufe sind kostenlos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(DiamondPackage package, int index) {
    final isLoading = _isPurchasing && _purchasingIndex == index;

    return GestureDetector(
      onTap: isLoading ? null : () => _purchasePackage(package, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: package.isBestValue
                ? [const Color(0xFF2D4A3E), const Color(0xFF1E3A2F)]
                : [const Color(0xFF252540), const Color(0xFF1E1E35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: package.isBestValue
                ? const Color(0xFF4ECDC4).withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: package.isBestValue ? 2 : 1,
          ),
          boxShadow: package.isBestValue
              ? [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Diamond icon with amount
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4ECDC4).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.diamond,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  if (package.bonusPercent != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${package.bonusPercent}%',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Package details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (package.isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BELIEBT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${package.diamonds} Diamanten',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Price button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                color: isLoading ? Colors.grey : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '${package.priceEur.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

