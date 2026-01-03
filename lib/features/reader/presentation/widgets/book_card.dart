import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/book_graph.dart';
import '../../../../domain/models/series_metadata.dart';
import '../../providers/reading_progress_provider.dart';

/// Modern, stylish book card for the library
class BookCard extends ConsumerStatefulWidget {
  final BookGraph book;
  final bool isSelected;
  final bool isSeries;
  final SeriesMetadata? seriesMetadata;
  final int chapterCount;
  final bool isLoadingChapters;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.isSelected,
    required this.isSeries,
    this.seriesMetadata,
    required this.chapterCount,
    required this.isLoadingChapters,
    required this.onTap,
  });

  @override
  ConsumerState<BookCard> createState() => _BookCardState();
}

class _BookCardState extends ConsumerState<BookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isSeries
                  ? [
                      const Color(0xFF1A2A3A),
                      const Color(0xFF0F1A24),
                    ]
                  : [
                      const Color(0xFF1E1E2E),
                      const Color(0xFF151520),
                    ],
            ),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF4ECDC4)
                  : widget.isSeries
                      ? const Color(0xFF4ECDC4).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background pattern for series
                if (widget.isSeries) _buildSeriesBackground(),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildAuthor(),
                      const SizedBox(height: 16),
                      _buildFooter(),
                    ],
                  ),
                ),
                
                // Selection indicator
                if (widget.isSelected) _buildSelectionIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _SeriesPatternPainter(),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book icon
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: widget.isSeries
                  ? [
                      const Color(0xFF4ECDC4).withOpacity(0.3),
                      Colors.transparent,
                    ]
                  : [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: widget.isSeries
                ? ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.video_library_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.auto_stories_rounded,
                    size: 28,
                    color: Colors.white.withOpacity(0.7),
                  ),
          ),
        ),
        
        const SizedBox(width: 14),
        
        // Title and badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              _buildBadge(),
              const SizedBox(height: 6),
              // Title
              Text(
                widget.book.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    if (widget.isSeries) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_filled_rounded,
              size: 12,
              color: Colors.black,
            ),
            SizedBox(width: 4),
            Text(
              'SERIE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Text(
          'INTERAKTIV',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
  }

  Widget _buildAuthor() {
    return Row(
      children: [
        Icon(
          Icons.person_outline_rounded,
          size: 14,
          color: Colors.white.withOpacity(0.5),
        ),
        const SizedBox(width: 6),
        Text(
          widget.book.author,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    if (widget.isSeries && widget.seriesMetadata != null) {
      return _SeriesProgressBar(
        seriesId: widget.seriesMetadata!.seriesId,
        totalEpisodes: widget.seriesMetadata!.episodeCount,
      );
    } else {
      return Row(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 14,
            color: Colors.white.withOpacity(0.4),
          ),
          const SizedBox(width: 6),
          Text(
            widget.isLoadingChapters
                ? 'Lade...'
                : '${widget.chapterCount} Kapitel',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSelectionIndicator() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          size: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}

/// Custom painter for series background pattern
class _SeriesPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4ECDC4).withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw subtle diagonal lines
    const spacing = 30.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Progress bar widget for series
class _SeriesProgressBar extends ConsumerWidget {
  final String seriesId;
  final int totalEpisodes;

  const _SeriesProgressBar({
    required this.seriesId,
    required this.totalEpisodes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressService = ref.watch(readingProgressServiceProvider);
    
    return FutureBuilder<Set<int>>(
      future: progressService.getCompletedEpisodes(seriesId),
      builder: (context, snapshot) {
        final completedCount = snapshot.data?.length ?? 0;
        final progress = totalEpisodes > 0 ? completedCount / totalEpisodes : 0.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 14,
                  color: const Color(0xFF4ECDC4).withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  '$completedCount / $totalEpisodes Episoden',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4ECDC4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4ECDC4).withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

