import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/Screens/login/LoginScreen.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/customBlurHash.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MobileProfile extends StatefulWidget {
  @override
  _MobileProfileState createState() => _MobileProfileState();
}

class _MobileProfileState extends State<MobileProfile> {
  final APIService _apiService = APIService();
  bool _loadingMe = false;
  bool _savingImage = false;
  File? _selectedImage;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Profile data
  String _headerFullName = '';
  String _headerEpf = '';
  String _profileAvatar = '';
  String _email = '';
  String _designation = '';
  String _department = '';
  String _phone = '';
  String _address = '';
  String _nic = '';
  String _dob = '';

  // Custom colors
  static const Color _primaryColor = HRColors.darkOrangeColor;
  static const Color _secondaryColor = Color(0xFF6366F1);
  static const Color _backgroundColor = Colors.white;
  static const Color _cardColor = Color.fromARGB(255, 248, 250, 252);
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _textTertiary = Color(0xFF94A3B8);
  static const Color _dividerColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (_loadingMe) return;
    setState(() => _loadingMe = true);

    try {
      final meProfile = await _apiService.fetchMeProfileWithBearer();
      if (meProfile == null) return;

      final dataAny = meProfile['data'] ?? meProfile['result'] ?? meProfile['user'];
      if (dataAny is! Map) return;
      final data = Map<String, dynamic>.from(dataAny);

      // Helper function to get custom field value
      String _getCustomField(Map<String, dynamic> data, String key) {
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

      setState(() {
        _email = (data['email'] ?? '').toString();
        final firstName = _getCustomField(data, 'cf_first_name');
        final lastName = _getCustomField(data, 'cf_last_name');
        _headerFullName = '$firstName $lastName'.trim();
        _headerEpf = _getCustomField(data, 'cf_epf_no');
        _designation = _getCustomField(data, 'cf_designation');
        _department = _getCustomField(data, 'cf_department');
        _phone = _getCustomField(data, 'cf_phone');
        _address = _getCustomField(data, 'cf_address');
        _nic = _getCustomField(data, 'cf_nic');
        _dob = _getCustomField(data, 'cf_dob');

        // Set profile avatar if available
        if (data['avatar'] is String && data['avatar'].toString().isNotEmpty) {
          _profileAvatar = data['avatar'];
        }
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      setState(() => _loadingMe = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() => _savingImage = true);
      
      // Here you would typically upload the image to your server
      await Future.delayed(Duration(seconds: 1)); // Simulate upload
      
      setState(() {
        _selectedImage = File(image.path);
        _savingImage = false;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile picture updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _savingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update picture'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear stored tokens and user identifiers (local + secure)
              try {
                final ls = LocalStorage('pocketHR');
                await ls.ready;
                await ls.setItem('access_token', '');
                await ls.setItem('token', '');
                await ls.setItem('refresh_token', '');
                await ls.setItem('uid', '');
                await ls.setItem('human_user_id', '');
                await ls.setItem('login', false);
              } catch (_) {}

              try {
                final secure = const FlutterSecureStorage();
                await secure.delete(key: 'access_token');
                await secure.delete(key: 'refresh_token');
                await secure.delete(key: 'token');
              } catch (_) {}

              // Navigate to login and remove all previous routes
              Navigator.pushNamedAndRemoveUntil(context, HRLogin.routeName, (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // Attendance/Leave-style circle icon button
  Widget _topCircleButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
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
                            "assets/svg/drawer_icon.svg",
                            colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                          ),
            ),
            const Text('My Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
            _topCircleButton(
              onTap: () => Navigator.pushNamed(context, HRNotifications.routeName),
              child: Image.asset(
                'assets/images/img/notification.png',
                errorBuilder: (_, __, ___) => const Icon(Icons.notifications_none_rounded, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final avatarUrl = _profileAvatar.isNotEmpty && _profileAvatar.contains('http')
        ? _profileAvatar
        : "https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png";

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _dividerColor, width: 4),
                ),
                child: ClipOval(
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                      : _savingImage
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(_primaryColor),
                              ),
                            )
                          : OctoImage(
                              image: CachedNetworkImageProvider(avatarUrl),
                              placeholderBuilder: OctoBlurHashFix.placeHolder(
                                'LRHe%pIA.m_2KjxawKNGIWkWD*M{',
                              ),
                              errorBuilder: (context, error, stacktrace) => 
                                Container(
                                  color: _backgroundColor,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: _textTertiary,
                                  ),
                                ),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                ),
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
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _savingImage
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Name and EPF
          Text(
            _loadingMe ? 'Loading...' : _headerFullName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'EPF : #${_headerEpf.isNotEmpty ? _headerEpf : "N/A"}',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          // Designation and Department
          if (_designation.isNotEmpty || _department.isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_designation.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _designation,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                if (_designation.isNotEmpty && _department.isNotEmpty)
                  SizedBox(width: 8),
                if (_department.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _department,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _secondaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: 20),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout_rounded, size: 20),
              label: Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red, backgroundColor: Colors.red.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withOpacity(0.2)),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            child: Center(
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textTertiary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not added',
                  style: TextStyle(
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
      margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          Column(
            children: [
              _buildInfoItem(
                icon: Icons.email_rounded,
                title: 'Email',
                value: _email,
                iconColor: _primaryColor,
              ),
              SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.phone_rounded,
                title: 'Phone',
                value: _phone,
                iconColor: Colors.green,
              ),
              SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.location_on_rounded,
                title: 'Address',
                value: _address,
                iconColor: Colors.blue,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.badge_rounded,
                      title: 'NIC',
                      value: _nic,
                      iconColor: Colors.purple,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.cake_rounded,
                      title: 'Date of Birth',
                      value: _dob,
                      iconColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: TextStyle(color: _textSecondary),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: _primaryColor,
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _topHeader(),
                    const SizedBox(height: 10),
                    _buildProfileCard(),
                    _buildPersonalInfo(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}