import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isPhoneFocused = false;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Staggered entrance animations
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();

    _phoneFocusNode.addListener(() {
      setState(() => _isPhoneFocused = _phoneFocusNode.hasFocus);
    });

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _entranceController.forward();
    _staggerController.forward();
  }

  Animation<double> _staggerFade(double begin, double end) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggerSlide(double begin, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _sendOTP() async {
    if (_phoneController.text.length != 10) {
      _showSnackBar('Please enter a valid 10-digit phone number', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final phoneNumber = '+91${_phoneController.text}';

    await _authService.sendOtp(
      phone: phoneNumber,
      onCodeSent: (verificationId) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushNamed(
          AppRoutes.otpVerification,
          arguments: {
            'verificationId': verificationId,
            'phoneNumber': phoneNumber,
          },
        );
      },
      onError: (error) {
        setState(() => _isLoading = false);
        _showSnackBar(error, isError: true);
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.error : AppColors.neonLime,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.dmSans(
                  color: AppColors.textWhite,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.cardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError
                ? AppColors.error.withValues(alpha: 0.3)
                : AppColors.neonLime.withValues(alpha: 0.3),
          ),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    _buildStaggered(0.0, 0.3, child: _buildLogo()),
                    const SizedBox(height: 24),

                    // Title
                    _buildStaggered(
                      0.1,
                      0.4,
                      child: Text(
                        'SafaiPay',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 42,
                          color: AppColors.textWhite,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    _buildStaggered(
                      0.15,
                      0.45,
                      child: Text(
                        'Clean Actions. Real Rewards.',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 56),

                    // Headline
                    _buildStaggered(
                      0.25,
                      0.55,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter your number',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 40,
                            color: AppColors.textWhite,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Phone Input
                    _buildStaggered(0.3, 0.6, child: _buildPhoneInput()),
                    const SizedBox(height: 24),

                    // Send OTP Button
                    _buildStaggered(0.4, 0.7, child: _buildSendOTPButton()),
                    const SizedBox(height: 32),

                    // Trust Badge
                    _buildStaggered(0.5, 0.8, child: _buildTrustBadge()),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaggered(double begin, double end, {required Widget child}) {
    return FadeTransition(
      opacity: _staggerFade(begin, end),
      child: SlideTransition(
        position: _staggerSlide(begin, end),
        child: child,
      ),
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.neonLime,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonLime.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.eco_rounded,
          size: 60,
          color: AppColors.neonLime,
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPhoneFocused ? AppColors.neonLime : AppColors.borderDefault,
          width: _isPhoneFocused ? 1.5 : 1,
        ),
        boxShadow: _isPhoneFocused
            ? [
                BoxShadow(
                  color: AppColors.neonLime.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _phoneController,
        focusNode: _phoneFocusNode,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textWhite,
          letterSpacing: 1.5,
        ),
        cursorColor: AppColors.neonLime,
        decoration: InputDecoration(
          hintText: 'Phone Number',
          hintStyle: GoogleFonts.dmSans(
            color: AppColors.textTertiary,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.neonLime.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('\u{1F1EE}\u{1F1F3}',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        '+91',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.borderActive,
                  margin: const EdgeInsets.only(left: 12),
                ),
              ],
            ),
          ),
          counterText: '',
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSendOTPButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonLime,
          foregroundColor: AppColors.textOnLime,
          disabledBackgroundColor: AppColors.neonLime.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.neonLime),
                ),
              )
            : Text(
                'SEND OTP',
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  color: AppColors.textOnLime,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildTrustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 18,
            color: AppColors.textWhite,
          ),
          const SizedBox(width: 8),
          Text(
            'Secure & Verified',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _entranceController.dispose();
    _staggerController.dispose();
    super.dispose();
  }
}
