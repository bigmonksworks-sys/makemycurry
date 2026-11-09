import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/error_response_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/features/auth/screens/login_screen.dart';
import 'package:provider/provider.dart';

class ApiCheckerHelper {
  static void checkApi(ApiResponseModel apiResponse) {
    if (apiResponse.response?.statusCode == 429) {
      return;
    }

    ErrorResponseModel error = getError(apiResponse);

    if (error.errors != null && error.errors!.isNotEmpty &&
        (error.errors![0].code == '401' ||
        error.errors![0].code == 'auth-001' &&
            ModalRoute.of(Get.context!)?.settings.name !=
                RouteHelper.getLoginRoute())) {
      Provider.of<SplashProvider>(Get.context!, listen: false)
          .removeSharedData();
      Navigator.pushAndRemoveUntil(
          Get.context!,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false);
    } else {
      String? errorMessage = (error.errors != null && error.errors!.isNotEmpty)
          ? error.errors!.first.message
          : null;

      if (errorMessage != null && errorMessage.isNotEmpty) {
        final lower = errorMessage.toLowerCase();
        if (lower.contains('<!doctype') ||
            lower.contains('<html') ||
            lower.contains('too many requests') ||
            lower.contains('status code:')) {
          return;
        }
        showCustomSnackBarHelper(getTranslated(errorMessage, Get.context!));
      }
    }
  }

  static ErrorResponseModel getError(ApiResponseModel apiResponse) {
    ErrorResponseModel error;

    if (apiResponse.error != null) {
      error = ErrorResponseModel.fromJson(apiResponse.error);
    } else if (apiResponse.response?.data != null) {
      error = ErrorResponseModel.fromJson(apiResponse.response!.data);
    } else {
      error = ErrorResponseModel(
          errors: [Errors(code: '', message: 'Something went wrong')]);
    }
    return error;
  }
}
