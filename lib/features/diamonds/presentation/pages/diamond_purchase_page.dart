import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/diamond_models.dart';
import '../../providers/diamond_providers.dart';
import '../widgets/diamond_balance_widget.dart';

/// Full page for purchasing diamond packages
class DiamondPurchasePage extends ConsumerStatefulWidget {
  const DiamondPurchasePage({super.key});

  /// Navigate to the purchase page
  static Future<void> show(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DiamondPurchasePage(),
      ),
    );
  }

  @override
  ConsumerState<DiamondPurchasePage> createState() => _DiamondPurchasePageState();
}

class _DiamondPurchasePageState extends ConsumerState<DiamondPurchasePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Diamanten kaufen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: DiamondBalanceWidget(compact: true),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entryController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
              child: child,
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E1E2E),
                        const Color(0xFF151520),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF4ECDC4).withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: Color(0xFF4ECDC4),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Schalte neue Episoden frei',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mit Diamanten kannst du weitere Kapitel deiner Lieblings-Geschichten freischalten.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section title
                Text(
                  'PAKETE WÄHLEN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Package list
                ...List.generate(packages.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPackageCard(packages[index], index),
                  );
                }),

                const SizedBox(height: 24),

                // Footer info
                Center(
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
              width: 50,
              height: 50,
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

            const SizedBox(width: 12),

            // Package details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          package.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (package.isBestValue) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BELIEBT',
                            style: TextStyle(
                              fontSize: 8,
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Price button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

