import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class ProductTitleWidget extends StatelessWidget {
  final Product? product;
  final int? stock;
  final int? cartIndex;
  const ProductTitleWidget({super.key, required this.product, required this.stock,required this.cartIndex});

  @override
  Widget build(BuildContext context) {
    double? startingPrice;
    double? startingPriceWithDiscount;
    double? startingPriceWithCategoryDiscount;
    double? endingPrice;
    double? endingPriceWithDiscount;
    double? endingPriceWithCategoryDiscount;
    if(product!.variations!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in product!.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if(priceList[0]! < priceList[priceList.length-1]!) {
        endingPrice = priceList[priceList.length-1];
      }
    }else {
      startingPrice = product!.price;
    }


    if(product!.categoryDiscount != null) {
      startingPriceWithCategoryDiscount = PriceConverterHelper.convertWithDiscount(
        startingPrice, product!.categoryDiscount!.discountAmount, product!.categoryDiscount!.discountType,
        maxDiscount: product!.categoryDiscount!.maximumAmount,
      );

      if(endingPrice != null){
        endingPriceWithCategoryDiscount = PriceConverterHelper.convertWithDiscount(
          endingPrice, product!.categoryDiscount!.discountAmount, product!.categoryDiscount!.discountType,
          maxDiscount: product!.categoryDiscount!.maximumAmount,
        );
      }
    }
    startingPriceWithDiscount = PriceConverterHelper.convertWithDiscount(startingPrice, product!.discount, product!.discountType);

    if(endingPrice != null) {
      endingPriceWithDiscount = PriceConverterHelper.convertWithDiscount(endingPrice, product!.discount, product!.discountType);
    }

    if(startingPriceWithCategoryDiscount != null &&
        startingPriceWithCategoryDiscount > 0 &&
        startingPriceWithCategoryDiscount < startingPriceWithDiscount!) {
      startingPriceWithDiscount = startingPriceWithCategoryDiscount;
      endingPriceWithDiscount = endingPriceWithCategoryDiscount;
    }




    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Padding(
          padding: EdgeInsets.only(
              right: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeSmall
                  : Dimensions.paddingSizeLarge,
              top: ResponsiveHelper.isDesktop(context)
                  ? 0
                  : Dimensions.paddingSizeLarge,
              left: ResponsiveHelper.isDesktop(context)
                  ? 0
                  : Dimensions.paddingSizeLarge,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: product?.name != null ? product!.name!.split(' (').first : '',
                          style: poppinsSemiBold.copyWith(
                            fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeOverLarge : Dimensions.fontSizeExtraLarge,
                            color: Colors.black,
                          ),
                        ),
                        if (product?.name != null && product!.name!.contains(' ('))
                          TextSpan(
                            text: ' (${product!.name!.split(' (').sublist(1).join(' (')}',
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1, color: const Color(0xFF53D258)),
                    color: const Color(0xFFE2F6E3),
                  ),
                  child: Text(
                    getTranslated(product!.totalStock! > 0 ? 'in_stock' : 'stock_out', context),
                    style: poppinsMedium.copyWith(color: const Color(0xFF38B23C), fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.paddingSizeDefault),

            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
              if (product?.rating != null) ...[
                const Icon(Icons.star_border, color: Colors.black87, size: 18),
                Text(
                  product!.rating!.isNotEmpty ? product!.rating![0].average!.toStringAsFixed(1) : '0.0', 
                  style: poppinsRegular.copyWith(color: Colors.black54, fontSize: Dimensions.fontSizeSmall),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('|', style: TextStyle(color: Colors.black26)),
                ),
              ],
              
              const Icon(Icons.access_time, color: Colors.black87, size: 18),
              Text(
                '20-25 min', 
                style: poppinsRegular.copyWith(color: Colors.black54, fontSize: Dimensions.fontSizeSmall),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('|', style: TextStyle(color: Colors.black26)),
              ),
              
              const Icon(Icons.local_shipping_outlined, color: Colors.black87, size: 18),
              Text(
                'Free Delivery', 
                style: poppinsRegular.copyWith(color: Colors.black54, fontSize: Dimensions.fontSizeSmall),
              ),
            ]),

          ]),
        );
      },
    );
  }
}

