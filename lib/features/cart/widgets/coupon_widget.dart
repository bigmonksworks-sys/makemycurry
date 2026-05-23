import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CouponWidget extends StatelessWidget {
  const CouponWidget({super.key, required this.couponController, required this.total});

  final TextEditingController couponController;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Image.asset(Images.couponApply, height: 24, width: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: couponController,
                  style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  decoration: InputDecoration(
                    hintText: getTranslated('enter_promo_code', context),
                    hintStyle: poppinsRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    enabled: couponProvider.discount == 0,
                    border: InputBorder.none,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (couponController.text.isNotEmpty && !couponProvider.isLoading) {
                    if (couponProvider.discount! < 1) {
                      couponProvider.applyCoupon(couponController.text, total);
                    } else {
                      couponProvider.removeCouponData(true);
                    }
                  } else {
                    showCustomSnackBarHelper(getTranslated('invalid_code_or_failed', context), isError: true);
                  }
                },
                child: couponProvider.discount! <= 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E29),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: !couponProvider.isLoading
                            ? Text(
                                'Apply Now',
                                style: poppinsSemiBold.copyWith(color: Colors.white, fontSize: 14),
                              )
                            : const SizedBox(
                                height: 18,
                                width: 18,
                                child: CupertinoActivityIndicator(color: Colors.white),
                              ),
                      )
                    : Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        );
      },
    );
  }
}