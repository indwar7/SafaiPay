import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Staggered controller
  late AnimationController _staggerController;

  // Resend timer
  Timer? _resendTimer;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _entranceController.forward();
    _staggerController.forward();

    // Auto-focus first field
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNodes[0].requestFocus();
    });

    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
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

  Widget _buildStaggered(double begin, double end, {required Widget child}) {
    return FadeTransition(
      opacity: _staggerFade(begin, end),
      child: SlideTransition(
        position: _staggerSlide(begin, end),
        child: child,
      ),
    );
  }

  void _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _showSnackBar('Please enter complete 6-digit OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if user exists
      final existingUser =
          await _firestoreService.getUserById(userCredential.user!.uid);

      if (existingUser == null) {
        // Create new user
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          phoneNumber: widget.phoneNumber,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(newUser);
      }

      if (mounted) {
        _showSnackBar('Login successful!', isError: false);
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainApp);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Invalid OTP. Please check and try again.', isError: true);
    }
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
                    const SizedBox(height: 20),

                    // Back Button
                    _buildStaggered(
                      0.0,
                      0.2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surface3,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textWhite,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Message Icon
                    _buildStaggered(0.1, 0.35, child: _buildMessageIcon()),
                    const SizedBox(height: 32),

                    // Title
                    _buildStaggered(
                      0.15,
                      0.4,
                      child: Text(
                        'Verify OTP',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 40,
                          color: AppColors.textWhite,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    _buildStaggered(
                      0.2,
                      0.45,
                      child: Column(
                        children: [
                          Text(
                            'Enter the 6-digit code sent to',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.phoneNumber,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neonLime,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // OTP Boxes
                    _buildStaggered(0.3, 0.6, child: _buildOTPBoxes()),
                    const SizedBox(height: 32),

                    // Verify Button
                    _buildStaggered(0.4, 0.7, child: _buildVerifyButton()),
                    const SizedBox(height: 28),

                    // Resend
                    _buildStaggered(0.5, 0.8, child: _buildResendSection()),
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

  Widget _buildMessageIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonLime.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.message_rounded,
          size: 40,
          color: AppColors.neonLime,
        ),
      ),
    );
  }

  Widget _buildOTPBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return _OTPDigitBox(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            // Auto-submit on last digit
            if (index == 5 && value.isNotEmpty) {
              final otp = _otpControllers.map((c) => c.text).join();
              if (otp.length == 6) {
                FocusScope.of(context).unfocus();
                _verifyOTP();
              }
            }
          },
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOTP,
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
                      AlwaysStoppedAnimation<Color>(AppColors.textOnLime),
                ),
              )
            : Text(
                'VERIFY & CONTINUE',
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  color: AppColors.textOnLime,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    if (_canResend) {
      return GestureDetector(
        onTap: () {
          _showSnackBar('Resending OTP...', isError: false);
          _startResendTimer();
        },
        child: Text(
          'Resend OTP',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.neonLime,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Resend code in ',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '00:${_resendCountdown.toString().padLeft(2, '0')}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _entranceController.dispose();
    _staggerController.dispose();
    super.dispose();
  }
}

// Individual OTP digit box with scale-in animation and focus-aware border
class _OTPDigitBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OTPDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OTPDigitBox> createState() => _OTPDigitBoxState();
}

class _OTPDigitBoxState extends State<_OTPDigitBox> {
  bool _isFocused = false;
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onValueChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  void _onValueChange() {
    if (mounted) setState(() => _hasValue = widget.controller.text.isNotEmpty);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? AppColors.neonLime : AppColors.borderDefault,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.neonLime.withValues(alpha: 0.12),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: _hasValue ? 0.0 : 1.0, end: _hasValue ? 1.0 : 0.0),
        curve: Curves.easeOutBack,
        builder: (context, scaleValue, child) {
          return Transform.scale(
            scale: _hasValue ? scaleValue.clamp(0.5, 1.0) : 1.0,
            child: child,
          );
        },
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
          ),
          cursorColor: AppColors.neonLime,
          cursorWidth: 2,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
