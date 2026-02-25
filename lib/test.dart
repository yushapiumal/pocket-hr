// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:provider/provider.dart';

// import 'package:cn_pocket_hr/l10n/app_localizations.dart';
// import 'package:cn_pocket_hr/Screens/main/MainScreen.dart';
// import 'package:cn_pocket_hr/api/apiService.dart';
// import 'package:cn_pocket_hr/provider/locale_provider.dart';
// import 'package:cn_pocket_hr/services/sso_service.dart';
// import 'package:cn_pocket_hr/services/device_details_service.dart';

// class MobileLogin extends StatefulWidget {
//   const MobileLogin({Key? key}) : super(key: key);

//   @override
//   State<MobileLogin> createState() => _MobileLoginState();
// }

// class _MobileLoginState extends State<MobileLogin> {
//    final email = TextEditingController();
//    final password = TextEditingController();
//    final company = TextEditingController();
//    final nicController = TextEditingController();
//    final List<TextEditingController> pinControllers = List.generate(4, (_) => TextEditingController());

//   // Focus nodes to support Next/Done keyboard actions
//   final FocusNode _companyFocus = FocusNode();
//   final FocusNode _emailFocus = FocusNode();
//   final FocusNode _passwordFocus = FocusNode();

//   bool _validateEmail = false;
//   bool _validatePassword = false;
//   bool _validateCompany = false;

//   bool isLoading = false;
//   bool buttonDisable = false;

//   final LocalStorage storage = LocalStorage('pocketHR');
//   final APIService apiService = APIService();
//   final SsoService _ssoService = SsoService();

//   bool _autoRedirecting = true;

//   bool _obscure = true;

//   static const Color _accent = Color(0xFFF59E0B); // close to HRColors.orangeColor
//   static const Color _surface = Color.fromARGB(255, 248, 250, 252);

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     _autoLoginIfPossible();
//   }

//   Future<void> _autoLoginIfPossible() async {
//     try {
//       await storage.ready;
//       final ok = await apiService.hasValidAccessToken();
//       if (!ok) {
//         // clear any stale tokens
//         try {
//           await storage.setItem('access_token', '');
//           await storage.setItem('refresh_token', '');
//         } catch (_) {}
//         if (mounted) setState(() => _autoRedirecting = false);
//         return;
//       }

//       // Token exists and not expired — try to fetch profile to ensure server accepts it
//       try {
//         await apiService.fetchMeProfileWithBearer();
//         if (!mounted) return;
//         Navigator.of(context).pushReplacementNamed(HRMain.routeName);
//         return;
//       } catch (e) {
//         // fetch failed — clear tokens and show login
//         try {
//           await storage.setItem('access_token', '');
//           await storage.setItem('refresh_token', '');
//         } catch (_) {}
//         if (mounted) setState(() => _autoRedirecting = false);
//         return;
//       }
//     } catch (_) {
//       if (mounted) setState(() => _autoRedirecting = false);
//     }
//   }

//   @override
//   void dispose() {
//     _companyFocus.dispose();
//     _emailFocus.dispose();
//     _passwordFocus.dispose();
//     email.dispose();
//     password.dispose();
//     nicController.dispose();
//     company.dispose();
//     for (final c in pinControllers) { c.dispose(); }
//     super.dispose();
//   }

//   Widget langPicker() {
//     final provider = Provider.of<LocaleProvider>(context);
//     return Padding(
//       padding: const EdgeInsets.only(top: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _langButton('EN', () {
//             provider.setLocale(const Locale('en'));
//             storage.setItem('lang', 'en');
//           }),
//           _langButton('සිං', () {
//             provider.setLocale(const Locale('si'));
//             storage.setItem('lang', 'si');
//           }),
//           _langButton('தமிழ்', () {
//             provider.setLocale(const Locale('ta'));
//             storage.setItem('lang', 'ta');
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _langButton(String label, VoidCallback onTap) {
//     return SizedBox(
//       height: 36,
//       child: ElevatedButton(
//         onPressed: onTap,
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           backgroundColor: _surface,
//           foregroundColor: Colors.black87,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         ),
//         child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
//       ),
//     );
//   }

//   InputDecoration _fieldDecoration({required String label, required String hint, required IconData icon, Widget? suffix}) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w800),
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w600),
//       prefixIcon: Icon(icon, color: Colors.black45, size: 20),
//       suffixIcon: suffix,
//       filled: true,
//       fillColor: _surface,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: _accent, width: 1.6),
//       ),
//     );
//   }

