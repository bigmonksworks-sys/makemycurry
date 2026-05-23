import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/place_order_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;

class RazorpayPaymentScreen extends StatefulWidget {
  final PlaceOrderModel orderBody;
  final double totalAmount;
  final String customerEmail;
  final String customerPhone;

  final Function(String paymentId, String razorpayOrderId) onPaymentSuccess;

  const RazorpayPaymentScreen({
    super.key,
    required this.orderBody,
    required this.totalAmount,
    required this.customerEmail,
    required this.customerPhone,
    required this.onPaymentSuccess,
  });

  @override
  State<RazorpayPaymentScreen> createState() => _RazorpayPaymentScreenState();
}

class _RazorpayPaymentScreenState extends State<RazorpayPaymentScreen> {
  late Razorpay _razorpay;
  bool _isLoading = true;
  String? _razorpayOrderId;
  String _currentStep = 'Initializing payment...';
  bool _paymentCompleted = false;
  bool _isNavigating = false; // Add this flag to prevent multiple navigations
  Map<String, dynamic>? _razorpayOrderData;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _createRazorpayOrder();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  

  Future<void> _createRazorpayOrder() async {
    try {
      _updateStep('Setting up payment gateway...');

      double cleanAmount = double.parse(widget.totalAmount.toStringAsFixed(2));
      debugPrint('🔹 Creating Razorpay order - Amount: ₹$cleanAmount');

      final response = await http.post(
        Uri.parse(
            '${AppConstants.baseUrl}/api/v1/payment/razor-pay/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': cleanAmount,
          'receipt':
              'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary receipt
        }),
      );

      debugPrint('📡 Razorpay API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          _razorpayOrderId = responseData['order_id'];
          _razorpayOrderData = responseData;
          debugPrint('🆔 Razorpay Order ID: $_razorpayOrderId');

          _updateStep('Opening payment interface...');
          await Future.delayed(const Duration(milliseconds: 500));

          _openRazorpayCheckout();
        } else {
          _handleError(
              'Razorpay order creation failed: ${responseData['message']}');
        }
      } else {
        _handleError(
            'Server error creating Razorpay order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(
          '❌ Network error during Razorpay order creation: ${e.toString()}');
      _handleError('Network error: ${e.toString()}');
    }
  }

  void _openRazorpayCheckout() {
    if (_isNavigating || _paymentCompleted) {
      return; // Prevent if already navigating or completed
    }

    setState(() {
      _isLoading = false;
      _currentStep = 'Complete payment in Razorpay';
    });
    print("=====================");
    print(widget.customerPhone);
    var options = {
      'key': _razorpayOrderData!['key'],
      'amount': _razorpayOrderData!['amount'],
      'currency': _razorpayOrderData!['currency'],
      'name': 'Make My Curry',
      'description': 'Payment for grocery order',
      'order_id': _razorpayOrderData!['order_id'],
      'prefill': {
        'email': widget.customerEmail.isNotEmpty
            ? widget.customerEmail
            : 'customer@makemycurry.com',
        'contact': widget.customerPhone.isNotEmpty
            ? widget.customerPhone
            : '9999999999', // Add phone number here
      },
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _handleError('Error opening payment: ${e.toString()}');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_paymentCompleted || _isNavigating) {
      return; // Prevent duplicate processing
    }

    log('Payment Success: ${response.paymentId}');

    _updateStep('Verifying payment...');
    setState(() {
      _isLoading = true;
    });

    try {
      await _verifyPayment(
        response.paymentId!,
        response.orderId!,
        response.signature!,
      );
    } catch (e) {
      _handleError('Error verifying payment: ${e.toString()}');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    if (_paymentCompleted || _isNavigating) {
      return; // Prevent duplicate processing
    }

    log('Payment Error: ${response.code} - ${response.message}');

    // Clear Razorpay instance immediately
    _razorpay.clear();

    // Show error and navigate back
    // _handleError('Payment failed: ${response.message ?? 'Something went wrong'}');
    _handleError('Payment failed ');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_paymentCompleted || _isNavigating) {
      return; // Prevent duplicate processing
    }

    log('External Wallet: ${response.walletName}');
    _handleError('External wallet selected: ${response.walletName}');
  }

  Future<void> _verifyPayment(
      String paymentId, String orderId, String signature) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConstants.baseUrl}/api/v1/payment/razor-pay/verify-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          _handleVerificationSuccess(paymentId, orderId);
        } else {
          _handleVerificationFailure(
              responseData['message'] ?? 'Payment verification failed');
        }
      } else {
        _handleVerificationFailure(
            'Verification failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _handleVerificationFailure(
          'Network error during verification: ${e.toString()}');
    }
  }

  void _handleVerificationSuccess(String paymentId, String razorpayOrderId) {
    if (_paymentCompleted || _isNavigating) {
      return; // Prevent duplicate processing
    }

    _paymentCompleted = true;
    _updateStep('Payment successful! Creating order...');

    debugPrint('✅ Payment verified successfully. Creating order now...');

    // Call the callback to create the order in the parent widget
    widget.onPaymentSuccess(paymentId, razorpayOrderId);
  }

  void _handleVerificationFailure(String message) {
    debugPrint('❌ Payment verification failed: $message');
    _handleError('Payment verification failed: $message');
  }

  void _navigateToFailure() {
    if (_isNavigating || _paymentCompleted) return;
    _isNavigating = true;

    debugPrint('🔄 Payment failed. Cart preserved for retry.');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Clear back stack and go to Menu
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteHelper
            .menu, // <-- adjust if your RouteHelper has another getter like getMenuRoute()
        (route) => false,
      );
    });
  }

  void _handleError(String message) {
    if (_paymentCompleted || _isNavigating) {
      return; // Don't show errors after successful payment or if already navigating
    }

    setState(() {
      _isLoading = false;
      _currentStep = 'Error: $message';
    });

    showCustomSnackBarHelper(message);

    // Show error for 3 seconds then navigate back
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_paymentCompleted && !_isNavigating) {
        _navigateToFailure();
      }
    });
  }

  void _updateStep(String step) {
    if (mounted) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        if (!_paymentCompleted && !_isNavigating) {
          _navigateToFailure();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Processing Payment'),
          automaticallyImplyLeading: false,
          actions: [
            if (!_paymentCompleted && !_isNavigating)
              TextButton(
                onPressed: () => _navigateToFailure(),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  CustomLoaderWidget(color: Theme.of(context).primaryColor),
                  const SizedBox(height: 30),
                ] else ...[
                  Icon(
                    Icons.payment,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 30),
                ],
                Text(
                  _currentStep,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!_isLoading && !_currentStep.startsWith('Error')) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Please complete the payment in Razorpay to confirm your order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _paymentCompleted
                            ? 'Payment successful! Creating your order...'
                            : 'Order will be created only after successful payment',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
