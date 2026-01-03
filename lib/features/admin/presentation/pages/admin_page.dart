import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/diamond_models.dart';
import '../../../diamonds/providers/diamond_providers.dart';

/// Admin page for managing diamonds and purchases
class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  String _diamondInput = '';
  bool _isResetting = false;
  bool _isSaving = false;

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'C') {
        _diamondInput = '';
      } else if (key == '⌫') {
        if (_diamondInput.isNotEmpty) {
          _diamondInput = _diamondInput.substring(0, _diamondInput.length - 1);
        }
      } else {
        // Limit to 7 digits (max 9,999,999)
        if (_diamondInput.length < 7) {
          _diamondInput += key;
        }
      }
    });
  }

  Future<void> _setDiamonds() async {
    if (_diamondInput.isEmpty) return;
    
    final amount = int.tryParse(_diamondInput);
    if (amount == null) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final repo = ref.read(diamondRepositoryProvider);
      await repo.setDiamondBalance(amount);
      ref.invalidate(diamondBalanceProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diamanten auf $amount gesetzt'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        setState(() => _diamondInput = '');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resetAllPurchases() async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Alle Käufe zurücksetzen?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Alle freigeschalteten Episoden werden gesperrt. Diamanten bleiben erhalten.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isResetting = true);
    HapticFeedback.heavyImpact();

    try {
      final repo = ref.read(diamondRepositoryProvider);
      await repo.resetAllUnlocks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alle Käufe wurden zurückgesetzt'),
            backgroundColor: Color(0xFF4ECDC4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(diamondBalanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFF4ECDC4), size: 24),
            SizedBox(width: 8),
            Text(
              'Admin',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Balance Display
              _buildCurrentBalance(balanceAsync),
              
              const SizedBox(height: 32),
              
              // Diamond Input Section
              _buildDiamondInputSection(),
              
              const SizedBox(height: 32),
              
              // Reset Section
              _buildResetSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBalance(AsyncValue<DiamondBalance> balanceAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          const Text(
            'AKTUELLES GUTHABEN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.diamond,
                color: Color(0xFF4ECDC4),
                size: 36,
              ),
              const SizedBox(width: 12),
              balanceAsync.when(
                data: (balance) => Text(
                  '${balance.amount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                loading: () => const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF4ECDC4),
                ),
                error: (_, __) => const Text(
                  'Fehler',
                  style: TextStyle(color: Colors.red, fontSize: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'DIAMANTEN SETZEN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.diamond_outlined,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _diamondInput.isEmpty ? '0' : _diamondInput,
                  style: TextStyle(
                    color: _diamondInput.isEmpty ? Colors.white38 : Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Numpad
          _buildNumpad(),
          
          const SizedBox(height: 16),
          
          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _diamondInput.isEmpty || _isSaving ? null : _setDiamonds,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.white12,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Diamanten setzen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildNumpadKey(key),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumpadKey(String key) {
    final isAction = key == 'C' || key == '⌫';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPressed(key),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 70,
          height: 56,
          decoration: BoxDecoration(
            color: isAction 
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              key,
              style: TextStyle(
                color: isAction ? Colors.white54 : Colors.white,
                fontSize: key == '⌫' ? 20 : 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                'GEFAHRENZONE',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Setzt alle freigeschalteten Episoden zurück. Diamanten bleiben erhalten.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isResetting ? null : _resetAllPurchases,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isResetting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restart_alt, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Alle Käufe zurücksetzen',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