//   Widget inputTenant() {
//     // Formatter to force lowercase
//     final lowerCaseFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
//       final text = newValue.text.toLowerCase();
//       return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
//     });

//     return Padding(
//       padding: const EdgeInsets.only(top: 10),
//       child: TextFormField(
//         controller: company,
//         focusNode: _companyFocus,
//         textInputAction: TextInputAction.next,
//         onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
//         onChanged: (_) => setState(() => _validateCompany = false),
//         style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
//         cursorColor: _accent,
//         inputFormatters: [
//           lowerCaseFormatter,
//           // allow only simple letters (a-z), numbers and spaces
//           FilteringTextInputFormatter.allow(RegExp('[a-z0-9 ]')),
//         ],
//         decoration: _fieldDecoration(
//           label: AppLocalizations.of(context)!.companyName,
//           hint: 'tenant / company',
//           icon: Icons.apartment_rounded,
//         ),
//       ),
//     );
//   }

//   // Widget inputEmail() {
//   //   return Padding(
//   //     padding: const EdgeInsets.only(top: 10),
//   //     child: TextFormField(
//   //       controller: email,
//   //       focusNode: _emailFocus,
//   //       textInputAction: TextInputAction.next,
//   //       onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
//   //       onChanged: (_) => setState(() => _validateEmail = false),
//   //       style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
//   //       cursorColor: _accent,
//   //       decoration: _fieldDecoration(
//   //         label: AppLocalizations.of(context)!.emailAddressText,
//   //         hint: 'name@email.com',
//   //         icon: Icons.mail_outline_rounded,
//   //       ),
//   //       keyboardType: TextInputType.emailAddress,
//   //     ),
//   //   );
//   // }

//   // Widget inputPassword() {
//   //   return Padding(
//   //     padding: const EdgeInsets.only(top: 10),
//   //     child: TextFormField(
//   //       controller: password,
//   //       focusNode: _passwordFocus,
//   //       textInputAction: TextInputAction.done,
//   //       onFieldSubmitted: (_) => submit(),
//   //       obscureText: _obscure,
//   //       onChanged: (_) => setState(() => _validatePassword = false),
//   //       style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
//   //       cursorColor: _accent,
//   //       decoration: _fieldDecoration(
//   //         label: AppLocalizations.of(context)!.passwordText,
//   //         hint: '',
//   //         icon: Icons.lock_outline_rounded,
//   //         suffix: IconButton(
//   //           onPressed: () => setState(() => _obscure = !_obscure),
//   //           icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black45, size: 20),
//   //         ),
//   //       ),
//   //       keyboardType: TextInputType.visiblePassword,
//   //     ),
//   //   );
//   // }

//   Widget inputNic() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10),
//       child: TextFormField(
//         controller: nicController,
//         textInputAction: TextInputAction.next,
//         onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
//         onChanged: (_) => setState(() => _validateEmail = false),
//         style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
//         cursorColor: _accent,
//         decoration: _fieldDecoration(
//           label: 'NIC',
//           hint: 'Enter NIC / National ID',
//           icon: Icons.badge_outlined,
//         ),
//         keyboardType: TextInputType.text,
//       ),
//     );
//   }

//   Widget _errorText(bool show, String text) {
//     if (!show) return const SizedBox(height: 8);
//     return Padding(
//       padding: const EdgeInsets.only(top: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(text, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700)),
//       ),
//     );
//   }

//   void submit() async {
//     setState(() {
//       _validateCompany = company.text.isEmpty;
//       _validateEmail = email.text.isEmpty;
//       _validatePassword = password.text.isEmpty;
//     });

//     if (_validateCompany || _validateEmail || _validatePassword) return;

//     setState(() {
//       isLoading = true;
//       buttonDisable = true;
//     });

//     storage.setItem('company', company.text);
//     storage.setItem('email', email.text);
//     storage.setItem('password', password.text);

