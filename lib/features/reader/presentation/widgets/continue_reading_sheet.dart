import 'package:flutter/material.dart';

/// Sheet that asks the user whether to continue reading or start from the beginning
class ContinueReadingSheet extends StatelessWidget {
  final String bookTitle;
  final int savedPageIndex;
  final int totalPages;
  final VoidCallback onContinue;
  final VoidCallback onStartOver;

  const ContinueReadingSheet({
    super.key,
    required this.bookTitle,
    required this.savedPageIndex,
    required this.totalPages,
    required this.onContinue,
    required this.onStartOver,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String bookTitle,
    required int savedPageIndex,
    required int totalPages,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ContinueReadingSheet(
        bookTitle: bookTitle,
        savedPageIndex: savedPageIndex,
        totalPages: totalPages,
        onContinue: () => Navigator.of(context).pop(true),
        onStartOver: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage
    final progress = ((savedPageIndex + 1) / totalPages * 100).round();
    final currentPage = savedPageIndex + 1; // 1-based display
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A2520),
            Color(0xFF1A1512),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DCC0).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: Color(0xFFE8DCC0),
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Lesezeichen gefunden',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8DCC0),
                  fontFamily: 'Mynerve',
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Book title
              Text(
                bookTitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Progress info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gespeicherte Position',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          'Seite $currentPage von $totalPages',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE8DCC0),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Container(
                                width: constraints.maxWidth * (savedPageIndex + 1) / totalPages,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE8DCC0), Color(0xFFFEFFE9)],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      '$progress% gelesen',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Action buttons
              Row(
                children: [
                  // Start over button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onStartOver,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('Von vorne'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Continue button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onContinue,
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Weiterlesen'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE8DCC0),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

