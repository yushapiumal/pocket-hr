import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/Screens/main/MainScreen.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/services/sso_service.dart';
import 'package:cn_pocket_hr/services/device_details_service.dart';
import 'package:cn_pocket_hr/Screens/login/otp_page.dart';

class TabletLogin extends StatefulWidget {
  const TabletLogin({Key? key}) : super(key: key);

  @override
  State<TabletLogin> createState() => _TabletLoginState();
}

class _TabletLoginState extends State<TabletLogin> {
  final email = TextEditingController();
  final password = TextEditingController();
  final company = TextEditingController();

  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validateCompany = false;

  bool isLoading = false;
  bool buttonDisable = false;

  final LocalStorage storage = LocalStorage('pocketHR');
  final APIService apiService = APIService();
  final SsoService _ssoService = SsoService();

  bool _autoRedirecting = true;
  bool _obscure = true;

  static const Color _accent = Color(0xFFF59E0B);
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _autoLoginIfPossible();
  }

  Future<void> _autoLoginIfPossible() async {
    try {
      await storage.ready;
      final token = storage.getItem('access_token')?.toString();
      if (token != null && token.trim().isNotEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(HRMain.routeName);
        return;
      }
    } catch (_) {
      // ignore
    }
    if (mounted) setState(() => _autoRedirecting = false);
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    company.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({required String label, required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w800),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.6),
      ),
    );
  }

  Widget _errorText(bool show, String text) {
    if (!show) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _inputTenant() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        controller: company,
        onChanged: (_) => setState(() => _validateCompany = false),
        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
        cursorColor: _accent,
        decoration: _fieldDecoration(
          label: AppLocalizations.of(context)!.companyName,
          hint: 'Tenant / Company',
          icon: Icons.apartment_rounded,
        ),
      ),
    );
  }

  Widget _inputEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        controller: email,
        onChanged: (_) => setState(() => _validateEmail = false),
        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
        cursorColor: _accent,
        decoration: _fieldDecoration(
          label: AppLocalizations.of(context)!.emailAddressText,
          hint: 'name@email.com',
          icon: Icons.mail_outline_rounded,
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _inputPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        controller: password,
        obscureText: _obscure,
        onChanged: (_) => setState(() => _validatePassword = false),
        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
        cursorColor: _accent,
        decoration: _fieldDecoration(
          label: AppLocalizations.of(context)!.passwordText,
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black45, size: 20),
          ),
        ),
        keyboardType: TextInputType.visiblePassword,
      ),
    );
  }

  void _submit() async {
    setState(() {
      _validateCompany = company.text.isEmpty;
      _validateEmail = email.text.isEmpty;
      _validatePassword = password.text.isEmpty;
    });

    if (_validateCompany || _validateEmail || _validatePassword) return;

    setState(() { isLoading = true; buttonDisable = true; });
    try {
      storage.setItem('company', company.text);
      storage.setItem('email', email.text);
      storage.setItem('password', password.text);

      // collect device info
      Map<String, String> deviceInfo = {};
      try {
        final dsvc = DeviceDetailsService();
        final details = await dsvc.collectAll();
        final dev = details['device'] as Map<String, dynamic>? ?? {};
        deviceInfo['model_number'] = (dev['model'] ?? '').toString();
        deviceInfo['device_id'] = (dev['androidId'] ?? dev['identifierForVendor'] ?? '').toString();
        deviceInfo['ip_address'] = (details['ip'] ?? '').toString();
      } catch (_) {}

      final tenantName = company.text.trim();
      final nic = email.text.trim();

      // request OTP
      final req = await apiService.sendAuthPinMobile(tenant: tenantName, nic: nic, deviceInfo: deviceInfo);
      if (req['status'] == false) {
        apiService.showToast(req['message'] ?? 'Failed to request OTP');
        return;
      }

      // open OTP page
      final otp = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const OtpPage()));
      if (otp == null || otp.isEmpty) return;

      // verify
      final verify = await apiService.verifyAuthPinMobile(tenant: tenantName, nic: nic, pin: otp, deviceInfo: deviceInfo);
      if (verify['status'] == false) {
        apiService.showToast(verify['message'] ?? 'OTP verification failed');
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HRMain.routeName);
    } catch (e, st) {
      debugPrint('[TABLET LOGIN] ERROR: $e');
      debugPrint(st.toString());
      apiService.showToast('Login failed');
    } finally {
      if (mounted) setState(() { isLoading = false; buttonDisable = false; });
    }
  }

  Future<void> _ssoLogin() async {
    setState(() {
      isLoading = true;
      buttonDisable = true;
    });

    try {
      final tenantName = company.text.trim();
      if (tenantName.isEmpty) {
        setState(() {
          _validateCompany = true;
          isLoading = false;
          buttonDisable = false;
        });
        return;
      }

      final result = await _ssoService.signIn(tenant: tenantName);
      storage.setItem('access_token', result.accessToken);
      storage.setItem('refresh_token', result.refreshToken);

      setState(() {
        isLoading = false;
        buttonDisable = false;
      });

      if (!mounted) return;
      Navigator.pushNamed(context, HRMain.routeName);
    } catch (e) {
      apiService.showToast(e.toString());
      setState(() {
        isLoading = false;
        buttonDisable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_autoRedirecting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Row(
          children: [
            // Left image panel
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/login.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.12)),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(26),
                        child: Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right form panel
            Expanded(
              flex: 5,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.black.withOpacity(0.88),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _inputTenant(),
                          _errorText(_validateCompany, AppLocalizations.of(context)!.tenantValidation),
                          _inputEmail(),
                          _errorText(_validateEmail, AppLocalizations.of(context)!.emailValidation),
                          _inputPassword(),
                          _errorText(_validatePassword, AppLocalizations.of(context)!.epfValidation),

                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => apiService.showToast('Coming soon'),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _accent),
                              ),
                            ),
                          ),

                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(child: CircularProgressIndicator()),
                            ),

                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: buttonDisable ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.loginText,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: buttonDisable ? null : _ssoLogin,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _accent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('SSO Login', style: TextStyle(fontWeight: FontWeight.w900, color: _accent)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
