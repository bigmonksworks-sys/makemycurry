// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_grocery/common/models/place_order_model.dart';
// import 'package:flutter_grocery/common/providers/cart_provider.dart';
// import 'package:flutter_grocery/features/order/providers/order_provider.dart';
// import 'package:flutter_grocery/helper/route_helper.dart';
// import 'package:flutter_grocery/utill/app_constants.dart';
// import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
// import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:http/http.dart' as http;

// class RazorpayPaymentService {
//   late Razorpay _razorpay;
//   late BuildContext _context;
//   Function? _onSuccess;
//   Function? _onError;
//   String? _razorpayOrderId;
//   int? _orderId;

//   RazorpayPaymentService() {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   /// Initialize Razorpay payment
// Future<void> initiatePayment({
//   required BuildContext context,
//   required PlaceOrderModel orderBody,
//   required Function(bool isSuccess, String message, String orderID) callback,
// }) async {
//   try {
//     // Get the OrderProvider
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);

//     // Create order with Razorpay payment method
//     final razorpayOrderBody = orderBody.copyWith(paymentMethod: 'razor_pay');

//     // Place the order in your system
//     orderProvider.placeOrder(razorpayOrderBody, (isSuccess, message, orderID) {
//       if (isSuccess) {
//         // Print the order ID
// debugPrint('📦&&&&&&&&&&&&&&&&&& Order JSON: ${razorpayOrderBody.toJson()}');
// debugPrint('-------- Order placed successfully $orderID ----------');

//         // Pass success to callback
//         callback(true, message, orderID);
//       } else {
//         // Pass error to callback
//         debugPrint('Failed to place order: $message');
//         callback(false, message, orderID);
//       }
//     });
//   } catch (e) {
//     debugPrint('Error initiating payment: ${e.toString()}');
//     callback(false, 'Error initiating payment: ${e.toString()}', '-1');
//   }
// }

//   /// Create Razorpay order via API
//   Future<void> _createRazorpayOrder(PlaceOrderModel orderBody) async {
    
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConstants.baseUrl}/api/v1/payment/razor-pay/create-order'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'amount': orderBody.orderAmount,
//           'order_id': _orderId,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         if (responseData['success'] == true) {
//           _razorpayOrderId = responseData['order_id'];
//           _openRazorpayCheckout(responseData, orderBody);
//         } else {
//           _onError?.call(false, responseData['message'] ?? 'Failed to create payment order', '-1');
//         }
//       } else {
//         _onError?.call(false, 'Server error: ${response.statusCode}', '-1');
//       }
//     } catch (e) {
//       _onError?.call(false, 'Network error: ${e.toString()}', '-1');
//     }
//   }

//   /// Open Razorpay checkout
//   void _openRazorpayCheckout(Map<String, dynamic> orderData, PlaceOrderModel orderBody) {
//     var options = {
//       'key': orderData['key'],
//       'amount': orderData['amount'],
//       'currency': orderData['currency'],
//       'name': 'Make My Curry',
//       'description': 'Payment for Order #$_orderId',
//       'order_id': orderData['order_id'],
//       'prefill': {
//         // 'contact': orderBody.deliveryAddress?.contactPersonNumber ?? '',
//         'email': '', // Add customer email from your user data
//         // 'name': orderBody.deliveryAddress?.contactPersonName ?? '',
//       },
//       'theme': {
//         'color': '#3399cc'
//       },
//       'notes': {
//         'order_id': _orderId.toString(),
//       },
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       _onError?.call(false, 'Error opening payment: ${e.toString()}', '-1');
//     }
//   }

//   /// Handle payment success
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     log('Payment Success: ${response.paymentId}');
    
//     try {
//       await _verifyPayment(
//         response.paymentId!,
//         response.orderId!,
//         response.signature!,
//       );
//     } catch (e) {
//       _onError?.call(false, 'Error verifying payment: ${e.toString()}', '-1');
//     }
//   }

//   /// Handle payment error
//   void _handlePaymentError(PaymentFailureResponse response) async {
//     log('Payment Error: ${response.code} - ${response.message}');
    
//     await _notifyPaymentFailure(
//       response.code.toString(),
//       response.message ?? 'Payment failed',
//     );
    
//     _onError?.call(false, 'Payment failed: ${response.message}', '-1');
//   }

//   /// Handle external wallet
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     log('External Wallet: ${response.walletName}');
//     _onError?.call(false, 'External wallet selected: ${response.walletName}', '-1');
//   }

//   /// Verify payment with backend
//   Future<void> _verifyPayment(String paymentId, String orderId, String signature) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConstants.baseUrl}/api/v1/payment/razor-pay/verify-payment'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'razorpay_payment_id': paymentId,
//           'razorpay_order_id': orderId,
//           'razorpay_signature': signature,
//           'order_id': _orderId,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         if (responseData['success'] == true) {
//           _handleVerificationSuccess(paymentId);
//         } else {
//           _onError?.call(false, responseData['message'] ?? 'Payment verification failed', '-1');
//         }
//       } else {
//         _onError?.call(false, 'Verification failed: ${response.statusCode}', '-1');
//       }
//     } catch (e) {
//       _onError?.call(false, 'Network error during verification: ${e.toString()}', '-1');
//     }
//   }

//   /// Notify payment failure to backend
//   Future<void> _notifyPaymentFailure(String errorCode, String errorDescription) async {
//     try {
//       await http.post(
//         Uri.parse('${AppConstants.baseUrl}/api/v1/payment/razor-pay/payment-failed'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'order_id': _orderId,
//           'error_code': errorCode,
//           'error_description': errorDescription,
//         }),
//       );
//     } catch (e) {
//       log('Error notifying payment failure: ${e.toString()}');
//     }
//   }

//   /// Handle successful verification
//   void _handleVerificationSuccess(String paymentId) {
//     Provider.of<CartProvider>(_context, listen: false).clearCartList();
//     _onSuccess?.call(true, 'Payment successful', _orderId.toString());
//   }

//   /// Clean up Razorpay instance
//   void dispose() {
//     _razorpay.clear();
//   }
// }