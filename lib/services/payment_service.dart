import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class PaymentService {
  late Razorpay _razorpay;
  Function(String)? _onSuccess;
  Function(String)? _onError;

  void initialize({
    required Function(String) onSuccess,
    required Function(String) onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_onSuccess != null) {
      _onSuccess!(response.paymentId ?? '');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_onError != null) {
      _onError!(response.message ?? 'Payment failed');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  void startPayment({
    required int amount, // in rupees
    required String name,
    required String phoneNumber,
    String? email,
  }) {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY_HERE', // Add your Razorpay key
      'amount': amount * 100, // Convert to paise
      'name': 'SafaiPay',
      'description': 'Withdraw to bank account',
      'prefill': {
        'contact': phoneNumber,
        'email': email ?? '',
      },
      'theme': {
        'color': '#2ECC71',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      if (_onError != null) {
        _onError!('Failed to open payment: $e');
      }
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
