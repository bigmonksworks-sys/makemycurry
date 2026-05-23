import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
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
    String? variationText = _getVariationValue();


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
                  image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${cart.image}',
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
                    if ((cart.capacity != null && cart.capacity! > 0) || (cart.product?.weight != null && cart.product!.weight! > 0))
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
                        Text(
                          PriceConverterHelper.convertPrice(context, cart.discountedPrice ?? 0),
                          style: poppinsBold.copyWith(fontSize: 20, color: Colors.black),
                        ),
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
                                  '${cart.quantity}${cart.unit ?? ''}',
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

  String? _getVariationValue() {
    String? variationText = '';
    if(cart.variation != null ) {
      List<String> variationTypes = cart.variation?.type?.split('-') ?? [];
      if(variationTypes.length == cart.product?.choiceOptions?.length) {
        int index = 0;
        for (var choice in cart.product?.choiceOptions ?? []) {
          variationText = '$variationText${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      }else {
        variationText = cart.product?.variations?[0].type;
      }
    }

    return variationText;
  }

}



