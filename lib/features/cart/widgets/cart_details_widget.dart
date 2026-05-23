import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/price_item_widget.dart';
import 'package:flutter_grocery/features/cart/widgets/coupon_widget.dart';
import 'package:flutter_grocery/features/cart/widgets/delivery_option_widget.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CartDetailsWidget extends StatefulWidget {
  const CartDetailsWidget({
    super.key,
    required TextEditingController couponController,
    required double total,
    required bool isFreeDelivery,
    required double itemPrice,
    required double tax,
    required double discount,
  }) : _couponController = couponController, _total = total, _itemPrice = itemPrice, _tax = tax, _discount = discount, _isFreeDelivery = isFreeDelivery;

  final TextEditingController _couponController;
  final double _total;
  final double _itemPrice;
  final double _tax;
  final double _discount;
  final bool _isFreeDelivery;

  @override
  State<CartDetailsWidget> createState() => _CartDetailsWidgetState();
}

class _CartDetailsWidgetState extends State<CartDetailsWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    return Column(children: [

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getTranslated('delivery_option', context), style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              DeliveryOptionWidget(value: 'delivery', title: getTranslated('home_delivery', context)),
              const SizedBox(width: 10),
              if(configModel.selfPickup == 1)
                DeliveryOptionWidget(value: 'self_pickup', title: getTranslated('self_pickup', context)),
            ],
          ),
        ]),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          return CouponWidget(couponController: widget._couponController, total: widget._total);
        },
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price Details', style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black)),
                Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black, size: 24),
              ],
            ),
          ),
          
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            const Divider(height: 30, thickness: 1, color: Colors.black12),

            PriceItemWidget(
              title: getTranslated('items_price', context),
              subTitle: PriceConverterHelper.convertPrice(context, widget._itemPrice),
              style: poppinsMedium.copyWith(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            PriceItemWidget(
              title: 'Platform fee (Include)',
              subTitle: PriceConverterHelper.convertPrice(context, 0),
              style: poppinsMedium.copyWith(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            PriceItemWidget(
              title: getTranslated('discount', context),
              subTitle: '- ${PriceConverterHelper.convertPrice(context, widget._discount)}',
              style: poppinsMedium.copyWith(color: Colors.black54, fontSize: 16),
            ),

            const SizedBox(height: 8),
            const Divider(height: 30, thickness: 1, color: Colors.black12),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: poppinsSemiBold.copyWith(fontSize: 18, color: Colors.black)),
              Text(
                PriceConverterHelper.convertPrice(context, widget._total),
                style: poppinsBold.copyWith(fontSize: 24, color: const Color(0xFF38B23C)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'You are saving ₹ 150 On this order', 
            style: poppinsMedium.copyWith(fontSize: 12, color: const Color(0xFF38B23C)),
          ),

        ]),
      ),
    ]);
  }
}


