import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/Screens/main/MainScreen.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/provider/locale_provider.dart';
import 'package:cn_pocket_hr/services/sso_service.dart';

class MobileLogin extends StatefulWidget {
  const MobileLogin({Key? key}) : super(key: key);

  @override
  State<MobileLogin> createState() => _MobileLoginState();
}

class _MobileLoginState extends State<MobileLogin> {
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
  bool _rememberMe = true;

  static const Color _accent = Color(0xFFF59E0B); // close to HRColors.orangeColor
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

  Widget langPicker() {
    final provider = Provider.of<LocaleProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _langButton('EN', () {
            provider.setLocale(const Locale('en'));
            storage.setItem('lang', 'en');
          }),
          _langButton('සිං', () {
            provider.setLocale(const Locale('si'));
            storage.setItem('lang', 'si');
          }),
          _langButton('தமிழ்', () {
            provider.setLocale(const Locale('ta'));
            storage.setItem('lang', 'ta');
          }),
        ],
      ),
    );
  }

  Widget _langButton(String label, VoidCallback onTap) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _surface,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
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

  Widget inputTenant() {
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

  Widget inputEmail() {
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

  Widget inputPassword() {
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

  void submit() async {
    setState(() {
      _validateCompany = company.text.isEmpty;
      _validateEmail = email.text.isEmpty;
      _validatePassword = password.text.isEmpty;
    });

    if (_validateCompany || _validateEmail || _validatePassword) return;

    setState(() {
      isLoading = true;
      buttonDisable = true;
    });

    storage.setItem('company', company.text);
    storage.setItem('email', email.text);
    storage.setItem('password', password.text);

    final login1 = await apiService.login(email.text, password.text);

    if (login1 == null) {
      apiService.showToast('Login failed, please Try again');
      setState(() {
        isLoading = false;
        buttonDisable = false;
      });
      return;
    }

    try {
      final result = (login1 is Map) ? (login1['result'] ?? login1) : null;
      final access = (result is Map ? (result['access_token'] ?? result['accessToken']) : null)?.toString();
      final refresh = (result is Map ? (result['refresh_token'] ?? result['refreshToken']) : null)?.toString();
      if (access != null && access.isNotEmpty) storage.setItem('access_token', access);
      if (refresh != null && refresh.isNotEmpty) storage.setItem('refresh_token', refresh);
    } catch (_) {}

    setState(() {
      isLoading = false;
      buttonDisable = false;
    });

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, HRMain.routeName);
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
    } catch (e, st) {
      debugPrint('[SSO][UI][ERROR] $e');
      debugPrint(st.toString());
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
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Top header image
            Positioned.fill(
              child: Container(color: Colors.white),
            ),
            Positioned(
              top: 2,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.42,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
                child: Image.asset(
                  'assets/images/login.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // slight dark overlay for readability
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.42,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                  color: Colors.black.withOpacity(0.10),
                ),
              ),
            ),

            // White bottom sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 22,
                  right: 22,
                  top: 18,
                  bottom: 18 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(34),
                    topRight: Radius.circular(34),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.black.withOpacity(0.88),
                          ),
                        ),
                        const SizedBox(height: 12),

                        inputTenant(),
                        _errorText(_validateCompany, AppLocalizations.of(context)!.tenantValidation),
                        inputEmail(),
                        _errorText(_validateEmail, AppLocalizations.of(context)!.emailValidation),
                        inputPassword(),
                        _errorText(_validatePassword, AppLocalizations.of(context)!.epfValidation),

                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Checkbox(
                                //   value: _rememberMe,
                                //   onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                //   activeColor: _accent,
                                //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                // ),
                                // const Text(
                                //   'Remember Me',
                                //   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54),
                                // ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => apiService.showToast('Coming soon'),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _accent),
                              ),
                            ),
                          ],
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
                            onPressed: buttonDisable ? null : submit,
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

                        const SizedBox(height: 12),
                        // Center(
                        //   child: Wrap(
                        //     spacing: 4,
                        //     children: [
                        //       Text("Don't have an Account?", style: TextStyle(color: Colors.black.withOpacity(0.45), fontWeight: FontWeight.w700, fontSize: 12)),
                        //       TextButton(
                        //          onPressed: () => apiService.showToast('Coming soon'),
                        //         child: const Text('Sign up', style: TextStyle(fontWeight: FontWeight.w900, color: Color.fromARGB(255, 243, 241, 238))),
                        //       )
                        //     ],
                        //   ),
                        // ),

                        langPicker(),
                         const SizedBox(height: 10),
                      ],
                      
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

