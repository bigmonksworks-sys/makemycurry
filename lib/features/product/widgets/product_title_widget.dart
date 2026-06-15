import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_grocery/common/widgets/custom_directionality_widget.dart';

class ProductTitleWidget extends StatelessWidget {
  final Product? product;
  final int? stock;
  final int? cartIndex;
  final SubVariant? selectedSubVariant;

  const ProductTitleWidget({
    super.key,
    required this.product,
    required this.stock,
    required this.cartIndex,
    this.selectedSubVariant,
  });

  @override
  Widget build(BuildContext context) {
    double? originalPrice = selectedSubVariant != null ? selectedSubVariant!.price : product?.price;
    double? activePrice = PriceConverterHelper.convertWithDiscount(
      originalPrice,
      product?.discount,
      product?.discountType,
    );

    String activeSizeText = '';
    if (selectedSubVariant != null) {
      if (selectedSubVariant!.attributes != null && selectedSubVariant!.attributes is Map) {
        final map = selectedSubVariant!.attributes as Map;
        final String unit = map['unit']?.toString() ?? '';
        final String capacity = map['capacity']?.toString() ?? '';
        if (unit.toLowerCase() == 'gram' || unit.toLowerCase() == 'gm') {
          activeSizeText = '${capacity}g';
        } else if (unit.isNotEmpty) {
          activeSizeText = '$capacity $unit';
        } else {
          activeSizeText = capacity;
        }
      }
    } else {
      if (product?.capacity != null && product!.capacity! > 0) {
        activeSizeText = '${product!.capacity} ${product!.unit ?? ''}';
      }
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
            
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomDirectionalityWidget(child: Text(
                  PriceConverterHelper.convertPrice(context, activePrice),
                  style: poppinsSemiBold.copyWith(
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                if (originalPrice != null && activePrice != null && originalPrice > activePrice) ...[
                  CustomDirectionalityWidget(child: Text(
                    PriceConverterHelper.convertPrice(context, originalPrice),
                    style: poppinsRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(context).disabledColor,
                    ),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                ],

                if (activeSizeText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      activeSizeText,
                      style: poppinsMedium.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
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

