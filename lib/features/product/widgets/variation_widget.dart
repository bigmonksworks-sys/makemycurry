import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';


class VariationWidget extends StatelessWidget {
  final Product? product;
  const VariationWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: product!.choiceOptions!.length,
          padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
          physics:  const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text('Select Quantity', style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: List.generate(
                  product!.choiceOptions![index].options!.length,
                  (i) {
                    bool isSelected = cartProvider.variationIndex![index] == i;
                    return InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        cartProvider.setCartVariationIndex(index, i);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0F1E29) : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: isSelected ? const Color(0xFF0F1E29) : Colors.black12, width: 1),
                        ),
                        child: Text(
                          product!.choiceOptions![index].options![i].trim(), maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: poppinsMedium.copyWith(
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]);
          },
        );
      },
    );
  }
}
