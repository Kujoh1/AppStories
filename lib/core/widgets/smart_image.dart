import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A smart image widget that tries different extensions (.png, .jpg, .jpeg) if the original path fails
class SmartImage extends StatefulWidget {
  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;

  const SmartImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.fallback,
  });

  @override
  State<SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends State<SmartImage> {
  String? _resolvedPath;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _resolvePath();
  }

  @override
  void didUpdateWidget(SmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _resolvePath();
    }
  }

  Future<void> _resolvePath() async {
    final originalPath = widget.assetPath;
    
    // 1. Try original path
    if (await _assetExists(originalPath)) {
      if (mounted) setState(() => _resolvedPath = originalPath);
      return;
    }

    // 2. If it fails, try swapping extension
    final dotIndex = originalPath.lastIndexOf('.');
    if (dotIndex != -1) {
      final basePath = originalPath.substring(0, dotIndex);
      final currentExt = originalPath.substring(dotIndex).toLowerCase();
      
      final alternatives = currentExt == '.png' 
          ? ['.jpg', '.jpeg'] 
          : ['.png'];

      for (final ext in alternatives) {
        final altPath = '$basePath$ext';
        if (await _assetExists(altPath)) {
          if (mounted) setState(() => _resolvedPath = altPath);
          return;
        }
      }
    }

    // 3. Complete failure
    if (mounted) {
      setState(() {
        _error = true;
        _resolvedPath = null;
      });
    }
  }

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return widget.fallback ?? const SizedBox.shrink();
    if (_resolvedPath == null) return const SizedBox.shrink(); // Loading state

    return Image.asset(
      _resolvedPath!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) => 
          widget.fallback ?? const SizedBox.shrink(),
    );
  }
}
