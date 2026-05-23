import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/wish_button_widget.dart';
import 'package:flutter_grocery/features/product/screens/product_image_screen.dart';
import 'package:provider/provider.dart';

class ProductImageWidget extends StatelessWidget {
  final Product? productModel;
  final SubVariant? selectedSubVariant;
  const ProductImageWidget({super.key, required this.productModel, this.selectedSubVariant});


  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context,listen: false);

    final imageList = <String>[];
    if (selectedSubVariant != null && selectedSubVariant!.image != null && selectedSubVariant!.image!.isNotEmpty) {
      imageList.add(selectedSubVariant!.image!);
    } else if (productModel?.image != null) {
      imageList.addAll(productModel!.image!);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(children: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return Stack(children: [
                InkWell(
                  onTap: () => Navigator.of(context).pushNamed(
                    RouteHelper.getProductImagesRoute(productModel!.name, jsonEncode(imageList), ''),
                    arguments: ProductImageScreen(imageList: imageList, title: productModel!.name, baseUrl: splashProvider.baseUrls?.productImageUrl),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: ResponsiveHelper.isDesktop(context) ? 350 : MediaQuery.of(context).size.height * 0.4,
                    child: PageView.builder(
                      itemCount: imageList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CustomImageWidget(
                              image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${imageList[index]}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      onPageChanged: (index) {
                        Provider.of<CartProvider>(context, listen: false).onSelectProductStatus(index, true);
                        Provider.of<ProductProvider>(context, listen: false).setImageSliderSelectedIndex(index);
                      },
                    ),
                  ),
                ),
                
                // Dot Indicator overlay
                if (imageList.length > 1)
                  Positioned(
                    bottom: 45, // Right over the bottom of the image
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imageList.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cartProvider.productSelect == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]);
            }
          ),

          Positioned(
            top: 36, right: 36,
            child: WishButtonWidget(
              product: productModel, 
              subVariantId: selectedSubVariant?.id,
              edgeInset: const EdgeInsets.all(8),
              color: Colors.black.withValues(alpha: 0.5), 
            ),
          )

        ]),
      ],
    );
  }

}
