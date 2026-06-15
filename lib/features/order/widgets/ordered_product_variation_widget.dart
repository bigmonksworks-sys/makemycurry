import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/domain/models/order_details_model.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';

class OrderedProductVariationWidget extends StatelessWidget {
  final OrderDetailsModel orderDetailsModel;
  const OrderedProductVariationWidget({super.key, required this.orderDetailsModel});


  @override
  Widget build(BuildContext context) {
    final String? variantText = (orderDetailsModel.variant != null && orderDetailsModel.variant!.isNotEmpty && orderDetailsModel.variant != 'null')
        ? 'Variant: ${orderDetailsModel.variant}'
        : (OrderHelper.getVariationValue(orderDetailsModel.formattedVariation).isNotEmpty && OrderHelper.getVariationValue(orderDetailsModel.formattedVariation) != 'null'
            ? OrderHelper.getVariationValue(orderDetailsModel.formattedVariation)
            : null);

    return variantText != null ? Row(children: [
      Container(height: 10, width: 10, decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      )),
      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

      Text(variantText,
        style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),
    ]):const SizedBox();
  }
}
