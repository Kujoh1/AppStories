import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive debug overlay showing viewport, scroll, FPS, and route info
/// Toggle with Alt+D or via button
class DebugOverlay extends StatefulWidget {
  final Widget child;

  const DebugOverlay({
    super.key,
    required this.child,
  });

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay>
    with WidgetsBindingObserver {
  bool _isVisible = false;
  Timer? _updateTimer;
  Timer? _fpsTimer;

  // Metrics
  double _viewportWidth = 0;
  double _viewportHeight = 0;
  double _screenWidth = 0;
  double _screenHeight = 0;
  double _devicePixelRatio = 1.0;
  String _orientation = 'portrait';
  double _fps = 60.0;
  String _currentRoute = '/';
  
  // FPS calculation
  final List<double> _fpsHistory = [];
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();

  static const String _storageKey = 'debug_overlay_visible';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreference();
    _startUpdates();
    _setupFpsMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateTimer?.cancel();
    _fpsTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final visible = prefs.getBool(_storageKey) ?? false;
    if (mounted) {
      setState(() {
        _isVisible = visible;
      });
    }
  }

  Future<void> _savePreference(bool visible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, visible);
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
    _savePreference(_isVisible);
  }

  void _startUpdates() {
    // Reduce update frequency to 250ms for better performance
    _updateTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      _updateMetrics();
    });
  }

  void _setupFpsMonitoring() {
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!mounted) return;

    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFpsUpdate);

    if (elapsed.inMilliseconds >= 1000) {
      final fps = (_frameCount / elapsed.inSeconds).clamp(0.0, 120.0);
      
      setState(() {
        _fpsHistory.add(fps);
        if (_fpsHistory.length > 10) {
          _fpsHistory.removeAt(0);
        }
        _fps = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
      });

      _frameCount = 0;
      _lastFpsUpdate = now;
    }

    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _updateMetrics() {
    if (!mounted) return;

    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    setState(() {
      _viewportWidth = size.width;
      _viewportHeight = size.height;
      _screenWidth = size.width * mediaQuery.devicePixelRatio;
      _screenHeight = size.height * mediaQuery.devicePixelRatio;
      _devicePixelRatio = mediaQuery.devicePixelRatio;
      _orientation = size.width > size.height ? 'landscape' : 'portrait';
      
      // Get current route
      final route = ModalRoute.of(context);
      if (route?.settings.name != null) {
        _currentRoute = route!.settings.name!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: RawKeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            // Check for Alt+D (Command+D on Mac)
            final isAltPressed = event.isAltPressed || event.isMetaPressed;
            if (event.logicalKey == LogicalKeyboardKey.keyD && isAltPressed) {
              _toggleVisibility();
            }
          }
        },
        child: Stack(
          children: [
            widget.child,
            if (_isVisible) _buildDebugPanel(),
            _buildToggleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: GestureDetector(
        onTap: _toggleVisibility,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
            border: Border.all(
              color: _isVisible ? Colors.greenAccent : Colors.white24,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _isVisible ? Icons.bug_report : Icons.bug_report_outlined,
            color: _isVisible ? Colors.greenAccent : Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Positioned(
      top: 50,
      left: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.greenAccent.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildSection('Viewport', [
              'Width: ${_viewportWidth.toStringAsFixed(0)}px',
              'Height: ${_viewportHeight.toStringAsFixed(0)}px',
              'Orientation: $_orientation',
            ]),
            const Divider(color: Colors.white24, height: 16),
            _buildSection('Screen', [
              'Physical: ${_screenWidth.toStringAsFixed(0)}×${_screenHeight.toStringAsFixed(0)}px',
              'DPR: ${_devicePixelRatio.toStringAsFixed(2)}x',
            ]),
            const Divider(color: Colors.white24, height: 16),
            _buildSection('Performance', [
              'FPS: ${_fps.toStringAsFixed(1)}',
              _buildFpsBar(),
            ]),
            const Divider(color: Colors.white24, height: 16),
            _buildSection('Route', [
              'Path: $_currentRoute',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.developer_mode,
          color: Colors.greenAccent,
          size: 16,
        ),
        const SizedBox(width: 8),
        const Text(
          'Debug Info',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleVisibility,
          child: const Icon(
            Icons.close,
            color: Colors.white70,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) {
          if (item is Widget) return item;
          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              item.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFpsBar() {
    final fpsPercentage = (_fps / 60.0).clamp(0.0, 1.0);
    final color = fpsPercentage > 0.9
        ? Colors.greenAccent
        : fpsPercentage > 0.7
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fpsPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

