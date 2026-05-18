import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

/// Maps a tenant identifier to its branded assets.
class _TenantConfig {
  final String logoPath;
  final Color? logoBorderColor;
  final Color? logoFillColor;

  const _TenantConfig(
      {required this.logoPath, this.logoBorderColor, this.logoFillColor});
}

class TenantHelper {
  static final LocalStorage _storage = LocalStorage('pocketHR');

  /// Tenant registry — add new tenants here as keys (lowercase).
  static const Map<String, _TenantConfig> _tenants = {
    'domex': _TenantConfig(
      logoPath: 'assets/images/domex-logo.png',
      // logoBorderColor: Color(0xFF8B1414), // dark red from Domex logo
      // logoFillColor: Color(0xFF8B1414), // same dark red as fill
    ),
    'mahajana': _TenantConfig(logoPath: 'assets/images/mahajana-logo.png'),
  };

  /// Fallback logo when no tenant match is found.
  static const String _defaultLogoPath = 'assets/images/logo.png';

  /// Returns the current tenant identifier from local storage, or null.
  static Future<String?> getCurrentTenant() async {
    await _storage.ready;
    final tenant = _storage.getItem('tenant')?.toString() ??
        _storage.getItem('company')?.toString();
    return (tenant != null && tenant.isNotEmpty)
        ? tenant.toLowerCase().trim()
        : null;
  }

  /// Returns the logo asset path for the given [tenant].
  /// Falls back to the default logo if the tenant is unknown.
  static String getLogoForTenant(String? tenant) {
    if (tenant == null || tenant.isEmpty) return _defaultLogoPath;
    return _tenants[tenant.toLowerCase().trim()]?.logoPath ?? _defaultLogoPath;
  }

  /// Returns the border color for the tenant logo, or null if none defined.
  static Color? getLogoBorderColor(String? tenant) {
    if (tenant == null || tenant.isEmpty) return null;
    return _tenants[tenant.toLowerCase().trim()]?.logoBorderColor;
  }

  /// Returns the fill/background color for the tenant logo, or null if none defined.
  static Color? getLogoFillColor(String? tenant) {
    if (tenant == null || tenant.isEmpty) return null;
    return _tenants[tenant.toLowerCase().trim()]?.logoFillColor;
  }

  /// Convenience method: reads tenant from storage and returns its logo path.
  static Future<String> loadLogoPath() async {
    final tenant = await getCurrentTenant();
    return getLogoForTenant(tenant);
  }

  /// Returns true if the tenant identifier is recognised.
  static bool isKnownTenant(String? tenant) {
    if (tenant == null || tenant.isEmpty) return false;
    return _tenants.containsKey(tenant.toLowerCase().trim());
  }
}
