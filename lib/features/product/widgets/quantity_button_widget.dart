import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

class QuantityButtonWidget extends StatelessWidget {
  final bool isIncrement;
  final int quantity;
  final bool isCartWidget;
  final int? stock;
  final int? maxOrderQuantity;
  final int? cartIndex;
  final Color? backgroundColor;
  final Color? iconColor;
  final BoxBorder? border;
  final double radius;

  const QuantityButtonWidget({super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.maxOrderQuantity,
    this.isCartWidget = false,
    required this.cartIndex,
    this.backgroundColor,
    this.iconColor,
    this.border,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return InkWell(
      onTap: () {
        if(cartIndex != null) {
          if(isIncrement) {
             if(maxOrderQuantity == null || cartProvider.cartList[cartIndex!].quantity! < maxOrderQuantity!){
               if (cartProvider.cartList[cartIndex!].quantity! < cartProvider.cartList[cartIndex!].stock!) {
                 cartProvider.setCartQuantity(true, cartIndex, showMessage: true, context: context);
               } else {
                 showCustomSnackBarHelper(getTranslated('out_of_stock', context));
               }
             }else{
               showCustomSnackBarHelper('${getTranslated('you_can_add_max', context)} $maxOrderQuantity ${
                   getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
             }

          }else {
            if (cartProvider.cartList[cartIndex!].quantity! > 1) {
              cartProvider.setCartQuantity(false, cartIndex, showMessage: true, context: context);
            } else {
              cartProvider.setExistData(null);
              cartProvider.removeItemFromCart(cartIndex!, context);
            }
          }
        }else {
          if (!isIncrement && quantity > 1) {
            cartProvider.setQuantity(false);
          } else if (isIncrement) {
             if(maxOrderQuantity == null || quantity < maxOrderQuantity!) {
               if(quantity < stock!) {
                 cartProvider.setQuantity(true);
               }else {
                 showCustomSnackBarHelper(getTranslated('out_of_stock', context));
               }
             }else{
               showCustomSnackBarHelper('${getTranslated('you_can_add_max', context)} $maxOrderQuantity ${
                   getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
             }
          }
        }
      },
      child: ResponsiveHelper.isDesktop(context)  ? Container(
        // padding: EdgeInsets.all(3),
        height: 30, width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: backgroundColor,
          border: border,
        ),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: iconColor ?? (isIncrement
                ? Theme.of(context).primaryColor
                : quantity > 1
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor),
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ) : Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: backgroundColor,
          border: border,
        ),
        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          color: iconColor ?? (isIncrement
              ?  Theme.of(context).primaryColor
              : quantity > 1
              ?  Theme.of(context).primaryColor
              :  Theme.of(context).primaryColor),
          size: isCartWidget ? 26 : 20,
        ),
      ),
    );
  }
}
