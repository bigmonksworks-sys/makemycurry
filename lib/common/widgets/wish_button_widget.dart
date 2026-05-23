import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';


class WishButtonWidget extends StatelessWidget {
  final Product? product;
  final int? subVariantId;
  final EdgeInsetsGeometry edgeInset;
  final Color? color;
  const WishButtonWidget({super.key, required this.product, this.subVariantId, this.edgeInset = EdgeInsets.zero, this.color});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishListProvider>(builder: (context, wishList, child) {
      bool isFav = wishList.isWishlist(product!.id, subVariantId: subVariantId);
      return Tooltip(
        message: getTranslated('click_to_add_to_your_wish_list', context),
        child: InkWell(
          onTap: () {
            if(Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
              isFav 
                  ? wishList.removeFromWishList(product!, context, subVariantId: subVariantId)
                  : wishList.addToWishList(product!, context, subVariantId: subVariantId);
            }else{
              showCustomSnackBarHelper(getTranslated('now_you_are_in_guest_mode', context));
            }
        
          },
          child: Container(
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).cardColor.withOpacity(0.90),
              shape: color != null ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: color != null ? null : BorderRadius.circular(Dimensions.radiusSizeDefault),
              border: color != null ? null : Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Padding(
              padding: edgeInset,
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : (color != null ? Colors.white : Theme.of(context).primaryColor),
                size: Dimensions.paddingSizeLarge,
              ),
            ),
          ),
        ),
      );
    });
  }
}