//     // collect device info and send with login
//     Map<String, String>? deviceInfo;
//     try {
//       final dsvc = DeviceDetailsService();
//       final details = await dsvc.collectAll();
//       final dev = details['device'] as Map<String, dynamic>? ?? {};
//       final deviceId = (dev['androidId'] ?? dev['identifierForVendor'] ?? dev['device'] ?? '').toString();
//       final model = (dev['model'] ?? '').toString();
//       final brand = (dev['brand'] ?? '').toString();
//       final platform = (dev['platform'] ?? '').toString();
//       final version = (dev['version'] ?? '').toString();
//       final ip = (details['ip'] ?? '').toString();
//       final batteryLevel = (details['battery'] is Map) ? (details['battery']['level']?.toString() ?? '') : '';
//       deviceInfo = {
//         'device_id': deviceId,
//         'device_model': model,
//         'device_brand': brand,
//         'device_platform': platform,
//         'device_version': version,
//         'device_ip': ip,
//         'battery_level': batteryLevel,
//       };
//     } catch (_) {
//       deviceInfo = null;
//     }

//     final login1 = await apiService.login(email.text, password.text, deviceInfo: deviceInfo);

//     if (login1 == null) {
//       apiService.showToast('Login failed, please Try again');
//       setState(() {
//         isLoading = false;
//         buttonDisable = false;
//       });
//       return;
//     }

//     try {
//       final result = (login1 is Map) ? (login1['result'] ?? login1) : null;
//       final access = (result is Map ? (result['access_token'] ?? result['accessToken']) : null)?.toString();
//       final refresh = (result is Map ? (result['refresh_token'] ?? result['refreshToken']) : null)?.toString();
//       if (access != null && access.isNotEmpty) storage.setItem('access_token', access);
//       if (refresh != null && refresh.isNotEmpty) storage.setItem('refresh_token', refresh);
//     } catch (_) {}

//     setState(() {
//       isLoading = false;
//       buttonDisable = false;
//     });

//     if (!mounted) return;
//     Navigator.pushReplacementNamed(context, HRMain.routeName);
//   }

//   Future<void> _ssoLogin() async {
//     setState(() {
//       isLoading = true;
//       buttonDisable = true;
//     });

//     try {
//       final tenantName = company.text.trim();
//       if (tenantName.isEmpty) {
//         setState(() {
//           _validateCompany = true;
//           isLoading = false;
//           buttonDisable = false;
//         });
//         return;
//       }

//       final result = await _ssoService.signIn(tenant: tenantName);
//       storage.setItem('access_token', result.accessToken);
//       storage.setItem('refresh_token', result.refreshToken);

//       setState(() {
//         isLoading = false;
//         buttonDisable = false;
//       });

//       if (!mounted) return;
//       Navigator.pushNamed(context, HRMain.routeName);
//     } catch (e, st) {
//       debugPrint('[SSO][UI][ERROR] $e');
//       debugPrint(st.toString());
//       apiService.showToast(e.toString());
//       setState(() {
//         isLoading = false;
//         buttonDisable = false;
//       });
//     }
//   }

//   void showPinBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: MediaQuery.of(context).viewInsets,
//           child: Container(
//             padding: const EdgeInsets.all(22),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Enter PIN',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.black.withOpacity(0.87),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Please enter the PIN sent to your registered email.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.black.withOpacity(0.65),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // PIN input fields
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _pinField(0),
//                     _pinField(1),
//                     _pinField(2),
//                     _pinField(3),
//                   ],
//                 ),

//                 const SizedBox(height: 24),

//                 if (isLoading)
//                   const CircularProgressIndicator(),
//                 if (!isLoading)
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         // Assemble PIN from controllers
//                         final pin = pinControllers.map((c) => c.text.trim()).join();
//                         // Set email to NIC and password to PIN, then submit
//                         email.text = nicController.text.trim();
//                         password.text = pin;
//                         Navigator.of(context).pop();
//                         submit();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _accent,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       child: Text(
//                         'Login',
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
//                       ),
//                     ),
//                   ),

