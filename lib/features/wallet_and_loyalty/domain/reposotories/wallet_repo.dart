import 'package:flutter_grocery/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_grocery/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;

  WalletRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getWalletTransactionList(String offset, String type) async {
    try {
      final response = await dioClient!.get('${AppConstants.walletTransactionUrl}?offset=$offset&limit=10&transaction_type=$type');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getLoyaltyTransactionList(String offset, String type) async {
    try {
      final response = await dioClient!.get('${AppConstants.loyaltyTransactionUrl}?offset=$offset&limit=10&type=$type');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> pointToWallet({int? point}) async {
    try {
      final response = await dioClient!.post(AppConstants.loyaltyPointTransferUrl, data: {'point': point});
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getWalletBonusList() async {
    try {
      final response = await dioClient!.get(AppConstants.walletBonusListUrl);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // New Razorpay methods
  Future<ApiResponseModel> createRazorpayOrder(double amount) async {
    try {
      final response = await dioClient!.post(
        '${AppConstants.baseUrl}/api/v1/payment/razor-pay/create-order',
        data: {
          'amount': amount,
          'receipt': 'wallet_fund_${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> verifyRazorpayPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final response = await dioClient!.post(
        '${AppConstants.baseUrl}/api/v1/payment/razor-pay/verify-payment',
        data: {
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> addFundViaRazorpay({
    required String paymentId,
    String? orderId,
    String? signature,
    required double amount,
  }) async {
    try {
      // First verify the payment
      final verificationResponse = await verifyRazorpayPayment(
        paymentId: paymentId,
        orderId: orderId ?? '',
        signature: signature ?? '',
      );

      if (verificationResponse.response?.statusCode == 200 && 
          verificationResponse.response?.data['success'] == true) {
        
        // If payment is verified, add funds to wallet
        final response = await dioClient!.post(
          '${AppConstants.baseUrl}/api/v1/customer/add-fund-razorpay',
          data: {
            'payment_id': paymentId,
            'order_id': orderId,
            'amount': amount,
            'payment_method': 'razorpay',
          },
        );
        return ApiResponseModel.withSuccess(response);
      } else {
        return ApiResponseModel.withError('Payment verification failed');
      }
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getPaymentStatus(String paymentId) async {
    try {
      final response = await dioClient!.post(
        '${AppConstants.baseUrl}/api/v1/payment/razor-pay/payment-status',
        data: {
          'payment_id': paymentId,
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}