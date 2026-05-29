import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/helpers/custom_blur_hash.dart';
import 'package:localstorage/localstorage.dart';

class TabletProfile extends StatefulWidget {
  @override
  _TabletProfileState createState() => _TabletProfileState();
}

class _TabletProfileState extends State<TabletProfile> {
  final APIService _apiService = APIService();
  final LocalStorage storage = LocalStorage('pocketHR');

  bool _loadingMe = false;
  bool _photoLoading = false;
  bool _savingImage = false;
  File? _selectedImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Profile data
  String _headerFullName = '';
  String _headerEpf = '';
  String _profilePhotoUrl = ''; // ← built from getProfilePhotoUrl()
  String _email = '';
  String _designation = '';
  String _department = '';
  String _phone = '';
  String _address = '';
  String _nic = '';
  String _dob = '';

  // Colors
  static Color get _primaryColor => HRColors.darkOrangeColor;
  static const Color _secondaryColor  = Color(0xFF6366F1);
  static const Color _backgroundColor = Colors.white;
  static const Color _cardColor       = Color.fromARGB(255, 248, 250, 252);
  static const Color _textPrimary     = Color(0xFF1E293B);
  static const Color _textSecondary   = Color(0xFF64748B);
  static const Color _textTertiary    = Color(0xFF94A3B8);
  static const Color _dividerColor    = Color(0xFFE2E8F0);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadProfileData();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadProfileData() async {
    if (_loadingMe) return;
    setState(() => _loadingMe = true);

    try {
      final meProfile = await _apiService.fetchMeProfileWithBearer();
      if (meProfile == null) return;

      final dataAny = meProfile['data'] ?? meProfile['result'] ?? meProfile['user'];
      if (dataAny is! Map) return;
      final data = Map<String, dynamic>.from(dataAny);

      // Helper: read custom field value
      String cf(String key) {
        final cfs = data['customfields'];
        if (cfs is List) {
          for (final item in cfs) {
            if (item is Map && item['input_name']?.toString() == key) {
              return item['input_value']?.toString() ?? '';
            }
          }
        }
        return '';
      }

      // Save uid to storage so getProfilePhotoUrl() can use it
      final uid = (data['_id'] ?? data['id'] ?? '').toString();
      if (uid.isNotEmpty) {
        await storage.ready;
        await storage.setItem('uid', uid);
      }

      setState(() {
        _email          = (data['email'] ?? '').toString();
        _headerFullName = '${cf('cf_first_name')} ${cf('cf_last_name')}'.trim();
        _headerEpf      = cf('cf_epf_no');
        _designation    = cf('cf_designation');
        _department     = cf('cf_department');
        _phone          = cf('cf_phone');
        _address        = cf('cf_address');
        _nic            = cf('cf_nic');
        _dob            = cf('cf_dob');
      });

      // ── Fetch profile photo separately after profile loads ─────────────────
      _fetchProfilePhoto();
    } catch (e) {
      debugPrint('[PROFILE] Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _loadingMe = false);
    }
  }

  /// Calls getProfilePhotoUrl() and updates _profilePhotoUrl
  Future<void> _fetchProfilePhoto() async {
    if (mounted) setState(() => _photoLoading = true);
    try {
      final url = await _apiService.getProfilePhotoUrl(size: '150-150');
      debugPrint('[PROFILE] photo URL => $url');
      if (url != null && url.isNotEmpty && mounted) {
        setState(() => _profilePhotoUrl = url);
      }
    } catch (e) {
      debugPrint('[PROFILE] photo fetch error: $e');
    } finally {
      if (mounted) setState(() => _photoLoading = false);
    }
  }

  /// Auth headers for CachedNetworkImageProvider
  Map<String, String> _authHeaders() {
    final oauthToken  = storage.getItem('token')?.toString() ?? '';
    final accessToken = storage.getItem('access_token')?.toString() ?? '';
    final tenant = storage.getItem('tenant')?.toString() ?? '';
    return {
      'Accept': 'image/*',
      if (oauthToken.isNotEmpty)  'Oauth-Token':   oauthToken,
      if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      if (tenant.isNotEmpty)      'Tenant':        tenant,
    };
  }

  Future<void> _pickImage() async {
    try {
      // final image = await ImagePicker().pickImage(
      //   source: ImageSource.gallery,
      //   imageQuality: 85,
      // );
      // if (image == null) return;

      setState(() => _savingImage = true);
      await Future.delayed(const Duration(seconds: 1)); // TODO: replace with real upload

      setState(() {
        // _selectedImage = File(image.path);
        _savingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: AutoSizeText(AppLocalizations.of(context)!.profilePictureUpdated),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      setState(() => _savingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: AutoSizeText(AppLocalizations.of(context)!.failedToUpdatePicture),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── UI Widgets ─────────────────────────────────────────────────────────────

  Widget _topCircleButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: HRColors.flavorIconBackgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _topHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _topCircleButton(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: SvgPicture.asset(
                'assets/svg/drawer_icon.svg',
                colorFilter: ColorFilter.mode(
                  HRColors.flavorIconColor, BlendMode.srcIn,
                ),
              ),
            ),
            AutoSizeText(
              AppLocalizations.of(context)!.myProfileTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            _topCircleButton(
              onTap: () => Navigator.pushNamed(context, HRNotifications.routeName),
              child: Image.asset(
                'assets/images/img/notification.png',
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar widget — shows spinner while loading, photo when ready, fallback on error
  Widget _buildAvatar() {
    const double size = 120;

    Widget imageChild;

    if (_selectedImage != null) {
      // Locally picked image (before upload)
      imageChild = Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    } else if (_savingImage) {
      imageChild = Center(
        child: CupertinoActivityIndicator(
          color: HRColors.darkOrangeColor,
          radius: 16,
        ),
      );
    } else if (_photoLoading) {
      // Still fetching photo URL
      imageChild = Center(
        child: CupertinoActivityIndicator(
          color: HRColors.darkOrangeColor,
          radius: 14,
        ),
      );
    } else if (_profilePhotoUrl.isNotEmpty) {
      // ✅ Photo URL resolved — load with auth headers
      imageChild = OctoImage(
        image: CachedNetworkImageProvider(
          _profilePhotoUrl,
          headers: _authHeaders(),
        ),
        placeholderBuilder: OctoBlurHashFix.placeHolder(
          'LRHe%pIA.m_2KjxawKNGIWkWD*M{',
        ),
        errorBuilder: (context, error, stacktrace) => _avatarFallback(),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else {
      // No photo found
      imageChild = _avatarFallback();
    }

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _dividerColor, width: 4),
          ),
          child: ClipOval(child: imageChild),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _savingImage ? null : _pickImage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _savingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CupertinoActivityIndicator(radius: 8),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: _cardColor,
      child: Icon(Icons.person, size: 60, color: _textTertiary),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────────
          _buildAvatar(),
          const SizedBox(height: 16),

          // ── Full name ────────────────────────────────────────────────────────
          if (_headerFullName.isNotEmpty)
            AutoSizeText(
              _headerFullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4),

          // ── EPF ──────────────────────────────────────────────────────────────
          AutoSizeText(
            '${AppLocalizations.of(context)!.epfLabel}${_headerEpf.isNotEmpty ? _headerEpf : "N/A"}',
            style: const TextStyle(fontSize: 14, color: _textSecondary),
            textAlign: TextAlign.center,
          ),

          // ── Designation & Department badges ──────────────────────────────────
          if (_designation.isNotEmpty || _department.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (_designation.isNotEmpty)
                  _buildBadge(_designation, _primaryColor),
                if (_department.isNotEmpty)
                  _buildBadge(_department, _secondaryColor),
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: AutoSizeText(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color iconColor = _textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, size: 20, color: iconColor)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  title,
                  style: const TextStyle(fontSize: 13, color: _textTertiary),
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  value.isNotEmpty
                      ? value
                      : AppLocalizations.of(context)!.notAdded,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: AutoSizeText(
              AppLocalizations.of(context)!.personalInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          _buildInfoItem(
            icon: Icons.email_rounded,
            title: AppLocalizations.of(context)!.emailAddressText,
            value: _email,
            iconColor: _primaryColor,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.phone_rounded,
            title: AppLocalizations.of(context)!.phoneLabel,
            value: _phone,
            iconColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.location_on_rounded,
            title: AppLocalizations.of(context)!.addressLabel,
            value: _address,
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.badge_rounded,
            title: AppLocalizations.of(context)!.nicLabel,
            value: _nic,
            iconColor: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.cake_rounded,
            title: AppLocalizations.of(context)!.dateOfBirth,
            value: _dob,
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawerScrimColor: Colors.black.withOpacity(0.3),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DesignConfig.drawerContent(_scaffoldKey, context),
      ),
      backgroundColor: _backgroundColor,
      body: _loadingMe
          ? Center(
              child: CupertinoActivityIndicator(
                color: HRColors.darkOrangeColor,
                radius: 16.0,
              ),
            )
          : RefreshIndicator(
              color: _primaryColor,
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _topHeader(),
                    const SizedBox(height: 10),
                    _buildProfileCard(),
                    _buildPersonalInfo(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}