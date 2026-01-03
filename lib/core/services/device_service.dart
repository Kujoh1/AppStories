import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for device identification and admin access control
/// Uses a simple secret-based approach for admin access
class DeviceService {
  static const String _adminEnabledKey = 'admin_mode_enabled';
  static const String _adminSecret = 'ADMIN_2024_SECRET';
  
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _isAdminEnabled = false;

  /// Initialize the service
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isAdminEnabled = _prefs!.getBool(_adminEnabledKey) ?? false;
      
      // For development: Always enable admin mode
      // Set to false for production
      const bool devModeAdminAccess = true;
      if (devModeAdminAccess) {
        _isAdminEnabled = true;
      }
      
      print('=== ADMIN STATUS ===');
      print('Admin Mode: $_isAdminEnabled');
      print('====================');
    } catch (e) {
      print('Error initializing DeviceService: $e');
      _isAdminEnabled = false;
    }
    
    _isInitialized = true;
  }

  /// Check if admin mode is enabled
  bool isAdminDevice() {
    return _isAdminEnabled;
  }
  
  /// Enable admin mode with secret
  Future<bool> enableAdminMode(String secret) async {
    if (secret == _adminSecret) {
      _isAdminEnabled = true;
      await _prefs?.setBool(_adminEnabledKey, true);
      return true;
    }
    return false;
  }
  
  /// Disable admin mode
  Future<void> disableAdminMode() async {
    _isAdminEnabled = false;
    await _prefs?.setBool(_adminEnabledKey, false);
  }
  
  /// Check if admin access should be shown
  bool shouldShowAdminAccess() {
    return _isAdminEnabled;
  }
}

/// Provider for DeviceService
final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

/// Provider for admin access check
final isAdminDeviceProvider = FutureProvider<bool>((ref) async {
  final deviceService = ref.watch(deviceServiceProvider);
  await deviceService.init();
  return deviceService.shouldShowAdminAccess();
});
