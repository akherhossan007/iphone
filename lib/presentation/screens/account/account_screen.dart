import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/launcher_helper.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/language_provider.dart';
import '../../../data/models/user_model.dart';
import '../subpages/account_settings_screen.dart';
import '../subpages/address_book_screen.dart';
import '../subpages/faq_screen.dart';
import '../subpages/help_support_screen.dart';
import '../subpages/notifications_screen.dart';
import '../subpages/order_tracking_screen.dart';
import '../subpages/skin_analyzer_screen.dart';
import '../subpages/privacy_policy_screen.dart';
import '../subpages/terms_conditions_screen.dart';
import '../subpages/vouchers_wallet_screen.dart';
import '../subpages/wishlist_screen.dart';
import '../catalog/catalog_screen.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const AccountScreen({super.key, this.onBackToHome});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

enum AuthMode { login, register, forgot }

class _AccountScreenState extends State<AccountScreen> {
  AuthMode _authMode = AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;
  bool _agreeTerms = true;
  bool _isForgotLoading = false;

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _forgotEmailCtrl = TextEditingController();
  String _selectedGender = '';

  // Standard Shopee / Lazada inspired theme tokens
  static const Color _primaryPink = Color(0xFFFF2A6D);
  static const Color _primaryGradientEnd = Color(0xFFFF5286);
  static const Color _surfaceBg = Color(0xFFF6F8FB);
  static const Color _borderSubtle = Color(0xFFE2E8F0);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSubtle = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<AuthProvider>().fetchDashboard();
      }
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _forgotEmailCtrl.dispose();
    super.dispose();
  }

  void _openTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
    );
  }

  void _openPrivacy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  void _handleLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or phone number.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(username, password);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Invalid credentials. Please verify and try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleRegister() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final fullName = '$firstName $lastName'.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your first name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your last name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number (01XXXXXXXXX).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service and Privacy Policy.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final isEn = context.read<LanguageProvider>().isEnglish;
    final auth = context.read<AuthProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isEn
                    ? 'Sending verification code to $email...'
                    : '$email এ ভেরিফিকেশন কোড পাঠানো হচ্ছে...',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );

    final res = await auth.sendEmailOtp(email, name: fullName);
    if (!mounted) return;

    if (res['success'] == true) {
      _showEmailOtpVerificationSheet(
        email: email,
        fullName: fullName,
        phone: phone,
        password: password,
        fallbackOtp: res['otp']?.toString(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? (isEn ? 'Failed to send OTP.' : 'ভেরিফিকেশন কোড পাঠাতে সমস্যা হয়েছে।')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleForgotPassword() async {
    final email = _forgotEmailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your registered email address.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isForgotLoading = true);
    final res = await context.read<AuthProvider>().forgotPassword(email);
    setState(() => _isForgotLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Password reset instructions have been dispatched to your email.'),
          backgroundColor: res['success'] == true ? AppColors.success : AppColors.error,
        ),
      );
      if (res['success'] == true) {
        setState(() => _authMode = AuthMode.login);
      }
    }
  }

  void _showEmailOtpVerificationSheet({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    String? fallbackOtp,
  }) {
    final isEn = context.read<LanguageProvider>().isEnglish;
    final TextEditingController otpCtrl = TextEditingController(text: fallbackOtp ?? '');
    bool isLoading = false;
    String? errorText;
    int resendCountdown = 60;
    Timer? resendTimer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          void startTimer() {
            resendCountdown = 60;
            resendTimer?.cancel();
            resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (resendCountdown > 0) {
                setModalState(() => resendCountdown--);
              } else {
                t.cancel();
              }
            });
          }

          if (resendTimer == null) {
            startTimer();
          }

          Future<void> submitOtp() async {
            final otp = otpCtrl.text.trim();
            if (otp.length < 4) {
              setModalState(() => errorText = isEn ? 'Please enter the 4-digit code.' : 'দয়া করে ৪-ডিজিটের কোড লিখুন।');
              return;
            }

            setModalState(() {
              isLoading = true;
              errorText = null;
            });

            final auth = context.read<AuthProvider>();
            final ok = await auth.verifyEmailOtpAndRegister(
              email: email,
              otp: otp,
              password: password,
              name: fullName,
              phone: phone,
            );

            if (!ctx.mounted || !mounted) return;

            if (ok) {
              resendTimer?.cancel();
              Navigator.of(ctx).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isEn
                                ? 'Account created and verified successfully! Welcome to GlowBay.'
                                : 'অ্যাকাউন্ট সফলভাবে ভেরিফাই ও তৈরি হয়েছে! GlowBay তে স্বাগতম।',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            } else {
              setModalState(() {
                isLoading = false;
                errorText = auth.errorMessage ?? (isEn ? 'Invalid or expired OTP code.' : 'ভুল অথবা মেয়াদোত্তীর্ণ ওটিপি কোড।');
              });
            }
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 14,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header Badge
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryPink, Color(0xFFFF7A00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryPink.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title & Subtitle
                  Text(
                    isEn ? 'Verify Your Email' : 'ইমেইল ভেরিফিকেশন',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _textSubtle, height: 1.4),
                      children: [
                        TextSpan(
                          text: isEn
                              ? 'We have sent a 4-digit verification code to\n'
                              : 'আমরা একটি ৪-ডিজিটের ভেরিফিকেশন কোড পাঠিয়েছি\n',
                        ),
                        TextSpan(
                          text: email,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: _primaryPink),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 4-Digit OTP Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: errorText != null ? AppColors.error : _borderSubtle,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: otpCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 4,
                      autofocus: true,
                      style: GoogleFonts.spaceMono(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 24,
                        color: _textDark,
                      ),
                      decoration: const InputDecoration(
                        hintText: '••••',
                        hintStyle: TextStyle(
                          letterSpacing: 24,
                          fontSize: 28,
                          color: Color(0xFFCBD5E1),
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        if (errorText != null) {
                          setModalState(() => errorText = null);
                        }
                        if (val.trim().length == 4) {
                          submitOtp();
                        }
                      },
                    ),
                  ),

                  // Error Text
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 15),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            errorText!,
                            style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submitOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              isEn ? 'Verify & Create Account →' : 'ভেরিফাই ও অ্যাকাউন্ট তৈরি করুন →',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Resend Timer Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEn ? "Didn't receive code? " : 'কোড পাননি? ',
                        style: const TextStyle(fontSize: 12.5, color: _textSubtle),
                      ),
                      if (resendCountdown > 0)
                        Text(
                          isEn ? 'Resend in ${resendCountdown}s' : '${resendCountdown}s পরে আবার পাঠান',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () async {
                            setModalState(() {
                              errorText = null;
                            });
                            final auth = context.read<AuthProvider>();
                            final res = await auth.sendEmailOtp(email, name: fullName);
                            if (ctx.mounted && mounted) {
                              if (res['success'] == true) {
                                startTimer();
                                if (res['otp'] != null) {
                                  otpCtrl.text = res['otp'].toString();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEn ? 'New code sent to $email.' : '$email এ নতুন কোড পাঠানো হয়েছে।'),
                                    backgroundColor: AppColors.success,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                setModalState(() {
                                  errorText = res['message'] ?? (isEn ? 'Failed to resend code.' : 'পুনরায় কোড পাঠাতে ব্যর্থ।');
                                });
                              }
                            }
                          },
                          child: Text(
                            isEn ? 'Resend Code' : 'পুনরায় কোড পাঠান',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: _primaryPink,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSocialAuth(String provider) async {
    if (provider == 'google') {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: '791811563157-lo60pbggt7s00gjftn5ebbrb5tumerr7.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        );
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        if (account == null) {
          // User canceled the Google picker, gracefully exit
          return;
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                SizedBox(width: 12),
                Text('গুগল অ্যাকাউন্ট ভেরিফাই করা হচ্ছে...'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF0F172A),
          ),
        );

        final auth = context.read<AuthProvider>();
        final ok = await auth.socialLogin(
          email: account.email,
          name: account.displayName ?? '',
          avatar: account.photoUrl ?? '',
          provider: 'google',
        );

        if (ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('স্বাগতম, ${account.displayName ?? account.email}! গুগল দিয়ে সফলভাবে লগইন হয়েছে।'),
              backgroundColor: AppColors.authenticGreen,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(auth.errorMessage ?? 'গুগল দিয়ে লগইন করা সম্ভব হয়নি।'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        debugPrint('Google Sign-In error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('গুগল দিয়ে লগইন সম্পন্ন করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      return;
    }

    if (provider == 'facebook') {
      final fbAuthUrl = Uri.parse(
        'https://www.facebook.com/v19.0/dialog/oauth?client_id=1053208033791589&redirect_uri=https%3A%2F%2Fglowbaybd.com%2Fmy-account%2F&state=gb_fb_auth&scope=email%2Cpublic_profile',
      );
      try {
        final ok = await launchUrl(fbAuthUrl, mode: LaunchMode.externalApplication);
        if (!ok) {
          await launchUrl(fbAuthUrl, mode: LaunchMode.inAppBrowserView);
        }
      } catch (e) {
        debugPrint('Direct Facebook OAuth launch error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ফেসবুক লগইন ওপেন করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      return;
    }
  }

  void _showWhatsAppSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GlowBay WhatsApp Support',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const Text(
                      'Select your preferred support desk',
                      style: TextStyle(fontSize: 11.5, color: _textSubtle),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Option 1: Bangladesh Helpline
            _buildWhatsAppOptionTile(
              ctx: ctx,
              flag: '🇧🇩',
              title: 'Bangladesh Customer Care',
              number: '+880 1948-667001',
              subtitle: 'Order tracking, delivery status & Dhaka hub support',
              waUrl: 'https://wa.me/8801948667001?text=Hello%20GlowBayBD,%20I%20need%20assistance%20with%20my%20order',
            ),
            const SizedBox(height: 10),

            // Option 2: Malaysia HQ
            _buildWhatsAppOptionTile(
              ctx: ctx,
              flag: '🇲🇾',
              title: 'Malaysia HQ & Dispatch Desk',
              number: '+60 11-2504 4155',
              subtitle: 'KL procurement, authentic sourcing & international freight',
              waUrl: 'https://wa.me/601125044155?text=Hello%20GlowBay%20HQ,%20I%20have%20an%20inquiry',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppOptionTile({
    required BuildContext ctx,
    required String flag,
    required String title,
    required String number,
    required String subtitle,
    required String waUrl,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          Navigator.pop(ctx);
          final uri = Uri.parse(waUrl);
          final phone = uri.path.replaceAll('/', '');
          final text = uri.queryParameters['text'] ?? '';
          await LauncherHelper.openWhatsApp(
            context: context,
            phone: phone.isNotEmpty ? phone : number,
            text: text,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderSubtle),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      number,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10.5, color: _textSubtle),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  void _showVipMembershipModal(BuildContext context, VipTierInfo currentTier) {
    HapticFeedback.mediumImpact();
    final isEn = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: currentTier.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.workspace_premium_rounded, color: currentTier.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GlowBay Loyalty Club',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          isEn
                              ? 'Automatically level up based on your orders and spend'
                              : 'কেনাকাটার ভিত্তিতে স্বয়ংক্রিয়ভাবে লেভেল আপ হোন',
                          style: const TextStyle(fontSize: 12, color: _textSubtle),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Current Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF131826), Color(0xFF1E2638)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: currentTier.primaryColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentTier.badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentTier.badge,
                            style: TextStyle(
                              color: currentTier.textColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Text(
                          'Level ${currentTier.level} of 4',
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentTier.discount,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: currentTier.progressRatio,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(currentTier.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentTier.remainingMsg,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                isEn ? '4 Membership Levels & Benefits' : 'চারটি মেম্বারশিপ লেভেল ও সুবিধাসমূহ',
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
              ),
              const SizedBox(height: 12),

              // Tier 1: Silver
              _buildTierCard(
                level: 1,
                title: 'Silver Member 🌱',
                requirement: isEn ? 'New Account • ৳0 – ৳4,999 or 0–1 Order' : 'নতুন অ্যাকাউন্ট • ৳০ – ৳৪,৯৯৯ বা ০–১ অর্ডার',
                perks: isEn
                    ? '• 100% Authentic Product Guarantee\n• Free Skin Consultation\n• Earn Glow Points with every order'
                    : '• ১০০% অথেনটিক পণ্য গ্যারান্টি\n• ফ্রি স্কিন কুইজ পরামর্শ\n• প্রতিটি অর্ডারে গ্লো পয়েন্ট অর্জন',
                color: const Color(0xFF64748B),
                isCurrent: currentTier.level == 1,
              ),
              const SizedBox(height: 10),

              // Tier 2: Gold
              _buildTierCard(
                level: 2,
                title: 'Gold Member ✨',
                requirement: isEn ? 'Total Spend ৳5,000+ or 2–5 Orders' : 'মোট কেনাকাটা ৳৫,০০০+ অথবা ২–৫টি অর্ডার',
                perks: isEn
                    ? '• 5% Exclusive Member Discount\n• Special Birthday Voucher\n• Priority Courier Tracking'
                    : '• ৫% স্পেশাল মেম্বার ডিসকাউন্ট\n• স্পেশাল বার্থডে ভাউচার\n• প্রায়োরিটি কুরিয়ার ট্র্যাকিং',
                color: const Color(0xFFEAB308),
                isCurrent: currentTier.level == 2,
              ),
              const SizedBox(height: 10),

              // Tier 3: Platinum
              _buildTierCard(
                level: 3,
                title: 'Platinum Member 💎',
                requirement: isEn ? 'Total Spend ৳15,000+ or 6–9 Orders' : 'মোট কেনাকাটা ৳১৫,০০০+ অথবা ৬–৯টি অর্ডার',
                perks: isEn
                    ? '• 7% Platinum Cashback / Discount\n• Surprise Luxury Gift Voucher\n• Early Access to New Arrivals'
                    : '• ৭% প্লাটিনাম ক্যাশব্যাক / ডিসকাউন্ট\n• স্পেশাল লাক্সারি গিফট ভাউচার\n• নতুন কালেকশনে আর্লি অ্যাক্সেস',
                color: const Color(0xFF8B5CF6),
                isCurrent: currentTier.level == 3,
              ),
              const SizedBox(height: 10),

              // Tier 4: Diamond VIP
              _buildTierCard(
                level: 4,
                title: 'Diamond VIP 👑',
                requirement: isEn ? 'Total Spend ৳30,000+ or 10+ Orders' : 'মোট কেনাকাটা ৳৩০,০০০+ অথবা ১০+ অর্ডার',
                perks: isEn
                    ? '• 10% Lifetime Flat VIP Rebate\n• Personal Beauty Consultant (WhatsApp VIP Desk)\n• Priority Direct Flight from Malaysia'
                    : '• ১০% লাইফটাইম ফ্ল্যাট ভিআইপি রিবেট\n• পার্সোনাল বিউটি কনসালট্যান্ট (WhatsApp VIP Desk)\n• মালয়েশিয়া থেকে প্রায়োরিটি ডিরেক্ট ফ্লাইট',
                color: const Color(0xFFFFB020),
                isCurrent: currentTier.level == 4,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEn ? 'Shop to Level Up 🛍️' : 'কেনাকাটা করে লেভেল আপ হোন 🛍️',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required int level,
    required String title,
    required String requirement,
    required String perks,
    required Color color,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? color : _borderSubtle,
          width: isCurrent ? 1.8 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: color,
                    child: Text('$level', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isCurrent ? color : _textDark)),
                ],
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'YOUR TIER',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(requirement, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          Text(perks, style: const TextStyle(fontSize: 11, color: _textSubtle, height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: _surfaceBg,
      body: auth.isLoggedIn ? _buildDashboardView(auth) : _buildAuthView(auth),
    );
  }

  // =========================================================================
  // 1. DASHBOARD VIEW (Shopee / Lazada Flagship Profile Experience)
  // =========================================================================
  Widget _buildDashboardView(AuthProvider auth) {
    final profile = auth.currentUser!;
    final dashboard = auth.dashboardData ??
        DashboardData(
          profile: profile,
          glowCoins: 0,
          rewardPoints: 0,
          activeVouchers: 0,
          totalSpent: '৳0',
          toPay: 0,
          toShip: 0,
          shipped: 0,
          delivered: 0,
          returns: 0,
          inTransit: 0,
          toReview: 0,
          totalOrders: 0,
          recentOrders: [],
        );

    final tier = dashboard.tierInfo;

    return Column(
      children: [
        // 0. Pinned Sticky Top Action Bar with MALL badge & Quick Actions
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'My Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryPink, _primaryGradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'MALL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // WhatsApp Live Quick Support
                  _buildHeaderIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    tooltip: 'WhatsApp Live Support',
                    badgeColor: const Color(0xFF10B981),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showWhatsAppSelector(context);
                    },
                  ),
                  const SizedBox(width: 8),

                  // Store Sync Button
                  _buildHeaderIconButton(
                    icon: Icons.sync_rounded,
                    tooltip: 'Sync Live Store',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      auth.fetchDashboard();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dashboard synchronized with live store.'),
                          duration: Duration(seconds: 1),
                          backgroundColor: Color(0xFF1E293B),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Lazada / Shopee Setting Gear Icon ⚙️
                  _buildHeaderIconButton(
                    icon: Icons.settings_outlined,
                    tooltip: 'Settings & More',
                    isHighlighted: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showLazadaSettingsModal(context, auth);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // 1. Scrollable Dashboard Body
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => auth.fetchDashboard(),
            color: _primaryPink,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
              children: [
                // ZONE 1: Champagne Gold VIP Hero (Lazada 1:1 Style)
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF5F7), Color(0xFFFFF0F5), Color(0xFFFFE4EC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFCDD9), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF2A6D).withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Avatar with Pink Rim (68px)
                          Stack(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _primaryPink, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryPink.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: profile.avatar.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: profile.avatar,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, dynamic error) => _buildAvatarFallback(profile.name),
                                        )
                                      : _buildAvatarFallback(profile.name),
                                ),
                              ),
                              // Edit pencil badge
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsScreen())),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _primaryPink,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.edit_rounded, size: 11, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),

                          // User Identity & Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name.isNotEmpty ? profile.name : 'GlowBay Member',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: _textDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  profile.phone.isNotEmpty ? profile.phone : profile.email,
                                  style: const TextStyle(
                                    color: _textSubtle,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 7),
                                // Member Center coin capsule
                                GestureDetector(
                                  onTap: () => _showVipMembershipModal(context, tier),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFFFB020), Color(0xFFFF7A00)],
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 13),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${dashboard.glowCoins > 0 ? dashboard.glowCoins : (dashboard.rewardPoints > 0 ? dashboard.rewardPoints : 50)} GlowCoins',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 13),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // VIP Tier Badge (right side)
                          GestureDetector(
                            onTap: () => _showVipMembershipModal(context, tier),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: tier.badgeBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: tier.primaryColor.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium_rounded, color: tier.primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    tier.badge,
                                    style: TextStyle(
                                      color: tier.textColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Level-Up Progress Bar (light bg)
                      GestureDetector(
                        onTap: () => _showVipMembershipModal(context, tier),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFCDD9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tier Level ${tier.level} • ${tier.label}',
                                    style: const TextStyle(
                                      color: _textDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  Text(
                                    tier.nextTier != null ? 'Next: ${tier.nextTier} ›' : 'Max Level 👑',
                                    style: TextStyle(
                                      color: tier.primaryColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: tier.progressRatio,
                                  minHeight: 5,
                                  backgroundColor: const Color(0xFFFFCDD9),
                                  valueColor: AlwaysStoppedAnimation<Color>(tier.primaryColor),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome, size: 12, color: tier.primaryColor),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      tier.remainingMsg,
                                      style: const TextStyle(
                                        color: _textSubtle,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ZONE 2: Tri-Card Rewards Strip (GlowCoins | Vouchers | VIP Tier)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showVipMembershipModal(context, tier),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Column(
                              children: [
                                const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB020), size: 22),
                                const SizedBox(height: 5),
                                Text(
                                  '${dashboard.glowCoins > 0 ? dashboard.glowCoins : (dashboard.rewardPoints > 0 ? dashboard.rewardPoints : 50)}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _textDark),
                                ),
                                const Text('GlowCoins', style: TextStyle(fontSize: 10.5, color: _textSubtle, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 44, color: _borderSubtle),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VouchersWalletScreen())),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Column(
                              children: [
                                Icon(Icons.confirmation_number_outlined, color: _primaryPink, size: 22),
                                const SizedBox(height: 5),
                                Text(
                                  '${dashboard.activeVouchers > 0 ? dashboard.activeVouchers : 3}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _textDark),
                                ),
                                const Text('Vouchers', style: TextStyle(fontSize: 10.5, color: _textSubtle, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 44, color: _borderSubtle),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showVipMembershipModal(context, tier),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Column(
                              children: [
                                Icon(Icons.workspace_premium_rounded, color: tier.primaryColor, size: 22),
                                const SizedBox(height: 5),
                                Text(
                                  tier.badge,
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: tier.primaryColor),
                                ),
                                const Text('VIP Tier', style: TextStyle(fontSize: 10.5, color: _textSubtle, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ZONE 3: Daily Skincare Check-In Gamification Bar
                _buildDailyCheckIn(dashboard),
                const SizedBox(height: 14),

          // 2. Shopee / Lazada "My Orders" Status Hub
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hub Header: Title + "View Purchase History ›"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _primaryPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: _primaryPink, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'My Orders',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen()));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Order History',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _primaryPink,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: _primaryPink),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5 Status Columns with Dynamic Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildOrderFunnelItem(
                      label: 'To Pay',
                      count: dashboard.toPay,
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: const Color(0xFFFF7A00),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen(initialFunnel: 'to_pay'))),
                    ),
                    _buildOrderFunnelItem(
                      label: 'To Ship',
                      count: dashboard.toShip,
                      icon: Icons.inventory_2_outlined,
                      accentColor: _primaryPink,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen(initialFunnel: 'to_ship'))),
                    ),
                    _buildOrderFunnelItem(
                      label: 'In Transit',
                      count: (dashboard.inTransit > 0 ? dashboard.inTransit : dashboard.shipped),
                      icon: Icons.local_shipping_outlined,
                      accentColor: const Color(0xFF3B82F6),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen(initialFunnel: 'in_transit'))),
                    ),
                    _buildOrderFunnelItem(
                      label: 'Delivered',
                      count: dashboard.delivered,
                      icon: Icons.verified_outlined,
                      accentColor: const Color(0xFF10B981),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen(initialFunnel: 'delivered'))),
                    ),
                    _buildOrderFunnelItem(
                      label: 'Cancelled',
                      count: dashboard.cancelled,
                      icon: Icons.cancel_outlined,
                      accentColor: const Color(0xFFEF4444),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen(initialFunnel: 'cancelled'))),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ZONE 4b: Malaysia Direct Flight Delivery Stepper (after orders)
          _buildFlightStepper(dashboard),
          const SizedBox(height: 14),

          // ZONE 5: Glow Channels 3x2 Discovery Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Glow Channels',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                  children: [
                    _buildServiceGridItem(
                      label: 'Flash Deals',
                      icon: Icons.local_fire_department_rounded,
                      bgGradient: const [Color(0xFFFFF3CD), Color(0xFFFFEBA0)],
                      iconColor: const Color(0xFFFF7A00),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'Brand Stores',
                      icon: Icons.store_rounded,
                      bgGradient: const [Color(0xFFFFE4EC), Color(0xFFFFCDD9)],
                      iconColor: _primaryPink,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'AI Routine',
                      icon: Icons.auto_awesome,
                      bgGradient: const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                      iconColor: const Color(0xFF7C3AED),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkinAnalyzerScreen())),
                    ),
                    _buildServiceGridItem(
                      label: '100% Genuine',
                      icon: Icons.verified_rounded,
                      bgGradient: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                      iconColor: const Color(0xFF059669),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'Flight Tracker',
                      icon: Icons.flight_rounded,
                      bgGradient: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      iconColor: const Color(0xFF2563EB),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'VIP Support',
                      icon: Icons.headset_mic_rounded,
                      bgGradient: const [Color(0xFFFDF4FF), Color(0xFFFAE8FF)],
                      iconColor: const Color(0xFFA21CAF),
                      onTap: () => _showWhatsAppSelector(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ZONE 6: 8-Tile Utility Grid (My Tools)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Account Tools',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.78,
                  children: [
                    _buildServiceGridItem(
                      label: 'Address Book',
                      icon: Icons.location_on_rounded,
                      bgGradient: const [Color(0xFFFFF3CD), Color(0xFFFFEBA0)],
                      iconColor: const Color(0xFFFF7A00),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressBookScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'My Vouchers',
                      icon: Icons.confirmation_number_rounded,
                      bgGradient: const [Color(0xFFFFE4EC), Color(0xFFFFCDD9)],
                      iconColor: _primaryPink,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VouchersWalletScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'My Wishlist',
                      icon: Icons.favorite_rounded,
                      bgGradient: const [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                      iconColor: const Color(0xFFF43F5E),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'Track Order',
                      icon: Icons.local_shipping_rounded,
                      bgGradient: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      iconColor: const Color(0xFF2563EB),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'Skin Analyzer',
                      icon: Icons.auto_awesome,
                      bgGradient: const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                      iconColor: const Color(0xFF7C3AED),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkinAnalyzerScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'FAQs',
                      icon: Icons.help_outline_rounded,
                      bgGradient: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                      iconColor: const Color(0xFF059669),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'Policies',
                      icon: Icons.policy_rounded,
                      bgGradient: const [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                      iconColor: const Color(0xFF0284C7),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                    ),
                    _buildServiceGridItem(
                      label: 'VIP Support',
                      icon: Icons.headset_mic_rounded,
                      bgGradient: const [Color(0xFFFDF4FF), Color(0xFFFAE8FF)],
                      iconColor: const Color(0xFFA21CAF),
                      onTap: () => _showWhatsAppSelector(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 100% Malaysian Direct Import Assurance Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF5F7), Color(0xFFFFE4EC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFCDD9)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _primaryPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🇲🇾', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '100% Direct Malaysian Sourcing',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF3B82F6)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Directly procured from verified distributors in Kuala Lumpur & Selangor.',
                        style: TextStyle(fontSize: 10.5, color: _textSubtle, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // App Trust & Version Seal
          Center(
            child: Text(
              'GlowBay App v2.4.0 • 100% Authentic Malaysian Skincare\nEncrypted WooCommerce Backend API',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: const Color(0xFF94A3B8), height: 1.4),
            ),
          ),
        ],
      ),
    ),
  ),
],
);
  }

  // =========================================================================
  // 2. AUTH VIEW (Lazada / Shopee Standard Login & Register)
  // =========================================================================
  Widget _buildAuthView(AuthProvider auth) {
    final isEn = context.watch<LanguageProvider>().isEnglish;
    return SafeArea(
      top: true,
      bottom: true,
      child: Column(
        children: [
          // Top Navigation Bar (Back to Home / Previous screen)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19, color: _textDark),
                  tooltip: isEn ? 'Back' : 'পেছনে যান',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else if (widget.onBackToHome != null) {
                      widget.onBackToHome!();
                    }
                  },
                ),
                Text(
                  _authMode == AuthMode.login
                      ? (isEn ? 'Sign In' : 'লগইন করুন')
                      : _authMode == AuthMode.register
                          ? (isEn ? 'Create Account' : 'নতুন অ্যাকাউন্ট তৈরি')
                          : (isEn ? 'Reset Password' : 'পাসওয়ার্ড পুনরুদ্ধার'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (widget.onBackToHome != null) {
                      widget.onBackToHome!();
                    } else if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.home_rounded, size: 18, color: _primaryPink),
                  label: Text(
                    isEn ? 'Home' : 'হোম',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _primaryPink),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Modern Clean Brand Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GlowBay',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                ),
              ),
              Text(
                'BD',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _primaryPink,
                ),
              ),
              const SizedBox(width: 4),
              const Text('✨', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Authentic Malaysian & Global Beauty Store',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSubtle,
            ),
          ),
          const SizedBox(height: 20),

          // Auth White Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Subtitle
                Text(
                  _authMode == AuthMode.login
                      ? 'Welcome Back! 👋'
                      : _authMode == AuthMode.register
                          ? 'Create Account ✨'
                          : 'Reset Password 🔐',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _authMode == AuthMode.login
                      ? 'Sign in to access your orders, perks & profile'
                      : _authMode == AuthMode.register
                          ? 'Register to track parcels & enjoy member discounts'
                          : 'Enter your email address to receive password reset steps.',
                  style: const TextStyle(fontSize: 12, color: _textSubtle),
                ),
                const SizedBox(height: 20),

                // Segmented Tabs [ Login ] [ Register ]
                if (_authMode != AuthMode.forgot) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _authMode = AuthMode.login),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _authMode == AuthMode.login ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _authMode == AuthMode.login
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.06),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: _authMode == AuthMode.login ? _primaryPink : _textSubtle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _authMode = AuthMode.register),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _authMode == AuthMode.register ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _authMode == AuthMode.register
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.06),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: _authMode == AuthMode.register ? _primaryPink : _textSubtle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // PANE A: LOGIN
                if (_authMode == AuthMode.login) ...[
                  _buildFieldLabel('Phone Number or Email'),
                  _buildInputField(
                    controller: _usernameCtrl,
                    hint: '01XXXXXXXXX or email@example.com',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  _buildFieldLabel('Password'),
                  _buildInputField(
                    controller: _passwordCtrl,
                    hint: 'Enter your account password',
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 18,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: _primaryPink,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _rememberMe = val ?? true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Remember me',
                            style: TextStyle(fontSize: 12, color: _textSubtle, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _authMode = AuthMode.forgot),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _primaryPink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Standard 48px CTA Button
                  _buildSubmitButton(
                    label: 'Login to Account',
                    loading: auth.isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 14),

                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('By logging in, you agree to our ', style: TextStyle(fontSize: 11, color: _textSubtle)),
                        GestureDetector(
                          onTap: _openTerms,
                          child: const Text(
                            'Terms',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _primaryPink, decoration: TextDecoration.underline),
                          ),
                        ),
                        const Text(' & ', style: TextStyle(fontSize: 11, color: _textSubtle)),
                        GestureDetector(
                          onTap: _openPrivacy,
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _primaryPink, decoration: TextDecoration.underline),
                          ),
                        ),
                        const Text('.', style: TextStyle(fontSize: 11, color: _textSubtle)),
                      ],
                    ),
                  ),
                ] else if (_authMode == AuthMode.register) ...[
                  // PANE B: REGISTER
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('First Name *'),
                            _buildInputField(
                              controller: _firstNameCtrl,
                              hint: 'First name',
                              icon: Icons.person_outline,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Last Name *'),
                            _buildInputField(
                              controller: _lastNameCtrl,
                              hint: 'Last name',
                              icon: Icons.person_outline,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFieldLabel('Phone Number (01XXXXXXXXX) *'),
                  _buildInputField(
                    controller: _phoneCtrl,
                    hint: '01XXXXXXXXX',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  _buildFieldLabel('Email Address *'),
                  _buildInputField(
                    controller: _emailCtrl,
                    hint: 'Enter your email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // DOB & Gender Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Date of Birth'),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000, 1, 1),
                                  firstDate: DateTime(1940),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _dobCtrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: _buildInputField(
                                  controller: _dobCtrl,
                                  hint: 'YYYY-MM-DD (Optional)',
                                  icon: Icons.calendar_today_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Gender'),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _borderSubtle),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedGender.isEmpty ? null : _selectedGender,
                                  hint: const Text('Select Gender', style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _textSubtle),
                                  items: const [
                                    DropdownMenuItem(value: 'female', child: Text('Female (মহিলা)', style: TextStyle(fontSize: 11.5))),
                                    DropdownMenuItem(value: 'male', child: Text('Male (পুরুষ)', style: TextStyle(fontSize: 11.5))),
                                    DropdownMenuItem(value: 'other', child: Text('Other (অন্যান্য)', style: TextStyle(fontSize: 11.5))),
                                  ],
                                  onChanged: (val) => setState(() => _selectedGender = val ?? ''),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Password & Confirm Password Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Password *'),
                            _buildInputField(
                              controller: _passwordCtrl,
                              hint: 'Min 6 chars',
                              icon: Icons.lock_outline,
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16, color: const Color(0xFF94A3B8)),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Confirm Password *'),
                            _buildInputField(
                              controller: _confirmPasswordCtrl,
                              hint: 'Re-enter password',
                              icon: Icons.shield_outlined,
                              obscure: _obscureConfirmPassword,
                              suffix: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16, color: const Color(0xFF94A3B8)),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Terms Agreement
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _agreeTerms,
                          activeColor: _primaryPink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _agreeTerms = val ?? true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('I agree to the ', style: TextStyle(fontSize: 11.5, color: _textSubtle)),
                            GestureDetector(
                              onTap: _openTerms,
                              child: const Text(
                                'Terms & Conditions',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: _primaryPink, decoration: TextDecoration.underline),
                              ),
                            ),
                            const Text(' and ', style: TextStyle(fontSize: 11.5, color: _textSubtle)),
                            GestureDetector(
                              onTap: _openPrivacy,
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: _primaryPink, decoration: TextDecoration.underline),
                              ),
                            ),
                            const Text('.', style: TextStyle(fontSize: 11.5, color: _textSubtle)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  _buildSubmitButton(
                    label: 'Create Account →',
                    loading: auth.isLoading,
                    onPressed: _handleRegister,
                  ),
                ] else ...[
                  // PANE C: FORGOT PASSWORD
                  _buildFieldLabel('Email Address *'),
                  _buildInputField(
                    controller: _forgotEmailCtrl,
                    hint: 'Enter your registered email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  _buildSubmitButton(
                    label: 'Send Reset Link →',
                    loading: _isForgotLoading,
                    onPressed: _handleForgotPassword,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _authMode = AuthMode.login),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '← Back to Login',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _primaryPink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Social Grid (Google & Facebook)
                if (_authMode != AuthMode.forgot) ...[
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: _borderSubtle)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Or continue with', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                      ),
                      Expanded(child: Divider(color: _borderSubtle)),
                    ],
                  ),
                  const SizedBox(height: 16),

                                    Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => _handleSocialAuth('google'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _borderSubtle),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata, color: Color(0xFFEA4335), size: 26),
                                SizedBox(width: 6),
                                Text('Google', style: TextStyle(color: _textDark, fontWeight: FontWeight.w800, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _handleSocialAuth('facebook'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.facebook, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Facebook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bottom Trust Badges
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderSubtle),
            ),
            child: Row(
              children: [
                _buildTrustCol(Icons.verified_outlined, _primaryPink, '100% Authentic', 'Original Sourced'),
                _buildTrustDivider(),
                _buildTrustCol(Icons.flight_takeoff_outlined, const Color(0xFFFF7A00), 'Direct Flight', 'From Malaysia'),
                _buildTrustDivider(),
                _buildTrustCol(Icons.shield_outlined, const Color(0xFF10B981), 'Safe Checkout', 'SSL Encrypted'),
                _buildTrustDivider(),
                _buildTrustCol(Icons.support_agent, const Color(0xFF3B82F6), 'Live Care', 'Chat & Call'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Legal & Support Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _openTerms,
                child: const Text('Terms & Conditions', style: TextStyle(fontSize: 11.5, color: _textSubtle, fontWeight: FontWeight.w600)),
              ),
              const Text('  •  ', style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))),
              GestureDetector(
                onTap: _openPrivacy,
                child: const Text('Privacy Policy', style: TextStyle(fontSize: 11.5, color: _textSubtle, fontWeight: FontWeight.w600)),
              ),
              const Text('  •  ', style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                child: const Text('Help & Support', style: TextStyle(fontSize: 11.5, color: _textSubtle, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS (Shopee / Lazada Flagship Components)
  // =========================================================================

  // ZONE 3: Daily Skincare Check-In Bar
  Widget _buildDailyCheckIn(DashboardData dashboard) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Daily check-in complete! +20 GlowCoins earned.'),
            backgroundColor: const Color(0xFFFF2A6D),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD84D).withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB020).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('✨', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Skincare Check-In',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to earn +20 GlowCoins today',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB020),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Check In',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ZONE 4b: Malaysia Direct Flight Delivery Stepper
  Widget _buildFlightStepper(DashboardData dashboard) {
    final steps = [
      {'icon': '🏬', 'label': 'KLIA Hub', 'sub': 'Sourced & Verified'},
      {'icon': '✈️', 'label': 'In Flight', 'sub': 'Direct Flight Dispatch'},
      {'icon': '🛬', 'label': 'Dhaka Hub', 'sub': 'Customs Clearance'},
      {'icon': '🚚', 'label': 'Courier', 'sub': 'Local Express Delivery'},
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_rounded, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(
                'Direct Flight Delivery Route',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: const Color(0xFF1E40AF),
                ),
              ),
              const Spacer(),
              const Text('10–25 Days', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Expanded(
                  child: Container(height: 1.5, color: const Color(0xFF93C5FD)),
                );
              }
              final s = steps[i ~/ 2];
              return Column(
                children: [
                  Text(s['icon']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    s['label']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 9.5,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                  Text(
                    s['sub']!,
                    style: const TextStyle(fontSize: 8.5, color: Color(0xFF3B82F6)),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ZONE 7: Lazada-Style Settings Bottom Sheet Modal
  void _showLazadaSettingsModal(BuildContext ctx, AuthProvider auth) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final items = [
          {'icon': Icons.person_outline_rounded, 'label': 'Edit Profile', 'screen': const AccountSettingsScreen()},
          {'icon': Icons.notifications_outlined, 'label': 'Notifications', 'screen': const NotificationsScreen()},
          {'icon': Icons.location_on_outlined, 'label': 'Address Book', 'screen': const AddressBookScreen()},
          {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy Policy', 'screen': const PrivacyPolicyScreen()},
          {'icon': Icons.article_outlined, 'label': 'Terms & Conditions', 'screen': const TermsConditionsScreen()},
          {'icon': Icons.help_outline_rounded, 'label': 'Help & FAQs', 'screen': const FaqScreen()},
          {'icon': Icons.support_agent_rounded, 'label': 'Customer Support', 'screen': null},
          {'icon': Icons.info_outline_rounded, 'label': 'About GlowBayBD', 'screen': null},
        ];
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Settings & More',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: _textDark,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ...items.map((item) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      final screen = item['screen'];
                      if (screen != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => screen as Widget));
                      } else if (item['label'] == 'Customer Support') {
                        _showWhatsAppSelector(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Icon(item['icon'] as IconData, size: 21, color: _textDark),
                          const SizedBox(width: 16),
                          Text(
                            item['label'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              // Log Out Button (Red)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    await auth.logout();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, size: 21, color: Color(0xFFDC2626)),
                        const SizedBox(width: 16),
                        const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: _primaryPink,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildOrderFunnelItem({
    required String label,
    required int count,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                if (count > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _primaryPink,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: _textDark,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? badgeColor,
    bool isHighlighted = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isHighlighted ? _primaryPink.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighlighted ? _primaryPink.withValues(alpha: 0.35) : _borderSubtle,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isHighlighted ? _primaryPink : _textDark,
                ),
                if (badgeColor != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGridItem({
    required String label,
    required IconData icon,
    required List<Color> bgGradient,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: bgGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.16),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textDark,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: _textDark)),
    );
  }

  Widget _buildTrustCol(IconData icon, Color color, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 3),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: _textDark)),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, color: _textSubtle)),
        ],
      ),
    );
  }

  Widget _buildTrustDivider() {
    return Container(width: 1, height: 26, color: _borderSubtle);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderSubtle),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: _textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({required String label, required bool loading, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryPink, _primaryGradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primaryPink.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      ),
    );
  }
}
