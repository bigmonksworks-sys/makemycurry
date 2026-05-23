import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_directionality_widget.dart';
import 'package:flutter_grocery/common/widgets/price_item_widget.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/features/order/widgets/order_details_button_view.dart';

class OrderAmountWidget extends StatelessWidget {
  final double itemsPrice;
  final double tax;
  final double subTotal;
  final double discount;
  final double couponDiscount;
  final double deliveryCharge;
  final double total;
  final bool isVatInclude;
  final List<OrderPartialPayment> paymentList;
  final OrderModel? orderModel;
  final String? phoneNumber;
  final double extraDiscount;
  final double? weightChargeAmount;

  const OrderAmountWidget({
    super.key, required this.itemsPrice, required this.tax, required this.subTotal,
    required this.discount, required this.couponDiscount, required this.deliveryCharge,
    required this.total, required this.isVatInclude,
    required this.paymentList, this.orderModel, this.phoneNumber, required this.extraDiscount,
    this.weightChargeAmount
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Column( mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getTranslated('cost_summery', context), style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Divider(thickness: 0.5),
            ),

            PriceItemWidget(
              title: 'subtotal'.tr,
              subTitle: PriceConverterHelper.convertPrice(context, itemsPrice),
            ),
            const SizedBox(height: 12),

            PriceItemWidget(
              title: 'discount'.tr,
              subTitle: '- ${PriceConverterHelper.convertPrice(context, discount)}',
            ),
            const SizedBox(height: 12),

            PriceItemWidget(
              title: '${'tax'.tr} ${isVatInclude ? '(${'include'.tr})' : ''}',
              subTitle: '${isVatInclude ? '' : '+'} ${PriceConverterHelper.convertPrice(context, tax)}',
            ),
            const SizedBox(height: 12),

            PriceItemWidget(
              title: 'coupon_discount'.tr,
              subTitle: '- ${PriceConverterHelper.convertPrice(context, couponDiscount)}',
            ),
            const SizedBox(height: 12),

            extraDiscount > 0 ? PriceItemWidget(
              title: 'extra_discount'.tr,
              subTitle: '- ${PriceConverterHelper.convertPrice(context, extraDiscount)}',
            ) : const SizedBox(),
            SizedBox(height: extraDiscount > 0 ? 12 : 0),


            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text(getTranslated('delivery_fee', context), style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                if(weightChargeAmount != null && weightChargeAmount! > 0.0)...[
                  Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                    ),
                    message: "${getTranslated('delivery_charge_base_on', context)} ${getTranslated('delivery_and_weight', context)}",
                    child: CustomAssetImageWidget(
                      Images.deliveryTooltipIcon, color: Theme.of(context).hintColor,
                      height: 18, width: 18,
                    ),
                  ),
                ],
              ]),

              CustomDirectionalityWidget(child: Text(
                '+ ${PriceConverterHelper.convertPrice(context, deliveryCharge)}',
                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
              )),
            ]),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
              child: Divider(thickness: 0.5),
            ),

            PriceItemWidget(
              title: 'total_amount'.tr,
              subTitle: PriceConverterHelper.convertPrice(context, total),
              style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
            ),

            if(paymentList.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              child: Column(children: paymentList.map((payment) => payment.id != null ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Text("${getTranslated(payment.paidAmount! > 0 ? 'paid_amount' : 'due_amount', context)} (${ payment.paidWith != null && payment.paidWith!.isNotEmpty ? '${payment.paidWith?[0].toUpperCase()}${payment.paidWith?.substring(1).replaceAll('_', ' ')}' : getTranslated('${payment.paidWith}', context)})",
                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    overflow: TextOverflow.ellipsis,),

                  Text(PriceConverterHelper.convertPrice(context, payment.paidAmount! > 0 ? payment.paidAmount : payment.dueAmount),
                    style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                ],
                ),
              ) : const SizedBox()).toList()),
            ),
          ]),
        ),

        if(ResponsiveHelper.isDesktop(context)) Column(children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          OrderDetailsButtonView(orderModel: orderModel, phoneNumber: phoneNumber),
        ]),

      ]);
  }
}