//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _pinField(int index) {
//     return SizedBox(
//       width: 60,
//       height: 60,
//       child: TextFormField(
//         controller: pinControllers[index],
//         focusNode: null, // No focus node needed for individual fields
//         textInputAction: TextInputAction.next,
//         onChanged: (value) {
//           // Move to the next field automatically
//           if (value.length == 1 && index < 3) {
//             FocusScope.of(context).nextFocus();
//           }
//           // TODO: Handle PIN value
//         },
//         style: const TextStyle(
//           color: Colors.black87,
//           fontSize: 24,
//           fontWeight: FontWeight.w700,
//         ),
//         cursorColor: _accent,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: _accent, width: 1.6),
//           ),
//         ),
//         keyboardType: TextInputType.number,
//         maxLength: 1,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_autoRedirecting) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return WillPopScope(
//       onWillPop: () async => true,
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         body: Stack(
//           children: [
//             // Top header image
//             Positioned.fill(
//               child: Container(color: Colors.white),
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               height: MediaQuery.of(context).size.height * 0.52,
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(48),
//                   bottomRight: Radius.circular(48),
//                 ),
//                 child: Image.asset(
//                   'assets/images/login.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             // slight dark overlay for readability
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               height: MediaQuery.of(context).size.height * 0.82,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(48),
//                     bottomRight: Radius.circular(48),
//                   ),
//                   color: Colors.black.withOpacity(0.10),
//                 ),
//               ),
//             ),

//             // White bottom sheet
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.only(
//                   left: 22,
//                   right: 22,
//                   top: 18,
//                   bottom: 18 + MediaQuery.of(context).padding.bottom,
//                 ),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(34),
//                     topRight: Radius.circular(34),
//                   ),
//                 ),
//                 child: SafeArea(
//                   top: false,
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 6),
//                         Text(
//                           'Sign in',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.w900,
//                             color: Colors.black.withOpacity(0.88),
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         inputTenant(),
//                         _errorText(_validateCompany, AppLocalizations.of(context)!.tenantValidation),
//                         // NIC instead of email/password for first step
//                         inputNic(),
//                         _errorText(_validateEmail, 'Please enter NIC'),

//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 // Checkbox(
//                                 //   value: _rememberMe,
//                                 //   onChanged: (v) => setState(() => _rememberMe = v ?? true),
//                                 //   activeColor: _accent,
//                                 //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                 // ),
//                                 // const Text(
//                                 //   'Remember Me',
//                                 //   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54),
//                                 // ),
//                               ],
//                             ),
//                             TextButton(
//                               onPressed: () => apiService.showToast('Coming soon'),
//                               child: const Text(
//                                 'Forgot Password?',
//                                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _accent),
//                               ),
//                             ),
//                           ],
//                         ),

//                         if (isLoading)
//                           const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 10),
//                             child: Center(child: CircularProgressIndicator()),
//                           ),

//                         const SizedBox(height: 4),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 48,
//                           child: ElevatedButton(
//                             onPressed: buttonDisable ? null : () {
//                               // Validate company and NIC then open PIN sheet
//                               setState(() {
//                                 _validateCompany = company.text.isEmpty;
//                                 _validateEmail = nicController.text.isEmpty;
//                               });
//                               if (_validateCompany || _validateEmail) return;
//                               showPinBottomSheet();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _accent,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                               elevation: 0,
//                             ),
//                             child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
//                           ),
//                         ),

//                         const SizedBox(height: 18),

//                         SizedBox(
//                           width: double.infinity,
//                           height: 46,
//                           child: OutlinedButton(
//                             onPressed: buttonDisable ? null : _ssoLogin,
//                             style: OutlinedButton.styleFrom(
//                               side: const BorderSide(color: _accent),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                             ),
//                             child: const Text('SSO Login', style: TextStyle(fontWeight: FontWeight.w900, color: _accent)),
//                           ),
//                         ),

//                         const SizedBox(height: 12),
//                         // Center(
//                         //   child: Wrap(
//                         //     spacing: 4,
//                         //     children: [
//                         //       Text("Don't have an Account?", style: TextStyle(color: Colors.black.withOpacity(0.45), fontWeight: FontWeight.w700, fontSize: 12)),
//                         //       TextButton(
//                         //          onPressed: () => apiService.showToast('Coming soon'),
//                         //         child: const Text('Sign up', style: TextStyle(fontWeight: FontWeight.w900, color: Color.fromARGB(255, 243, 241, 238))),
//                         //       )
//                         //     ],
//                         //   ),
//                         // ),

//                         langPicker(),
//                          const SizedBox(height: 20),
//                       ],
                      
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

