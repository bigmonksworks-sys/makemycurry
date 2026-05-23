import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class FreeDeliveryProgressBarWidget extends StatelessWidget {
  const FreeDeliveryProgressBarWidget({
    super.key,
    required double subTotal,
    required ConfigModel configModel,
  }) : _subTotal = subTotal;

  final double _subTotal;

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel;

    return configModel?.freeDeliveryStatus ?? false ? Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F9E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF38B23C)),
            child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            ((configModel?.freeDeliveryOverAmount ?? 0) - _subTotal) > 0
                ? '${PriceConverterHelper.convertPrice(context, (configModel?.freeDeliveryOverAmount ?? 0) - _subTotal)} More to free Delivery!'
                : 'Free Delivery reached!',
            style: poppinsSemiBold.copyWith(fontSize: 14, color: const Color(0xFF38B23C)),
          ),
        ],
      ),
    ) : const SizedBox();
  }
}
