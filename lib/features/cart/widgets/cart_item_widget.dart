import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartModel cart;
  final int index;
  const CartItemWidget({super.key, required this.cart, required this.index});

  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);

    SubVariant? selectedSubVariant;
    if (cart.subVariantId != null && cart.product?.subVariants != null) {
      try {
        selectedSubVariant = cart.product!.subVariants!.firstWhere((element) => element.id == cart.subVariantId);
      } catch (_) {}
    }

    String? displayUnit = cart.unit;
    if (selectedSubVariant != null && selectedSubVariant.attributes != null && selectedSubVariant.attributes is Map) {
      final map = selectedSubVariant.attributes as Map;
      final String subUnit = map['unit']?.toString() ?? '';
      if (subUnit.isNotEmpty) {
        displayUnit = subUnit;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteHelper.getProductDetailsRoute(productId: cart.product?.id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${(selectedSubVariant != null && selectedSubVariant.image != null && selectedSubVariant.image!.isNotEmpty) ? selectedSubVariant.image : cart.image}',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cart.name ?? '',
                      style: poppinsSemiBold.copyWith(fontSize: 18, color: Colors.black, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (selectedSubVariant != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Variant: ${selectedSubVariant.name ?? ""}',
                          style: poppinsMedium.copyWith(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          'Net : ${_getAttributesText(cart.product!, selectedSubVariant)}',
                          style: poppinsMedium.copyWith(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                    ] else if ((cart.capacity != null && cart.capacity! > 0) || (cart.product?.weight != null && cart.product!.weight! > 0))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${cart.capacity != null ? 'Net : ${cart.capacity}${cart.unit ?? ''}' : ''}${cart.capacity != null && cart.product?.weight != null ? '  |  ' : ''}${cart.product?.weight != null ? 'Gross : ${cart.product?.weight} g' : ''}',
                          style: poppinsMedium.copyWith(fontSize: 14, color: Colors.black45),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    PriceConverterHelper.convertPrice(context, cart.discountedPrice ?? 0),
                                    style: poppinsBold.copyWith(fontSize: 20, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        // Quantity Picker
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F2F4),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
                                  if (cart.quantity! > 1) {
                                    cartProvider.setCartQuantity(false, index, showMessage: true, context: context);
                                  } else {
                                    cartProvider.removeItemFromCart(index, context);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, 
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                  ),
                                  child: const Icon(Icons.remove, size: 16, color: Colors.black),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${cart.quantity}${displayUnit != null && displayUnit.isNotEmpty ? ' ${_getShortUnit(displayUnit)}' : ''}',
                                  style: poppinsMedium.copyWith(fontSize: 14, color: Colors.black),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if(cart.product != null && (cart.product!.maximumOrderQuantity == null || cart.quantity! < cart.product!.maximumOrderQuantity!)) {
                                    if(cart.quantity! < (cart.stock ?? 0)) {
                                      Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
                                      cartProvider.setCartQuantity(true, index, showMessage: true, context: context);
                                    } else {
                                      showCustomSnackBarHelper(getTranslated('out_of_stock', context));
                                    }
                                  } else {
                                    showCustomSnackBarHelper('${getTranslated('you_can_add_max', context)} ${cart.product?.maximumOrderQuantity ?? ''} ${getTranslated((cart.product?.maximumOrderQuantity ?? 0) > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F1E29)),
                                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  String _getAttributesText(Product product, SubVariant subVariant) {
    if (subVariant.attributes == null) {
      return '';
    }
    if (subVariant.attributes is Map) {
      final map = subVariant.attributes as Map;
      final String unit = map['unit']?.toString() ?? '';
      final String capacity = map['capacity']?.toString() ?? '';
      if (unit.toLowerCase() == 'gram' || unit.toLowerCase() == 'gm') {
        return '${capacity}g';
      } else if (unit.isNotEmpty) {
        return '$capacity $unit';
      }
      return capacity;
    }
    return '';
  }

  String _getShortUnit(String? unit) {
    if (unit == null) return '';
    final lower = unit.toLowerCase().trim();
    if (lower == 'packet' || lower == 'packets' || lower == 'pack') {
      return 'pkt';
    }
    if (lower == 'piece' || lower == 'pieces' || lower == 'pc') {
      return 'pcs';
    }
    if (lower == 'gram' || lower == 'grams' || lower == 'gm' || lower == 'g') {
      return 'g';
    }
    if (lower == 'kilogram' || lower == 'kilograms' || lower == 'kg') {
      return 'kg';
    }
    if (lower == 'litre' || lower == 'litres' || lower == 'ltr' || lower == 'l') {
      return 'l';
    }
    return unit;
  }

}



